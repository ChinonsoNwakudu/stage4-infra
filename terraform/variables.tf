variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"  # Change to your region if different (e.g., us-west-2)
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.large"  # t2.micro may crash, so use t2.small
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair in AWS"
  default     = "chin-key"  # Match your key pair
  type        = string
}

variable "app_repo_url" {
  description = "URL of your forked application repository"
  default     = "https://github.com/ChinonsoNwakudu/DevOps-Stage-4"  # Update this
  type        = string
}