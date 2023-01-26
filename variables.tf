# AWS Details
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = "default"
}
variable "aws_config_file" {
  description = "AWS config file"
  type        = list(any)
  default     = ["~/.aws/config"]
}

# The Materialize egress IPs, eg: SELECT * FROM mz_egress_ips;
variable "mz_egress_ips" {
  description = "List of Materialize egress IPs"
  type        = list(any)
}
