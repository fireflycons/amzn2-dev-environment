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

resource "aws_route53_record" "ee-devenv" {
  count   = var.domain_name == "" || var.host_name == "" ? 0 : 1
  zone_id = data.aws_route53_zone.my_zone[0].zone_id
  name    = "${var.host_name}.${data.aws_route53_zone.my_zone[0].name}"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.mate_devenv.public_ip]
}