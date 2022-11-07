
resource "aws_s3_bucket" "frontend" {
  bucket = "${lower(var.project_name)}-${var.env}-frontend"
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  restrict_public_buckets = true
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true
}

data "aws_iam_policy_document" "frontend_s3_policy" {
  dynamic "statement" {
    for_each = var.domain
    content {
      actions   = ["s3:GetObject"]
      resources = ["${aws_s3_bucket.frontend.arn}/${statement.value}/*"]

      principals {
        type        = "AWS"
        identifiers = [module.cloudfront_entrypoint[statement.value].oai_arn]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_s3_policy" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.frontend_s3_policy.json
}
