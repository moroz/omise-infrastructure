locals {
  s3_origin_id = "S3Origin"
}

resource "aws_s3_bucket" "assets" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.assets.id
  policy = data.aws_iam_policy_document.public_read.json
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = aws_s3_bucket.assets.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  http_version        = "http2and3"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "https-only"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # cache optimized
    compress               = true

    response_headers_policy_id = aws_cloudfront_response_headers_policy.cors.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}

resource "aws_cloudfront_response_headers_policy" "cors" {
  name = "${var.bucket_name}-cors-response-policy"

  cors_config {
    access_control_allow_credentials = true

    access_control_allow_headers {
      items = ["Access-Control-Request-Headers", "Origin", "Access-Control-Request-Methods"]
    }

    access_control_allow_methods {
      items = ["GET", "HEAD"]
    }

    access_control_allow_origins {
      items = ["*"]
    }

    origin_override = true
  }
}


