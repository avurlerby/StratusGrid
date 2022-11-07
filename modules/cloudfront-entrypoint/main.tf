terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "4.8.0"
      configuration_aliases = [aws, aws.us-east-1]
    }
  }
}

resource "aws_acm_certificate" "this" {
  domain_name       = "${var.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  provider = aws.us-east-1
}

resource "aws_route53_record" "certificate" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 3600
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

resource "aws_route53_record" "this" {
  name    = "${var.domain}"
  type    = "A"
  zone_id = var.route53_zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
  }
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "${var.project_name}-${var.env}/${var.domain}"
}


data "aws_cloudfront_cache_policy" "Managed_CachingOptimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "Managed_CachingDisabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "Managed_AllViewer" {
  name = "Managed-AllViewer"
}

data "aws_cloudfront_origin_request_policy" "Managed_CORS_S3Origin" {
  name = "Managed-CORS-S3Origin"
}

resource "aws_cloudfront_distribution" "this" {
  aliases = [
    "${var.domain}",
  ]
  comment             = "${var.project_name}-${var.env}/${var.domain}"
  default_root_object = "index.html"

  enabled          = true
  http_version     = "http2"
  is_ipv6_enabled  = true
  price_class      = "PriceClass_200"
  retain_on_delete = false

  wait_for_deployment = true

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]
    cached_methods = ["GET", "HEAD"]

    target_origin_id         = "${var.domain}-origin"
    cache_policy_id          = data.aws_cloudfront_cache_policy.Managed_CachingOptimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.Managed_CORS_S3Origin.id

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern = "/api/*"
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"
    ]
    cached_methods = ["GET", "HEAD"]

    target_origin_id         = var.elb_endpoint
    cache_policy_id          = data.aws_cloudfront_cache_policy.Managed_CachingDisabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.Managed_AllViewer.id

    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern = "/oauth2*"
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]
    cached_methods = ["GET", "HEAD"]

    target_origin_id         = var.elb_endpoint
    cache_policy_id          = data.aws_cloudfront_cache_policy.Managed_CachingDisabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.Managed_AllViewer.id

    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern = "/files/*"
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]
    cached_methods = ["GET", "HEAD"]

    target_origin_id         = var.elb_endpoint
    cache_policy_id          = data.aws_cloudfront_cache_policy.Managed_CachingDisabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.Managed_AllViewer.id

    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    viewer_protocol_policy = "redirect-to-https"
  }

  origin {
    domain_name = var.s3_bucket_domain
    origin_path = "/${var.domain}"
    origin_id   = "${var.domain}-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  origin {
    connection_attempts = 3
    connection_timeout  = 10
    domain_name         = var.elb_endpoint
    origin_id           = var.elb_endpoint

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.this.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }
}
