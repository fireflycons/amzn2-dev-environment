# Security group to permit all access from only the public IP of the machine running terraform apply
resource "aws_security_group" "mate_devenv_sg" {
  name        = "fc_public_ip"
  description = "SG that permits ingress from my own public IP only"
  vpc_id      = var.vpc_id

  ingress {
    description = "Any from my IP"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "${chomp(data.http.my_ip_address.body)}/32"
    ]
  }

  egress {
    description = "Any outgoing"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = var.environment_name
  }
}

# Instance role to permit connection with SSM Session Manager
resource "aws_iam_role" "instance_role" {
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
    }
  )
  max_session_duration = 3600
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  path = "/mate-devenv/"
  tags = {
    "Name" = var.environment_name
  }

}

resource "aws_iam_instance_profile" "instance_profile" {
  role = aws_iam_role.instance_role.name
  path = "/mate-devenv/"
  tags = {
    "Name" = var.environment_name
  }

}

resource "aws_instance" "mate_devenv" {
  ami                         = data.aws_ami.devenv_ami.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.mate_devenv_sg.id
  ]
  iam_instance_profile = aws_iam_instance_profile.instance_profile.id
  subnet_id            = var.subnet_id

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 3000
    throughput            = 125
    volume_size           = 30
    volume_type           = "gp3"
  }

  tags = {
    "Name" = var.environment_name
  }

  volume_tags = {
    "Name" = var.environment_name
  }
}

resource "aws_route53_record" "mate_devenv" {
  count   = var.domain_name == "" || var.host_name == "" ? 0 : 1
  zone_id = data.aws_route53_zone.my_zone[0].zone_id
  name    = "${var.host_name}.${data.aws_route53_zone.my_zone[0].name}"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.mate_devenv.public_ip]
}

resource "aws_sns_topic" "auto_stop_topic" {
  name = local.topic_name
  count      = var.notification_email == "" ? 0 : 1
}

resource "aws_sns_topic_subscription" "email_notification" {
  count     = var.notification_email == "" ? 0 : 1
  endpoint  = var.notification_email
  protocol  = "email"
  topic_arn = aws_sns_topic.auto_stop_topic[0].arn
}

resource "aws_cloudwatch_metric_alarm" "auto_stop" {
  count           = var.notification_email == "" ? 0 : 1
  actions_enabled = true
  alarm_actions = [
    aws_sns_topic.auto_stop_topic[0].arn,
    "arn:aws:swf:eu-west-1:104552851521:action/actions/AWS_EC2.InstanceId.Stop/1.0"
  ]
  alarm_name          = local.alarm_name
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 30
  dimensions = {
    InstanceId = aws_instance.mate_devenv.id
  }
  evaluation_periods = 30
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = 60
  statistic          = "Average"
  threshold          = 5
  treat_missing_data = "missing"
}