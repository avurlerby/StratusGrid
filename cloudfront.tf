resource "aws_cloudfront_distribution" "main" {
  aliases = [
    "${var.domain}",
  ]
  comment = "${var.project_name}-${var.env}"

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

    target_origin_id         = var.elb_endpoint
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"

    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
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
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"

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
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"

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
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"

    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    viewer_protocol_policy = "redirect-to-https"
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
  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.root.arn
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
