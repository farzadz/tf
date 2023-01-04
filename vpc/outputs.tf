output "vpc_id" {
  value = aws_vpc.vpc
}

output "web_subnets" {
  value = {for az in keys(module.subnet[*]) : az => module.subnet.web_subnet}
}

output "db_subnets" {
  value = {for az in keys(module.subnet[*]) : az => module.subnet.db_subnet}
}

output "reserved_subnets" {
  value = {for az in keys(module.subnet[*]) : az => module.subnet.reserved_subnet}
}

output "app_subnets" {
  value = {for az in keys(module.subnet[*]) : az => module.subnet.app_subnet}
}

output "jumpbox_instance_ip" {
  value = aws_instance.jumpbox_instance.public_ip
}

output "jumpbox_instance_dns" {
  value = aws_instance.jumpbox_instance.public_dns
}

