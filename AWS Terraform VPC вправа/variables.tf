variable "aws_region" {
  description = "AWS регіон"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Префікс для імен ресурсів"
  type        = string
  default     = "tf-vpc-demo"
}

variable "vpc_cidr" {
  description = "CIDR-блок для VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR публічної підмережі"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR приватної підмережі"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "Тип EC2 (t3.micro — free tier у Frankfurt)"
  type        = string
  default     = "t3.micro"
}

variable "my_ip" {
  description = "Твій публічний IP у форматі CIDR для SSH-доступу, напр. 1.2.3.4/32"
  type        = string
}
