terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-alb.git//.?ref=v6.6.1"
}
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env          = local.env_vars.locals.env
  name         = basename(dirname("${get_terragrunt_dir()}/../.."))
  project_name = local.global_vars.locals.project_name
}

dependency "sg" {
  config_path = "${dirname(find_in_parent_folders())}/_env/sg"
  mock_outputs = {
    alb_sg = "sg-12345"
  }
}

dependency "s3_ec2" {
  config_path = "${dirname(find_in_parent_folders())}/_env/s3/files"
  mock_outputs = {
    s3_bucket_id = "testsamplebucket12"
  }
}
dependency "vpc" {
  config_path = "${dirname(find_in_parent_folders())}/_env/vpc"
  mock_outputs = {
    vpc_id         = "vpc-123"
    public_subnet_1_id = "pub-subnet-123"
  }
}

inputs = {
  name            = local.global_vars.locals.alb_setting["name"]
  vpc_id          = dependency.vpc.outputs.vpc_id
  subnets         = [dependency.vpc.outputs.public_subnet_1_id]
  create_security_group = local.global_vars.locals.alb_setting["create_security_group"]
  # Security Group
  security_groups = [dependency.sg.outputs.alb_sg]
  access_logs = {
    bucket = dependency.s3_ec2.outputs.s3_bucket_id
  }
  http_tcp_listeners = local.global_vars.locals.alb_setting["http_tcp_listeners"]
  https_listeners    = local.global_vars.locals.alb_setting["https_listeners"]
  tags               = local.global_vars.locals.alb_setting["tags"]
}