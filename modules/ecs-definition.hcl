terraform {
  source = "github.com/cloudposse/terraform-aws-ecs-container-definition.git//.?ref=0.58.1"
}

# Dependencies:


## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"), {})
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  aws_region   = try(local.region_vars.locals.aws_region, "ap-southeast-1")
  env          = try(local.env_vars.locals.environment, "dev")
  env_desc     = try(local.env_vars.locals.env_desc, "Development")
  project_name = try(local.global_vars.locals.project_name, "example")
  name_prefix  = lower("${local.project_name}-${local.env}")
  global_tags  = try(local.global_vars.locals.tags, {})
  name         = basename(get_terragrunt_dir())
  launch_type  = try(local.global_vars.locals.ecs_settings.launch_type, "FARGATE")
  prefix       = local.env == "dev" ? "dev" : local.env == "stage" ? "stg" : "prd"
}

inputs = {
  container_name               = try(local.global_vars.locals.ecs_settings["container_name"]["${local.name}"], "${local.name}-container")
  container_image              = "nginxdemos/hello"
  container_cpu                = try(local.global_vars.locals.ecs_settings["cpu"], 0)
  container_memory_reservation = try(local.global_vars.locals.ecs_settings["memory_reservation"], 128)
  # container_memory           = try(local.global_vars.locals.ecs_settings["memory"], 256)

//   environment      = try(local.global_vars.locals.ecs_settings["environment"], [])
//   secrets          = try(local.global_vars.locals.ecs_settings["secrets"], [])
//   command          = try(local.global_vars.locals.ecs_settings["command"], null)
//   linux_parameters = try(local.global_vars.locals.ecs_settings["linux_parameters"], null)
//   healthcheck      = try(local.global_vars.locals.ecs_settings["healthcheck"], null)
//   entrypoint       = try(local.global_vars.locals.ecs_settings["entrypoint"], null)


  log_configuration = local.env == "prod" ? {
    logDriver = "awslogs"
    options = {
      "awslogs-create-group"  = "true"
      "awslogs-group"         = "/aws/ecs/${local.name_prefix}-${local.name}"
      "awslogs-region"        = local.aws_region
      "awslogs-stream-prefix" = local.name
    }
  } : null

  port_mappings = [
    {
      containerPort = try(local.global_vars.locals.ecs_settings["port"], 80)
      hostPort      = local.launch_type == "FARGATE" ? try(local.global_vars.locals.ecs_settings["port"], 80) : 0
      protocol      = "tcp"
    }
  ]
}
