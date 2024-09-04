terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-ecs.git?ref=v4.1.3"
}

## Dependencies:
dependencies {
  paths = [
  ]
}


## Variables:
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"), {})
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env         = local.env_vars.locals.environment
  env_desc    = local.env_vars.locals.env_desc
  aws_region  = local.region_vars.locals.region
  name        = basename(get_terragrunt_dir())
  name-prefix = lower("${local.global_vars.locals.project_name}-${local.env}")

  tags = merge(
    try(local.global_vars.locals.tags, {}),
    {
      Name = "${local.name-prefix}-${local.name}"
      Env  = local.env_desc
    }
  )
}

inputs = {
  cluster_name = "${local.name-prefix}-cluster"
  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/${local.name-prefix}/aws-ec2"
      }
    }
  }

  fargate_capacity_providers =  {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 1
        base   = 1
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 1
      }
    }
    } 

  tags = local.tags
}
