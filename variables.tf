#ALL VARIABLES ARE DEFINED HERE!

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "num_frontend_subnets" {
  description = "Number of frontend subnets"
  type        = number
}

variable "num_backend_subnets" {
  description = "Number of backend subnets"
  type        = number
}

variable "num_db_subnets" {
  description = "Number of database subnets"
  type        = number
  validation {
    condition     = var.num_db_subnets >= 2
    error_message = "At least 2 DB subnets are required!!."
  }
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "image_name" {
  description = "Docker image name"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the execution role"
  type        = string
}