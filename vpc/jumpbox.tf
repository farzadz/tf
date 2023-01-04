resource "aws_instance" "jumpbox_instance" {
  #ubuntu 22.04
  ami                    = "ami-0574da719dca65348"
  instance_type          = "t2.micro"
  key_name               = var.instance_public_key_name
  # get the id of the first web subnet from the map
  subnet_id              = (values(module.subnet)[*].web_subnet)[0]
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
