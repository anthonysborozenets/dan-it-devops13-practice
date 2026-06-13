output "public_instance_public_ip" {
  description = "Публічний IP bastion-інстансу"
  value       = aws_instance.public.public_ip
}

output "public_instance_private_ip" {
  description = "Приватний IP bastion-інстансу"
  value       = aws_instance.public.private_ip
}

output "private_instance_private_ip" {
  description = "Приватний IP приватного інстансу"
  value       = aws_instance.private.private_ip
}

output "ssh_to_bastion" {
  description = "Готова команда для підключення до bastion"
  value       = "ssh -i ${var.project_name}-key.pem ec2-user@${aws_instance.public.public_ip}"
}
