resource "aws_iam_role" "codepipeline_role" {
  name = local.codepipeline_role_name

  assume_role_policy = file("./policies/codepipeline_assume_policy.json")
}

resource "aws_iam_role_policy" "codepipeline_role" {
  name = "${local.codepipeline_role_name}-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = file("./policies/codepipeline_policy.json")
}

resource "aws_iam_role_policy" "codebuild_role" {
  role = aws_iam_role.codebuild_role.name

  policy = templatefile("./policies/build_role_policy.tpl", {
    s3_bucket  = aws_s3_bucket.pipeline_artifacts.arn
    aws_region = var.aws_region
  })
}

resource "aws_iam_role" "codebuild_role" {
  name = local.codebuild_role_name

  assume_role_policy = file("./policies/build_role_assume_policy.json")
}

resource "aws_iam_role" "event_role" {
  name               = local.event_role_name
  assume_role_policy = file("./policies/event_role_assume_policy.json")
}

resource "aws_iam_role_policy" "event_role_policy" {
  role = aws_iam_role.event_role.name

  policy = templatefile("./policies/event_role_policy.tpl", {
    pipeline = aws_codepipeline.cd_pipeline.arn
  })
}
