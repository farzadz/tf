resource "aws_subnet" "web_subnet" {
  vpc_id                  = var.vpc_id
  #  assign_ipv6_address_on_creation = true fixme
  map_public_ip_on_launch = true
  cidr_block              = var.subnet_cidr_block["web"]
  availability_zone       = var.availability_zone
}

resource "aws_subnet" "app_subnet" {
  vpc_id                  = var.vpc_id
  #  assign_ipv6_address_on_creation = true fixme
  map_public_ip_on_launch = false
  cidr_block              = var.subnet_cidr_block["app"]
  availability_zone       = var.availability_zone
}

resource "aws_subnet" "db_subnet" {
  vpc_id                  = var.vpc_id
  #  assign_ipv6_address_on_creation = true fixme
  map_public_ip_on_launch = false
  cidr_block              = var.subnet_cidr_block["db"]
  availability_zone       = var.availability_zone
}

resource "aws_subnet" "reserved_subnet" {
  vpc_id                  = var.vpc_id
  #  assign_ipv6_address_on_creation = true fixme
  map_public_ip_on_launch = false
  cidr_block              = var.subnet_cidr_block["reserved"]
  availability_zone       = var.availability_zone
}


resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = var.vpc_id

  # these are fine since routing is done based on the most specific match and there are local
  # routes that match the vpc for both ipv4 and ipv6
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.vpc_gw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = data.aws_internet_gateway.vpc_gw.id
  }
}

resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

# this association is different and is linked to the public route table

resource "aws_route_table_association" "web_subnet_route_table_association" {
  subnet_id      = aws_subnet.web_subnet.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}


resource "aws_route_table_association" "reserved_subnet_route_table_association" {
  subnet_id      = aws_subnet.reserved_subnet.id
  route_table_id = aws_route_table.private_subnet_route_table.id
}

resource "aws_route_table_association" "db_subnet_route_table_association" {
  subnet_id      = aws_subnet.db_subnet.id
  route_table_id = aws_route_table.private_subnet_route_table.id
}

resource "aws_route_table_association" "app_subnet_route_table_association" {
  subnet_id      = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.private_subnet_route_table.id
}

resource "aws_eip" "nat_gw_elastic_ip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id     = aws_eip.nat_gw_elastic_ip.id
  connectivity_type = "public"
  subnet_id         = aws_subnet.web_subnet.id
}
