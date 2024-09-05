terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-rds"
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
  config_path = "${dirname(find_in_parent_folders())}/_env/vpc-test"
  mock_outputs = {
    vpc_id          = "vpc-123"
    private_subnets = ["priv-subnet-1"]
    database_subnets = ["data-subnet-1", "data-subnet-2"]
  }
}

inputs = {
  identifier = "demodb"

  engine            = "mysql"
  engine_version    = "8.0.39"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = "demodb"
  username = "admin"
  password = "d123456"
  port     = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [dependency.sg.outputs.rds_sg.id]

//   maintenance_window = "Mon:00:00-Mon:03:00"
//   backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
//   monitoring_interval    = "30"
//   monitoring_role_name   = "MyRDSMonitoringRole"
//   create_monitoring_role = true

  tags = {
    Name       = local.name
    Environment = local.env
  }

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name = dependency.vpc.outputs.database_subnet_group_name
  subnet_ids             = dependency.vpc.outputs.private_subnets


  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  # Database Deletion Protection
  deletion_protection = false

//   parameters = [
//     {
//       name  = "character_set_client"
//       value = "utf8mb4"
//     },
//     {
//       name  = "character_set_server"
//       value = "utf8mb4"
//     }
//   ]

//   options = [
//     {
//       option_name = "MARIADB_AUDIT_PLUGIN"

//       option_settings = [
//         {
//           name  = "SERVER_AUDIT_EVENTS"
//           value = "CONNECT"
//         },
//         {
//           name  = "SERVER_AUDIT_FILE_ROTATIONS"
//           value = "37"
//         },
//       ]
//     },
//   ]
}