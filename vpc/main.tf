resource "aws_vpc" "vpc" {
  cidr_block                       = "10.16.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "vpc_route_table" {
  vpc_id = aws_vpc.vpc.id

  # these are fine since routing is done based on the most specific match and there are local
  # routes that match the vpc for both ipv4 and ipv6
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }
}


resource "aws_subnet" "vpc_private_subnet" {
  for_each                = {for subnet in local.subnets : "${subnet.az_name}-${subnet.subnet_type}" => subnet if !subnet.public}
  vpc_id                  = aws_vpc.vpc.id
  #  assign_ipv6_address_on_creation = true fixme
  map_public_ip_on_launch = each.value.public
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az_name
}

resource "aws_subnet" "vpc_public_subnet" {
  for_each                = {for subnet in local.subnets : "${subnet.az_name}-${subnet.subnet_type}" => subnet if subnet.public}
  vpc_id                  = aws_vpc.vpc.id
  #  assign_ipv6_address_on_creation = true fixme
  map_public_ip_on_launch = each.value.public
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az_name
}

# this is to use count, to overcome the limitations of for_each
locals {
  public_subnets = values(aws_subnet.vpc_public_subnet)[*].id
}

resource "aws_route_table_association" "route_table_association" {
  count          = length(local.public_subnets)
  subnet_id      = local.public_subnets[count.index]
  route_table_id = aws_route_table.vpc_route_table.id
}


resource "aws_instance" "jumpbox_instance" {
  #ubuntu 22.04
  ami                    = "ami-0574da719dca65348"
  instance_type          = "t2.micro"
  key_name               = var.instance_public_key_name
  # get the id of the first public subnet from the map
  subnet_id              = sort((values(aws_subnet.vpc_public_subnet)[*].id))[0]
  vpc_security_group_ids = [aws_security_group.jumpbox_instance_security_group.id]
}


resource "aws_security_group" "jumpbox_instance_security_group" {
  name   = "jumpbox_security_group"
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = toset(local.instance.ports_in)
    content {
      description = "Inbound"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "egress" {
    for_each = toset(local.instance.ports_out)
    content {
      description = "Outbound"
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}