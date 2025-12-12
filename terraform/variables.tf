# Variables: Configurable values for your infrastructure
# Change these to customize your setup

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"  # Change to your preferred region
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  # Free tier eligible
  # Other options: t2.small, t3.micro, etc.
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "inventory-api"
}

