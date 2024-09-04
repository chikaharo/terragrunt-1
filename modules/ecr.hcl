terraform {
  source = "github.com/cloudposse/terraform-aws-ecr.git//.?ref=0.33.0"
}

## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env          = local.env_vars.locals.environment
  global_tags  = try(local.global_vars.locals.tags, {})
  project_name = try(local.global_vars.locals.project_name, "example")
  name         = basename(get_terragrunt_dir())
  name-prefix  = lower("${local.project_name}-${local.env}")

  tags = merge(
    local.global_tags,
    {
      Name = "${local.name-prefix}-${local.name}"
      Env  = local.env
    }
  )
}

inputs = {
  namespace = try(local.global_vars.locals.project_name, "project")
  stage     = local.env
  name      = "ecr-app"
  tags      = local.tags
}
