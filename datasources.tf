data "aws_availability_zones" "available" {}

data "http" "user_public_ip" {
  url = "https://ifconfig.me/ip"
}
