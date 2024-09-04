terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role?ref=v4.9.0"
}

## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env          = local.env_vars.locals.environment
  name =  basename(get_terragrunt_dir())
  project_name = local.global_vars.locals.project_name
  name-prefix  = lower("${local.project_name}-${local.env}")

  tags = {
      Name = "${local.name-prefix}-${local.name}"
      Env  = local.env
    }

}

inputs = {
  role_name        = lower("${local.name-prefix}-${local.name}")
  role_description = "Roles for ${local.env} ${local.name}"
  create_role      = true

  role_requires_mfa       = false
  trusted_role_services   = ["ec2.amazonaws.com"]
  create_instance_profile = true
  custom_role_policy_arns = []

  tags = local.tags
}
