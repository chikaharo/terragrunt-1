terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-rds-aurora"
}
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env          = local.env_vars.locals.environment
  name         = basename(dirname("${get_terragrunt_dir()}/../.."))
  project_name = local.global_vars.locals.project_name
}

dependency "sg" {
  config_path = "${dirname(find_in_parent_folders())}/_env/sg"
  mock_outputs = {
    rds_sg = "sg-1234"
  }
}

dependency "vpc" {
  config_path = "${dirname(find_in_parent_folders())}/_env/vpc"
  mock_outputs = {
    vpc_id          = "vpc-123"
    private_subnet_1_id = "subnet-123"
    private_subnet_2_id = "subnet-345"
  }
}

inputs = {
  name                                       = local.global_vars.locals.database_setting["name"]
  engine                                     = local.global_vars.locals.database_setting["engine"]
  master_username                            = local.global_vars.locals.database_setting["master_username"]
  master_password                            = local.global_vars.locals.database_setting["master_password"]
  vpc_id                                     = dependency.vpc.outputs.vpc_id
  // vpc_id                                     = "vpc-0392f0b0fe7e20bb6"
  create_db_subnet_group                     = local.global_vars.locals.database_setting["create_db_subnet_group"]
  db_subnet_group_name                       = local.global_vars.locals.database_setting["db_subnet_group_name"]
  subnets                                    = [dependency.vpc.outputs.private_subnet_1_id, dependency.vpc.outputs.private_subnet_2_id]
  // subnets                                    = ["subnet-004e89ebf3116e4df", "subnet-0b8b03303128d3720"]
  create_security_group                      = local.global_vars.locals.database_setting["create_security_group"]
  apply_immediately                          = local.global_vars.locals.database_setting["apply_immediately"]
  vpc_security_group_ids                     = [dependency.sg.outputs.rds_sg.id]
  // vpc_security_group_ids                     = ["sg-05a6fe480b4a4cc1a"]
  engine_version                             = local.global_vars.locals.database_setting["${local.env}"]["engine_version"]
  instance_class                             = local.global_vars.locals.database_setting["${local.env}"]["instance_class"]
  instances                                  = local.global_vars.locals.database_setting["${local.env}"]["instances"]
  create_cloudwatch_log_group                = local.global_vars.locals.database_setting["${local.env}"]["create_cloudwatch_log_group"]
  storage_encrypted                          = local.global_vars.locals.database_setting["${local.env}"]["storage_encrypted"]
  monitoring_interval                        = local.global_vars.locals.database_setting["${local.env}"]["monitoring_interval"]
  enabled_cloudwatch_logs_exports            = local.global_vars.locals.database_setting["${local.env}"]["enabled_cloudwatch_logs_exports"]
  tags                                       = local.global_vars.locals.database_setting["tags"]
  create_db_cluster_parameter_group          = true
  db_cluster_parameter_group_use_name_prefix = true
  db_cluster_parameter_group_name            = "t${local.global_vars.locals.project_name}-${local.env}-custom-group"
  cluster_parameter_group_name               = "custom-group"
  db_cluster_parameter_group_description     = "Allow Audit of Database activities"
  db_cluster_parameter_group_family          = "aurora-mysql8.0"
  create_db_parameter_group                  = true
  db_parameter_group_name                    = "t${local.global_vars.locals.project_name}-${local.env}-db-custom-group"
  db_parameter_group_family                  = "aurora-mysql8.0"
  db_parameter_group_use_name_prefix = false
  //cluster
  create_db_cluster_parameter_group          = true
  cluster_use_name_prefix                    = false
  db_cluster_parameter_group_use_name_prefix = false
  db_cluster_parameter_group_name            = "t${local.global_vars.locals.project_name}-${local.env}-cluster-custom-group"
  db_cluster_parameter_group_family          = "aurora-mysql8.0"
  db_cluster_parameter_group_description     = "Allow Audit of Database activities"
  db_cluster_parameter_group_parameters      = [
    {
      name         = "server_audit_events"
      value        = "CONNECT,QUERY,TABLE"
      apply_method = "immediate"
    },
    {
      name         = "server_audit_logging"
      value        = 1
      apply_method = "immediate"
    }
  ]
}