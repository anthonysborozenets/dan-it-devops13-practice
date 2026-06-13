variable "vpc_id" {
  description = "ID VPC, у якій створюються ресурси"
  type        = string
}

variable "list_of_open_ports" {
  description = "Список портів, які відкриваємо звідусіль"
  type        = list(number)
}

variable "name" {
  description = "Префікс для імен ресурсів"
  type        = string
  default     = "tf-module-demo"
}

variable "instance_type" {
  description = "Тип EC2"
  type        = string
  default     = "t3.micro"
}
