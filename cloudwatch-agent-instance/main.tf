resource "aws_instance" "tf_cloudwatch_instance" {
  #ubuntu 22.04
  ami                  = "ami-0574da719dca65348"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.tf_cw_agent_instance_profile.name
  key_name             = var.instance_public_key_name
  security_groups      = [aws_security_group.tf_instance_security_group.name]
  user_data            = <<EOF
#!/bin/bash

wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb
sudo apt-get update && sudo apt-get install -f && sudo apt-get install apache2 -y
sudo service apache2 start


sudo mkdir -p /usr/share/collectd/
sudo touch /usr/share/collectd/types.db

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:${aws_ssm_parameter.tf_cloudwatch_agent_config.name} -s

EOF
  depends_on           = [aws_ssm_parameter.tf_cloudwatch_agent_config]
}

resource "aws_ssm_parameter" "tf_cloudwatch_agent_config" {
  name  = "cloudwatch-agent-config"
  type  = "String"
  value = file("./cloudwatch-config.json")
}

resource "aws_security_group" "tf_instance_security_group" {
  name = "tf_cw_agent_security_group"

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


resource "aws_iam_instance_profile" "tf_cw_agent_instance_profile" {
  name = "tf_cw_agent_instance_profile"
  role = aws_iam_role.tf_profile_role.name
}

resource "aws_iam_role" "tf_profile_role" {
  name = "tf_cw_agent_profile_role"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
  ]

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
