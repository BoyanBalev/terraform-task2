variable "vpc_cider" {
  type = string

}

variable "num_backend_subnets" {
  type =number
}

variable "num_frontend_subnets" {
  type =number
}

variable "num_db_subnets" {
  type =number
  default = 2
  validation {
    condition     = var.num_db_subnets >= 2
    error_message = "You must define at least 2 DB subnets."
  }
}

variable "db_username" {
  type = string
}


variable "db_password" {
  type = string
}






variable "ecr_repository_name" {
    type = string
}

variable "image_name" {
  type = string
}

variable "app_name" {
  type = string
}

variable "execution_role_arn" {
  description = "The ARN of the ECS Task Execution Role"
  type        = string
}