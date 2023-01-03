output "instance_ip" {
  value = aws_instance.tf_instance.public_ip
}

output "instance_dns" {
  value = aws_instance.tf_instance.public_dns
}

