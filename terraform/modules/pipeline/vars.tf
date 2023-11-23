variable "base_name" {
  type = string
}

variable "git_repo_name" {
  type = string
}

variable "deployment_role" {
  default = null
}

variable "codecommit_repo_arn" {
  type = string
}

variable "codedeploy_app_name" {
  type    = string
  default = null
}

variable "codebuild_image" {
  type    = string
  default = null
}

variable "deployment_group_name" {
  type    = string
  default = null
}

variable "git_branch" {
  type    = string
  default = "staging"
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "additional_build_env_vars" {
  type    = map(string)
  default = {}
}

variable "build_secrets" {
  type    = map(string)
  default = {}
}

variable "is_arm" {
  type    = bool
  default = false
}

variable "enable_deploy" {
  type    = bool
  default = true
}

variable "build_image" {
  type    = string
  default = null
}

variable "dockerhub_credential_arn" {
  type    = string
  default = null
}

variable "codebuild_privileged_mode" {
  type    = bool
  default = false
}
