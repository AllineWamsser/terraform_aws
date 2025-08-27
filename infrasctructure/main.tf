terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Keypair
resource "aws_key_pair" "grocery_key" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key)
}

# Security Group para EC2
resource "aws_security_group" "grocery_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = var.vpc_id

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

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# EC2 Instance
resource "aws_instance" "grocery_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = element(var.public_subnets, 0)
  vpc_security_group_ids = [aws_security_group.grocery_sg.id]
  key_name               = aws_key_pair.grocery_key.key_name

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name   = "${var.project_name}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow HTTP"
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

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# Registrar EC2 no Target Group
resource "aws_lb_target_group_attachment" "app_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.grocery_ec2.id
  port             = 80
}

# Listener ALB
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# S3 Bucket
resource "aws_s3_bucket" "grocery_bucket" {
  bucket = "${var.project_name}-bucket-${random_id.suffix.hex}"

  tags = {
    Name = "${var.project_name}-bucket"
  }
}

# ACL separada
resource "aws_s3_bucket_acl" "grocery_bucket_acl" {
  bucket = aws_s3_bucket.grocery_bucket.id
  acl    = "private"
}

# Random ID para sufixo único no bucket
resource "random_id" "suffix" {
  byte_length = 4
}
















