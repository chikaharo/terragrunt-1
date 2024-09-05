include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/security/iam-role.hcl"
}

## Dependencies:
dependencies {
  paths = []
}

## Variables:
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env         = local.env_vars.locals.env
  bname       = basename(get_terragrunt_dir())
  name        = "${local.global_vars.locals.project_name}-ecsTaskExecutionRole"
}

inputs = {
  role_name               = "${local.name}-${local.env}"
  role_description        = ""
  create_instance_profile = false
  trusted_role_services   = ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
  custom_role_policy_arns = [
    # "arn:aws:iam::753363116616:policy/GetRole",
    # "arn:aws:iam::753363116616:policy/invoke-sagemaker",
    # "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]

  ## Inline:
  policy_file = "${dirname(find_in_parent_folders())}/_templates/iam/${local.bname}.json.tpl"
  s3_resources = [
    "arn:aws:s3:::dev-3108app-s3",
    "arn:aws:s3:::dev-3108app-s3-${local.env}",
    "arn:aws:s3:::dev-3108app-s3-${local.env}/*",
    "arn:aws:s3:::dev-3108app-s3-${local.env}-public",
    "arn:aws:s3:::dev-3108app-s3-${local.env}-public/*"
  ]
}
