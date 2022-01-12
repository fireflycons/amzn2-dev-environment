variable "vpc_id" {
  description = "VPC to deploy instance to"
  type        = string
  validation {
    condition     = can(regex("^vpc-([0-9a-f]{8}|[0-9a-f]{17})$", var.vpc_id))
    error_message = "Invalid VPC ID."
  }
}

variable "subnet_id" {
  description = "Subnet within VPC to deploy instance to"
  type        = string
  validation {
    condition     = can(regex("^subnet-([0-9a-f]{8}|[0-9a-f]{17})$", var.subnet_id))
    error_message = "Invalid subnet ID."
  }
}

variable "instance_type" {
  description = "AWS Instance type to use for the environment"
  type        = string
}

variable "domain_name" {
  description = "A domain name you have hosted in Route53 to which a record will be added for the instance. Omit this to not create a DNS entry."
  type        = string
  default     = ""
}

variable "host_name" {
  description = "Host name to add to the domain provided by domain_name variable. Required if domain_name is set."
  type        = string
  default     = ""
}

variable "environment_name" {
  description = "Whatever is provided here will be added to the 'Name' tag on all taggable resources."
  type        = string
  default     = "MATE devenv"
}