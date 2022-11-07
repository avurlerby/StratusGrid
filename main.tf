terraform {
  backend "http" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "${var.project_name}"
      Environment = "${var.env}"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "${var.project_name}"
      Environment = "${var.env}"
    }
  }
}

module "cloudfront_entrypoint" {
  for_each = var.domain
  source   = "./modules/cloudfront-entrypoint"

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  project_name = var.project_name
  env          = var.env

  domain           = var.domain
  route53_zone_id  = aws_route53_zone.main.zone_id
  s3_bucket_domain = aws_s3_bucket.frontend.bucket_regional_domain_name
  elb_endpoint     = var.elb_endpoint
}

variable "project_name" {
  type        = string
  description = "Project name: "
  default     = "statusgrid"
}

variable "region" {
  type        = string
  default     = "us-east-2"
  description = "AWS region"
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

variable "cidr_ab" {
  default = "192.168"
}