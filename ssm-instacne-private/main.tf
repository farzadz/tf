resource "aws_vpc" "vpc" {
  cidr_block                       = "10.16.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = true
}


resource "aws_subnet" "vpc_private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false
  cidr_block              = "10.16.16.0/20"
  availability_zone       = "us-east-1a"
}

resource "aws_instance" "private_instance" {
  #ubuntu 22.04
  ami                    = "ami-0574da719dca65348"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.private_instance_instance_profile.name
  key_name               = var.instance_public_key_name
  subnet_id              = aws_subnet.vpc_private_subnet.id
  vpc_security_group_ids = [aws_security_group.private_instance_security_group.id]
}


resource "aws_security_group" "private_instance_security_group" {
  name   = "private_instance_security_group"
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = toset(local.instance.ports_in)
    content {
      description = "Inbound"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [aws_vpc.vpc.cidr_block]
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


resource "aws_security_group" "interface_security_group" {
  name   = "interface_security_group"
  vpc_id = aws_vpc.vpc.id

  ingress {

    description = "Inbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    description = "Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_iam_instance_profile" "private_instance_instance_profile" {
  name = "private_instance_instance_profile"
  role = aws_iam_role.tf_profile_role.name
}


resource "aws_vpc_endpoint" "ssm_interface" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids          = [aws_subnet.vpc_private_subnet.id]
  security_group_ids  = [aws_security_group.interface_security_group.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2_messages_interface" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type = "Interface"

  subnet_ids          = [aws_subnet.vpc_private_subnet.id]
  security_group_ids  = [aws_security_group.interface_security_group.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_messages_interface" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids          = [aws_subnet.vpc_private_subnet.id]
  security_group_ids  = [aws_security_group.interface_security_group.id]
  private_dns_enabled = true
}

resource "aws_iam_role" "tf_profile_role" {
  name = "private_instance_profile_role"

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
