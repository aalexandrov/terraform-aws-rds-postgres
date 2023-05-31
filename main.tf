module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name                 = "mz_rds_demo_vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "mz_rds_demo_db_subnet_group" {
  name       = "mz_rds_demo_db_subnet_group"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "mz_rds_demo_db_subnet_group"
  }
}

resource "aws_security_group" "mz_rds_demo_sg" {
  name        = "mz_rds_demo_vpc"
  description = "Materialize RDS Terraform demo"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = distinct(concat(var.mz_egress_ips, [format("%s/%s", data.http.user_public_ip.response_body, "32")]))
  }
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_string" "mz_rds_demo_db_password" {
  length  = 32
  upper   = true
  numeric = true
  special = false
}

resource "aws_db_parameter_group" "mz_rds_demo_pg" {
  name   = var.rds_instance_name
  family = "postgres13"

  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }
}

resource "aws_db_instance" "mz_rds_demo_db" {
  identifier             = "mz-rds-demo-db"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "13"
  instance_class         = "db.m5.large"
  db_name                = "materialize"
  username               = "materialize"
  password               = random_string.mz_rds_demo_db_password.result
  vpc_security_group_ids = [aws_security_group.mz_rds_demo_sg.id]
  parameter_group_name   = aws_db_parameter_group.mz_rds_demo_pg.name
  apply_immediately      = true
  # Publicly accessible by default for demo purposes
  publicly_accessible  = var.publicly_accessible
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.mz_rds_demo_db_subnet_group.name
}
