
resource "aws_acm_certificate" "root" {
  domain_name       = var.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  provider = aws.us-east-1
}
