variable "project_name" {
  type        = string
  description = "Project name"
}

variable "env" {
  type        = string
  description = "Environment"
}

variable "domain" {
  type        = string
  description = "Main domain for web application"
}

variable "elb_endpoint" {
  type        = string
  description = "ELB Application endpoint"
}

variable "route53_zone_id" {
  type = string
}
