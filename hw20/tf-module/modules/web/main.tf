# ---------- Найсвіжіший Amazon Linux 2023 AMI ----------
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ---------- Підмережі переданої VPC (беремо першу) ----------
data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# ---------- Security Group: відкриваємо передані порти звідусіль ----------
resource "aws_security_group" "web" {
  name        = "${var.name}-sg"
  description = "Allow inbound on provided ports from anywhere"
  vpc_id      = var.vpc_id

  # dynamic-блок створює по одному ingress-правилу на кожен порт зі списку
  dynamic "ingress" {
    for_each = var.list_of_open_ports
    content {
      description = "Allow port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}

# ---------- Публічний EC2 з Nginx ----------
resource "aws_instance" "web" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.selected.ids[0]
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  # Скрипт, що виконується при першому запуску інстансу
  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    systemctl enable --now nginx
    echo "<h1>Nginx is running on $(hostname -f)</h1>" > /usr/share/nginx/html/index.html
  EOF

  tags = {
    Name = "${var.name}-web"
  }
}
