# Terraform Configuration for AWS EC2 Instance
# This file defines the infrastructure we want to create

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure AWS Provider
# This tells Terraform how to connect to AWS
provider "aws" {
  region = var.aws_region  # Uses the region from variables.tf
  
  # Credentials can be set via:
  # 1. AWS CLI: aws configure
  # 2. Environment variables: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
  # 3. IAM roles (if running on EC2)
}

# Data source: Get the latest Amazon Linux 2023 AMI
# AMI = Amazon Machine Image (the OS template)
# This finds the most recent Amazon Linux image automatically
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group: Firewall rules for your EC2 instance
# This controls what traffic can reach your server
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for Inventory API and Prometheus"

  # Allow HTTP traffic (port 8000 for your API)
  ingress {
    description = "HTTP for Inventory API"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere (for learning)
  }

  # Allow Prometheus metrics (port 9090)
  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH (port 22) - so you can connect to the server
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # In production, restrict this to your IP!
  }

  # Allow all outbound traffic (for downloading packages, etc.)
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

# EC2 Instance: The virtual server
# This creates the actual server where your app will run
resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id  # Use the AMI we found
  instance_type = var.instance_type             # t2.micro (free tier)
  key_name      = aws_key_pair.app_key.key_name # SSH key for access

  # Security group (firewall rules)
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # User data script: Runs when the instance starts
  # This installs Docker, runs your app, and sets up Prometheus
  user_data = file("${path.module}/user_data.sh")

  # Tags: Labels for organizing resources
  tags = {
    Name        = "${var.project_name}-server"
    Project     = var.project_name
    Environment = "learning"
  }
}

# Key Pair: SSH key for secure access to the EC2 instance
# This allows you to SSH into the server
resource "aws_key_pair" "app_key" {
  key_name   = "${var.project_name}-key"
  public_key = file("${path.module}/../.ssh/id_rsa.pub")  # We'll create this
}

# Output: Information displayed after Terraform creates resources
# These values are shown when you run `terraform apply`
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.app.public_dns
}

output "api_url" {
  description = "URL to access your Inventory API"
  value       = "http://${aws_instance.app.public_ip}:8000"
}

output "prometheus_url" {
  description = "URL to access Prometheus"
  value       = "http://${aws_instance.app.public_ip}:9090"
}

output "ssh_command" {
  description = "Command to SSH into the server"
  value       = "ssh -i ../.ssh/id_rsa ec2-user@${aws_instance.app.public_ip}"
}

