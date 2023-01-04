resource "aws_vpc" "vpc" {
  cidr_block                       = "10.16.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

module "subnet" {
  for_each          = local.az_subnets
  source            = "./az"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  subnet_cidr_block = {
    "web" : each.value["web"]["cidr_block"]
    "db" : each.value["db"]["cidr_block"]
    "reserved" : each.value["reserved"]["cidr_block"]
    "app" : each.value["app"]["cidr_block"]
  }
  depends_on = [
    aws_internet_gateway.igw
  ]
}