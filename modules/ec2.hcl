terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance"
}

locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env = local.env_vars.locals.environment
  project_name = local.global_vars.locals.project_name
}

dependency "sg" {
  config_path = "${dirname(find_in_parent_folders())}/_env/sg"
  mock_outputs = {
    ec2_sg = "sg-1234"
  }
}

dependency "key_pair"{
  config_path = "${dirname(find_in_parent_folders())}/_env/key_pair"
  mock_outputs = {
    key_pair = "hblab-test"
  }
}

dependency "vpc" {
  config_path = "${dirname(find_in_parent_folders())}/_env/vpc-test"
  mock_outputs = {
    public_subnets = ["pub-subnet-1", "pub-subnet-2"]
    // public_subnet1_id = "subnet-1213"
  }
}

inputs = {
  name =  lower("${local.project_name}-${local.env}-bastion")

  // instance_type          = try(local.global_vars.locals.ec2_settings["${local.env}"]["instance_type"], "t3.micro")
  instance_type          = local.global_vars.locals.ec2_settings["instance_type"]
  key_name               = dependency.key_pair.outputs.key_pair
  // monitoring             = try(local.global_vars.locals.ec2_settings["${local.env}"]["monitoring"], true)
  monitoring             = local.global_vars.locals.ec2_settings["monitoring"]
  // iam_instance_profile  = dependency.iam_role.outputs.ec2_role
  vpc_security_group_ids = [dependency.sg.outputs.ec2_sg.id]
  // subnet_id              = "subnet-049fed8e8a28fe330"
  subnet_id              = dependency.vpc.outputs.public_subnets[0]
  associate_public_ip_address = true

  tags = {
    Name = "${local.env}-${local.project_name}-bastion"
    Environment = "${local.env}"
  }
}
