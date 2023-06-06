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

# Publicly accessible or not
variable "publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible or not"
  type        = bool
  default     = true
}

# Name of the RDS instance
variable "rds_instance_name" {
  description = "The name of the RDS instance"
  type        = string
}

# RDS instance size
variable "rds_instance_class" {
  description = "The size of the RDS instance"
  type        = string
  default     = "db.m5.large"
}

# RDS instance engine version
variable "engine_version" {
  description = "The engine version of the RDS instance"
  type        = string
  default     = "14"
}
