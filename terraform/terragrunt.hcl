locals {
  base_vars   = yamldecode(file("./vars/vars.yml"))
  env_secrets = yamldecode(file("./vars/secrets.yml"))
  secrets     = merge(local.base_vars, local.env_secrets)
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${get_env("TG_BUCKET_PREFIX", "")}terraform-state-${local.secrets.project_name}-${local.secrets.aws_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    profile        = local.secrets.aws_profile
    region         = local.secrets.aws_region
    dynamodb_table = "terraform-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.11"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

provider "aws" {
  region = "${local.secrets.aws_region}"
  profile = "${local.secrets.aws_profile}"
}

provider "aws" {
  region = "ap-northeast-1"
  alias = "tokyo"
  profile = "${local.secrets.aws_profile}"
}

provider "aws" {
  region = "us-east-1"
  alias = "east1"
  profile = "${local.secrets.aws_profile}"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
EOF
}

inputs = local.secrets
