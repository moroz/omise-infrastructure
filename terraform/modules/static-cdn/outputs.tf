output "bucket" {
  value = aws_s3_bucket.assets
}

output "cloudfront_distribution" {
  value = aws_cloudfront_distribution.distribution
}
