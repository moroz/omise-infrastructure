variable "environments" {
  type    = list(string)
  default = ["staging"]
}

variable "project_name" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "aws_availability_zones" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "aws_account_id" {
  type = string
}

variable "dockerhub_username" {
  type = string
}

variable "dockerhub_password" {
  type = string
}

variable "docker_repos" {
  type    = list(string)
  default = []
}

variable "cloudflare_api_token" {
  type = string
}

variable "cloudflare_zone_ids" {
  type = map(string)
}

variable "database_passwords" {
  type = map(string)
}
