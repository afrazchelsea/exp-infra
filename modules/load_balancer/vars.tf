variable "vpc_id" {
  description = "VPC ID in which the instance is to be created"
  type        = string
}

variable "alb_subnets" {
  description = "ID of the subnet in which ALB is to be kept"
  type        = list(string)
}

variable "deployment_account" {
  description = "Deployment Environment"
  type        = string
}

variable "env" {
  description = "VPC name"
  type        = string
}

variable "targets" {
  type        = list(string)
  description = ""
  default     = []
}
