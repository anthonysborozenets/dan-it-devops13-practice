resource "aws_key_pair" "jenkins" {
  key_name   = "${var.project}-key"
  public_key = file(pathexpand(var.public_key_path))

  tags = local.tags
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "master" {
  name        = "${var.project}-master-sg"
  description = "SSH and HTTP for Jenkins master"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${var.project}-master-sg" })
}

resource "aws_security_group" "worker" {
  name        = "${var.project}-worker-sg"
  description = "SSH from master only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from master"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.master.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${var.project}-worker-sg" })
}

resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.public.id
  key_name               = aws_key_pair.jenkins.key_name
  vpc_security_group_ids = [aws_security_group.master.id]

  tags = merge(local.tags, { Name = "${var.project}-master" })
}

resource "aws_instance" "worker" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.private.id
  key_name               = aws_key_pair.jenkins.key_name
  vpc_security_group_ids = [aws_security_group.worker.id]

  instance_market_options {
    market_type = "spot"

    spot_options {
      spot_instance_type             = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }

  tags = merge(local.tags, { Name = "${var.project}-worker" })
}
