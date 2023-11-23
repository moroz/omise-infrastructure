locals {
  role_name                   = "${var.deployment_group_name}-deploy-role"
  registerer_user_name        = "${var.deployment_group_name}-registerer"
  registerer_user_policy_name = "${var.deployment_group_name}-registerer-policy"
}

resource "aws_codedeploy_deployment_group" "example" {
  app_name              = var.app_name
  deployment_group_name = var.deployment_group_name
  service_role_arn      = aws_iam_role.deployment_role.arn

  ec2_tag_filter {
    key   = "DeploymentGroupName"
    type  = "KEY_AND_VALUE"
    value = var.deployment_group_name
  }

  on_premises_instance_tag_filter {
    key   = "DeploymentGroupName"
    type  = "KEY_AND_VALUE"
    value = var.deployment_group_name
  }
}

resource "aws_iam_role" "deployment_role" {
  name = local.role_name

  assume_role_policy = file("./policies/codedeploy_assume_policy.json")
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.deployment_role.name
}

resource "aws_iam_user" "registerer" {
  count = var.is_on_premises ? 1 : 0
  name  = local.registerer_user_name
}

resource "aws_iam_user_policy" "registerer" {
  count = var.is_on_premises ? 1 : 0
  name  = local.registerer_user_policy_name
  user  = local.registerer_user_name

  policy = file("./policies/registerer_policy.json")
}
