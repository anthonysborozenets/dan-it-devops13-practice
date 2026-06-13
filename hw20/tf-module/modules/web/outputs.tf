output "instance_public_ip" {
  description = "Публічний IP створеного EC2"
  value       = aws_instance.web.public_ip
}

output "security_group_id" {
  description = "ID створеної Security Group"
  value       = aws_security_group.web.id
}
