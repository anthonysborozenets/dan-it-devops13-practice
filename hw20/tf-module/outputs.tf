output "instance_public_ip" {
  description = "Публічний IP створеного EC2"
  value       = module.web.instance_public_ip
}

output "nginx_url" {
  description = "Адреса для перевірки Nginx у браузері"
  value       = "http://${module.web.instance_public_ip}"
}
