terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-autoscaling.git?ref=v6.9.0"
}

## Dependencies:
dependency "vpc" {
  config_path ="${dirname(find_in_parent_folders())}/_env/vpc"
}

dependency "sg" {
  config_path = "${dirname(find_in_parent_folders())}/_env/sg"
}

dependency "keypair" {
  config_path = "${dirname(find_in_parent_folders())}/_env/key_pair"
}



## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"), {})
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env          = local.env_vars.locals.env
  env_desc     = local.env_vars.locals.env_desc
  aws_region   = local.region_vars.locals.aws_region
  name         = basename(get_terragrunt_dir())
  project_name = local.global_vars.locals.project_name
  name-prefix  = "${local.global_vars.locals.project_name}-${local.env}"
  prompt_color = try(local.global_vars.locals.ec2_settings["${local.env}"]["prompt_color"], "32m")
  ssh_user     = try(local.global_vars.locals.ssh_user["${local.env}"], "hbnet")
  folder_name  = local.env == "prod" ? "env" : "common"

  tags = merge(
    try(local.global_vars.locals.tags, {}),
    {
      Name = lower("${local.name-prefix}-${local.name}")
      Env  = local.env_desc
    }
  )
}

inputs = {
  name = "${local.project_name}-${local.env}-asg"

  # image_id      = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type = "t2.micro"

  vpc_zone_identifier = dependency.vpc.outputs.public_subnets
  health_check_type   = "EC2"
  min_size            = 0
  max_size            = 2
  desired_capacity    = 1

  security_groups = [dependency.sg.outputs.security_group_id]
  key_name        = dependency.keypair.outputs.key_pair_key_name
//   user_data = base64encode(templatefile(
//     "${dirname(find_in_parent_folders())}/_templates/user-data/ubuntu.tpl",
//     {
//       "ssh_user"            = lower(local.ssh_user)
//       "user"                = lower("${local.project_name}-${local.env}")
//       "project_name"        = lower(local.project_name)
//       "hostname"            = "${upper(local.project_name)}-${upper(local.env)}-${upper(local.name)}"
//       "prompt_color"        = local.prompt_color
//       "ssh_authorized_keys" = dependency.ssh.outputs.public_keys["${local.project_name}-${local.env}"]
//       "ecs_cluster"         = lower("${local.project_name}-${local.env}")
//     }
//   ))

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 30
        volume_type           = "gp3"
      }
    }
  ]



  # ignore_desired_capacity_changes = true

  # create_iam_instance_profile = true
  # iam_role_name               = local.name
  # iam_role_description        = "ECS role for ${local.name}"
  # iam_role_policies = {
  #   AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  #   AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  # }



  # autoscaling_group_tags = {
  #   AmazonECSManaged = true
  # }

  # protect_from_scale_in = true

  tags = local.tags
}
