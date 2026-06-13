# ---------- SG для публічного (bastion) інстансу ----------
resource "aws_security_group" "public" {
  name        = "${var.project_name}-public-sg"
  description = "SSH from my IP, all outbound"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-public-sg"
  }
}

# ---------- SG для приватного інстансу ----------
resource "aws_security_group" "private" {
  name        = "${var.project_name}-private-sg"
  description = "All outbound (for ping via NAT)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH only from the bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public.id] # дозвіл лише з публічного SG
  }

  ingress {
    description     = "ICMP (ping) from the bastion"
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.public.id]
  }

  egress {
    description = "All outbound (for ping via NAT)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-private-sg"
  }
}
