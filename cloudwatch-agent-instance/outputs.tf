output "instance_ip" {
  value = aws_instance.tf_cloudwatch_instance.public_ip
}

output "instance_dns" {
  value = aws_instance.tf_cloudwatch_instance.public_dns
}

