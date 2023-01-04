# required for managing private instances with ssm session manager
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


resource "aws_vpc_endpoint" "ssm_interface" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids          = [(values(module.subnet)[*].web_subnet)[0]]
  security_group_ids  = [aws_security_group.interface_security_group.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2_messages_interface" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type = "Interface"

  subnet_ids          = [(values(module.subnet)[*].web_subnet)[0]]
  security_group_ids  = [aws_security_group.interface_security_group.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_messages_interface" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids          = [(values(module.subnet)[*].web_subnet)[0]]
  security_group_ids  = [aws_security_group.interface_security_group.id]
  private_dns_enabled = true
}