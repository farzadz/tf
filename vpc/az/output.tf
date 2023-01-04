output "web_subnet" {
  value = aws_subnet.web_subnet.id
}

output "app_subnet" {
  value = aws_subnet.app_subnet.id
}

output "db_subnet" {
  value = aws_subnet.db_subnet.id
}

output "reserved_subnet" {
  value = aws_subnet.reserved_subnet.id
}