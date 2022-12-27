resource "aws_instance" "tf_cw_instance" {
  #ubuntu 22.04
  ami                  = "ami-0574da719dca65348"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.tf_cw_instance_profile.name
  key_name             = var.instance_public_key_name
  security_groups      = [aws_security_group.tf_cw_instance_security_group.name]
  monitoring           = true
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "cpu alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "10"      #seconds
  statistic           = "Average"
  threshold           = "15"

  dimensions = {
    InstanceId = aws_instance.tf_cw_instance.id
  }
}


resource "aws_security_group" "tf_cw_instance_security_group" {
  name = "tf_cw_security_group"

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


resource "aws_iam_instance_profile" "tf_cw_instance_profile" {
  name = "tf_cw_instance_profile"
  role = aws_iam_role.tf_cw_profile_role.name
}

resource "aws_iam_role" "tf_cw_profile_role" {
  name = "tf_cw_profile_role"

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
