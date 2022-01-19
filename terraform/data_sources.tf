# Gets my public IP address
data "http" "my_ip_address" {
  url = "http://checkip.amazonaws.com"
  request_headers = {
    Accept = "text/plain"
  }
}

# Gets latest devenv ami we built with packer
data "aws_ami" "devenv_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["amzn2-devenv-*"]
  }
}

# Gets zone ID for given domain, if domain was specified
data "aws_route53_zone" "my_zone" {
  count = var.domain_name == "" ? 0 : 1
  name  = var.domain_name
}

