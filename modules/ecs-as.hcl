terraform {
  source = "github.com/pingbui/terraform-modules.git//ecs-service-autoscale?ref=0.2.8"
}

## Dependencies:
dependencies {
  paths = [
    "${dirname(find_in_parent_folders())}/_env/ecs/services/${local.name}",
  ]
}

dependency "cluster" {
  config_path = "${dirname(find_in_parent_folders())}/_env/ecs/clusters"
}

dependency "service" {
  config_path = "${dirname(find_in_parent_folders())}/env/ecs/services/${local.name}"
}

## Variables:
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"), {})
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env         = local.env_vars.locals.environment
  // env_desc    = local.env_vars.locals.env_desc
  aws_region  = local.region_vars.locals.region
  name        = basename(get_terragrunt_dir())
  name-prefix = lower("${local.global_vars.locals.project_name}-${local.env}")

  tags = merge(
    try(local.global_vars.locals.tags, {}),
    {
      Name = "${local.name-prefix}-${local.name}"
      Env  = local.env
    }
  )
}

inputs = {
  name               = lower("${local.name-prefix}-${local.name}")
  cluster_name       = dependency.cluster.outputs.cluster_name
  service_name       = dependency.service.outputs.service_name
  min_capacity       = try(local.global_vars.locals.ecs_settings[local.env]["min_capacity"], "1")
  max_capacity       = try(local.global_vars.locals.ecs_settings["${local.name}"][local.env]["max_capacity"], "2")
  target_cpu         = try(local.global_vars.locals.ecs_settings[local.env]["target_cpu"], "70")
  target_mem         = try(local.global_vars.locals.ecs_settings[local.env]["target_mem"], "75")
  scale_in_cooldown  = try(local.global_vars.locals.ecs_settings[local.env]["scale_in_cooldown"], "300")
  scale_out_cooldown = try(local.global_vars.locals.ecs_settings[local.env]["scale_out_cooldown"], "60")
  timezone           = try(local.global_vars.locals.time_zone, "Asia/Tokyo")
  schedules          = try(local.global_vars.locals.ecs_settings["${local.name}"][local.env]["schedules"], [])
}
