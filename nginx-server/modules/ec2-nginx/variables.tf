variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 Instance type"
  type        = string
  default     = "t3.micro"
}

variable "cidr_block" {
  description = "the cidr_block for route table and security groups"
  default     = "0.0.0.0/0"
}
