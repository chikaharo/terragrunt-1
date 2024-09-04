terraform {
  source = "github.com/cloudposse/terraform-aws-ecs-alb-service-task.git?ref=0.64.0"
}

## Dependencies:
// dependencies {
//   paths = [
//     "${dirname(find_in_parent_folders())}/env/${local.aws_region}/security-groups/${local.name}",
//     "${dirname(find_in_parent_folders())}/${local.folder_name}/${local.aws_region}/lb",
//     "${dirname(find_in_parent_folders())}/env/${local.aws_region}/ecs/definitions/${local.name}",
//     "${dirname(find_in_parent_folders())}/env/${local.aws_region}/ecs/clusters",
//     "${dirname(find_in_parent_folders())}/env/global/iam/roles/ecs-task-exec",
//     "${dirname(find_in_parent_folders())}/env/global/iam/roles/ecs-service",
//   ]
// }

# dependency "aws-data" {
#   config_path = "${dirname(find_in_parent_folders())}/env/${local.aws_region}/aws-data"
# }

dependency "vpc" {
  config_path = "${dirname(find_in_parent_folders())}/_env/vpc"
}

dependency "definition" {
  config_path = "${dirname(find_in_parent_folders())}/_env/ecs/definitions/"
}

dependency "cluster" {
  config_path = "${dirname(find_in_parent_folders())}/_env//ecs/clusters"
}

dependency "alb" {
  config_path = "${dirname(find_in_parent_folders())}/_env//alb"
}

dependency "iam_task" {
  config_path = "${dirname(find_in_parent_folders())}/_env/iam/ecs-task-exec"
}

dependency "iam_task_exec" {
  config_path = "${dirname(find_in_parent_folders())}/_env/iam/ecs-task-exec"
}

dependency "iam_service" {
  config_path = "${dirname(find_in_parent_folders())}/_env/iam/ecs-service"
}

dependency "sg" {
  config_path = "${dirname(find_in_parent_folders())}/_env/sg"
  mock_outputs = {
    alb_sg = "alb-sg-1234"
    ecs_sg = "ecs-sg-123"
  }
}


## Variables:
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"), {})
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env         = local.env_vars.locals.environment
  aws_region  = local.region_vars.locals.region
  name        = basename(get_terragrunt_dir())
  name-prefix = lower("${local.global_vars.locals.project_name}-${local.env}")

  launch_type      = try(local.global_vars.locals.ecs_settings.launch_type, "FARGATE")
  assign_public_ip = try(local.global_vars.locals.ecs_settings.assign_public_ip, false)
  folder_name      = local.env == "prod" ? "env" : "common"
  tags = {
      Name = "${local.name-prefix}-${local.name}"
      Env  = local.env
    }
}

inputs = {
  name                               = "${local.name-prefix}-${local.name}"
  alb_security_group                 = dependency.sg.outputs.alb_sg.id
  container_definition_json          = dependency.definition.outputs.json_map_encoded_list
  ecs_cluster_arn                    = dependency.cluster.outputs.cluster_arn
  launch_type                        = local.launch_type
  platform_version                   = local.launch_type != "FARGATE" ? null : try(local.global_vars.locals.ecs_settings.platform_version, "LATEST")
  task_role_arn                      = [dependency.iam_task.outputs.iam_role_arn]
  task_exec_role_arn                 = [dependency.iam_task_exec.outputs.iam_role_arn]
  service_role_arn                   = dependency.iam_service.outputs.iam_role_arn
  vpc_id                             = dependency.vpc.outputs.vpc_id
  security_group_ids                 = [dependency.sg.outputs.ecs_sg.id]
  security_group_enabled             = false
  subnet_ids                         = local.assign_public_ip ? [dependency.vpc.outputs.public_subnet_1_id, dependency.vpc.outputs.public_subnet_2_id] : [dependency.vpc.outputs.private_subnet_1_id]
  ignore_changes_task_definition     = try(local.global_vars.locals.ecs_settings.ignore_changes_task_definition, false)
  network_mode                       = local.launch_type != "FARGATE" ? "bridge" : "awsvpc"
  assign_public_ip                   = local.assign_public_ip
  propagate_tags                     = try(local.global_vars.locals.ecs_settings.propagate_tags, "TASK_DEFINITION")
  deployment_minimum_healthy_percent = try(local.global_vars.locals.ecs_settings.deployment_minimum_healthy_percent, 100)
  deployment_maximum_percent         = try(local.global_vars.locals.ecs_settings.deployment_maximum_percent, "200")
  deployment_controller_type         = try(local.global_vars.locals.ecs_settings[local.name].deployment_controller_type, "ECS")
  desired_count                      = try(local.global_vars.locals.ecs_settings["desired_count"], 1)
  task_memory                        = try(local.global_vars.locals.ecs_settings[local.name][local.env]["task_memory"], 512) # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
  task_cpu                           = try(local.global_vars.locals.ecs_settings[local.name][local.env]["task_cpu"], 256)
  exec_enabled                       = try(local.global_vars.locals.ecs_settings[local.env]["exec_enabled"], true)
  tags                               = local.tags

  # ecs_load_balancers = [
  #   {
  #     container_name   = dependency.definition.outputs.json_map_object.name
  #     container_port   = dependency.definition.outputs.json_map_object.portMappings[0].containerPort
  #     elb_name         = null #try(dependency.alb.outputs.target_group_arns[0], null) != null ? null : split("/", coalesce(try(dependency.alb.outputs.lb_arn_suffix, ""), "/elb/name"))[1]
  #     target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:468629877310:targetgroup/microservices02-nghiand-frontend/4f7a3894676b5783" #try(dependency.alb.outputs.target_group_arns[0], null)
  #   }
  # ]
}
