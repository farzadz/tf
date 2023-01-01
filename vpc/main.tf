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

  #  public ipv4 subnet routes
  #  dynamic "route" {
  #    for_each = {for subnet in local.subnets : "${subnet.az_name}-${subnet.subnet_type}" => subnet if subnet.public}
  #    content {
  #      cidr_block = route.value.cidr_block
  #      gateway_id = aws_internet_gateway.igw.id
  #    }
  #  }

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

resource "aws_route_table_association" "route_table_association" {
  for_each       = toset(values(aws_subnet.vpc_public_subnet)[*].id) # got from terraform console
  subnet_id      = each.value
  route_table_id = aws_route_table.vpc_route_table.id
}