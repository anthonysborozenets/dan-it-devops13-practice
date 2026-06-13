variable "list_of_open_ports" {
  description = "Порти, які відкриваємо звідусіль (80 — для Nginx, 22 — для SSH)"
  type        = list(number)
  default     = [22, 80]
}
