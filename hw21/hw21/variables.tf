variable "aws_region" {
  description = "AWS регіон"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Префікс імен ресурсів"
  type        = string
  default     = "tf-ansible"
}

variable "instance_type" {
  description = "Тип EC2"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Скільки EC2 піднімати"
  type        = number
  default     = 2
}

variable "my_ip" {
  description = "Твій публічний IP у форматі CIDR для SSH, напр. 1.2.3.4/32"
  type        = string
}
