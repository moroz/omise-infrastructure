resource "aws_cloudwatch_event_rule" "source_update" {
  name        = "${var.base_name}-source-event"
  description = "AWS CodeCommit source updated"

  event_pattern = jsonencode({
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    resources   = [var.codecommit_repo_arn]
    detail = {
      event = [
        "referenceCreated",
        "referenceUpdated"
      ]
      referenceType = [
        "branch"
      ]
      referenceName = [var.git_branch]
    }
  })
}

resource "aws_cloudwatch_event_target" "codepipeline" {
  rule     = aws_cloudwatch_event_rule.source_update.name
  arn      = aws_codepipeline.cd_pipeline.arn
  role_arn = aws_iam_role.event_role.arn
}
