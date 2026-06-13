output "public_ips" {
  description = "Публічні IP створених EC2"
  value       = aws_instance.web[*].public_ip
}

output "urls" {
  description = "Адреси для перевірки Nginx у браузері"
  value       = [for ip in aws_instance.web[*].public_ip : "http://${ip}"]
}
