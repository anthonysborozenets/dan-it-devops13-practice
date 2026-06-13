# Беремо default VPC акаунта (вона вже має Internet Gateway і публічні підмережі)
data "aws_vpc" "default" {
  default = true
}

# Викликаємо наш модуль
module "web" {
  source             = "./modules/web"
  vpc_id             = data.aws_vpc.default.id
  list_of_open_ports = var.list_of_open_ports
}
