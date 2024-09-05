locals {
//   global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl", "global.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl", "region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl", "env.hcl"))
//   project_name = local.global_vars.locals.project_name
  env = local.env_vars.locals.environment
  aws_region   = local.region_vars.locals.region
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    encrypt        = false
    bucket         = "sepapp-dinhuy975"
    key = "${path_relative_to_include()}/terraform.tfstate"

    region         = local.aws_region
    dynamodb_table = "test-terraform-locks"

    skip_metadata_api_check     = true // commented when using with iam_role on ec2
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
    provider "aws" {
        region = "${local.aws_region}"
    }
    EOF
}

