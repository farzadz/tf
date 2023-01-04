data "aws_vpc" "current" {
  id = var.vpc_id
}

data "aws_internet_gateway" "vpc_gw" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}