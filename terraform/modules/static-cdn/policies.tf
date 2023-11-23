data "aws_iam_policy_document" "public_read" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]

    resources = ["${aws_s3_bucket.assets.arn}/*"]
  }
}
