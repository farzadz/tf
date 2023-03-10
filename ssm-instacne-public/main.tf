resource "aws_instance" "tf_instance" {
  #ubuntu 22.04
  ami                  = "ami-0574da719dca65348"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.tf_ssm_instance_profile.name
  key_name             = var.instance_public_key_name
  security_groups      = [aws_security_group.tf_instance_security_group.name]
  user_data            = <<EOF
#!/bin/bash
apt remove landscape-client landscape-common
rm -f /etc/motd
apt update && apt install -y cowsay update-motd
echo "#!/bin/sh" > /etc/update-motd.d/40-cow
echo '/usr/games/cowsay "Ubuntu 22.04"' >> /etc/update-motd.d/40-cow
chmod 755 /etc/update-motd.d/40-cow
update-motd
EOF
}


resource "aws_security_group" "tf_instance_security_group" {
  name = "tf_ssm_security_group"

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


resource "aws_iam_instance_profile" "tf_ssm_instance_profile" {
  name = "tf_ssm_instance_profile"
  role = aws_iam_role.tf_profile_role.name
}

resource "aws_iam_role" "tf_profile_role" {
  name = "tf_ssm_profile_role"

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
