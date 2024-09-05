terraform {
    source = "${dirname(find_in_parent_folders())}/local-modules/sg"
}


dependency "vpc" {
  config_path = "${dirname(find_in_parent_folders())}/_env/vpc-test"
  mock_outputs = {
    vpc_id = "vpc-1234"
  }
}

locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
}

inputs = {
    cidr_blocks = local.global_vars.locals.sg_settings["ec2_cidr_blocks"]
    vpc_id = dependency.vpc.outputs.vpc_id
    
}