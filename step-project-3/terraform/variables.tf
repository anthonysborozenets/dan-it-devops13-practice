variable "region" {
  description = "AWS регіон"
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Префікс для імен ресурсів"
  type        = string
  default     = "jenkins"
}

variable "vpc_cidr" {
  description = "CIDR для VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR публічної підмережі (master)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR приватної підмережі (worker)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_key_path" {
  description = "Шлях до публічного SSH-ключа"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
