output "instance_ip" {
  value = aws_instance.private_instance.private_ip
}

output "instance_dns" {
  value = aws_instance.private_instance.private_dns
}

