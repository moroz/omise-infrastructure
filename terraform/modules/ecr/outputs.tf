output "ecr_repo" {
  value = aws_ecr_repository._
}

output "ecr_repo_arn" {
  value = aws_ecr_repository._.arn
}
