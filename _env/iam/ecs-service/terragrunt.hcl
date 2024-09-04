include "root" {
  path = find_in_parent_folders()
}

include "modules" {
  path = "${dirname(find_in_parent_folders())}/modules/iam-role.hcl"
}

## Dependencies:
dependencies {
  paths = []
}

## Variables:
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env         = local.env_vars.locals.environment
  name        = "${local.global_vars.locals.project_name}-ecsServiceRole"
}

inputs = {
  role_name               = "${local.name}-${local.env}"
  role_description        = ""
  trusted_role_services   = ["ecs.amazonaws.com"]
  create_instance_profile = false
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
  ]
}
