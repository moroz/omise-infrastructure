locals {
  pipeline_name          = "${var.base_name}-codepipeline"
  app_name               = "${var.base_name}-app"
  artifact_bucket_name   = "${local.pipeline_name}-artifacts"
  codepipeline_role_name = "${local.pipeline_name}-service-role"
  event_role_name        = "${local.pipeline_name}-event-role"
  codebuild_project_name = "${var.base_name}-build"
  codebuild_role_name    = "${local.codebuild_project_name}-service-role"
  deployment_group_name  = var.deployment_group_name

  codebuild_image = var.build_image != null ? var.build_image : (var.is_arm ? "aws/codebuild/amazonlinux2-aarch64-standard:3.0" : "aws/codebuild/standard:7.0")
}

resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket        = local.artifact_bucket_name
  force_destroy = true
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = local.codebuild_project_name
  service_role  = aws_iam_role.codebuild_role.arn
  badge_enabled = false

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = local.codebuild_image
    privileged_mode             = var.codebuild_privileged_mode
    type                        = var.is_arm ? "ARM_CONTAINER" : "LINUX_CONTAINER"
    image_pull_credentials_type = var.build_image != null ? "SERVICE_ROLE" : "CODEBUILD"

    dynamic "environment_variable" {
      for_each = var.additional_build_env_vars
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }

    dynamic "environment_variable" {
      for_each = var.build_secrets
      content {
        name  = environment_variable.key
        value = environment_variable.value
        type  = "SECRETS_MANAGER"
      }
    }

    dynamic "registry_credential" {
      for_each = var.build_image != null ? [1] : []

      content {
        credential          = var.dockerhub_credential_arn
        credential_provider = "SECRETS_MANAGER"
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "buildspec.yml"
    git_clone_depth = 0
  }
}

resource "aws_codepipeline" "cd_pipeline" {
  name     = local.pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.pipeline_artifacts.bucket
  }

  stage {
    name = "Source"

    action {
      category        = "Source"
      owner           = "AWS"
      provider        = "CodeCommit"
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact"
      ]
      run_order = 1
      version   = "1"

      configuration = {
        "RepositoryName"       = var.git_repo_name
        "BranchName"           = var.git_branch
        "PollForSourceChanges" = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      configuration = {
        "ProjectName" = aws_codebuild_project.codebuild_project.name
      }
      input_artifacts = [
        "SourceArtifact"
      ]
      output_artifacts = [
        "BuildArtifact"
      ]
      name      = "Build"
      run_order = 1
      version   = "1"
    }
  }

  stage {
    name = "Deploy"

    action {
      name     = "Deploy"
      category = "Deploy"
      owner    = "AWS"
      provider = "CodeDeploy"

      input_artifacts = ["BuildArtifact"]
      version         = "1"

      configuration = {
        "ApplicationName"     = var.codedeploy_app_name
        "DeploymentGroupName" = var.deployment_group_name
      }
    }
  }
}
