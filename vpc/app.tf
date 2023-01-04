resource "aws_instance" "app_instance" {
  #ubuntu 22.04
  ami                    = "ami-0574da719dca65348"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.app_instance_profile.name
  subnet_id              = (values(module.subnet)[*].app_subnet)[0]
  key_name               = var.instance_public_key_name
  vpc_security_group_ids = [aws_security_group.app_instance_security_group.id]
}


resource "aws_security_group" "app_instance_security_group" {
  name   = "app_security_group"
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


resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "app_instance_profile"
  role = aws_iam_role.app_instance_profile_role.name
}

resource "aws_iam_role" "app_instance_profile_role" {
  name = "app_instance_profile_role"

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
