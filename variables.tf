# AWS Details
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

# The Materialize egress IPs, eg: SELECT * FROM mz_egress_ips;
variable "mz_egress_ips" {
  description = "List of Materialize egress IPs"
  type        = list(any)
}
