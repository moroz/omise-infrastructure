output "deployment_role" {
  value = aws_iam_role.deployment_role
}

output "deployment_group_name" {
  value = aws_codedeploy_deployment_group.example.deployment_group_name
}
