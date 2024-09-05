terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-ecs.git?ref=v4.1.3"
}

## Dependencies:

// dependency "vpc" {
//   config_path = "${dirname(find_in_parent_folders())}/_env/vpc"
//   mock_outputs = {
//     vpc_id          = "vpc-123"
//     public_subnet_1_id = "subnet-123"
//     public_subnet_2_id = "subnet-123"
//   }
// }

## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env          = local.env_vars.locals.environment
  project_name = local.global_vars.locals.project_name
  domain_name  = lookup(local.global_vars.locals.domain_names, local.env)
  name = lower("${local.env}-${local.project_name}-${basename(get_terragrunt_dir())}")
//   public_subnet_1_id = dependency.vpc.outputs.public_subnet_1_id
//   public_subnet_2_id = dependency.vpc.outputs.public_subnet_2_id

  tags = {
    Name = "${local.name}"
    Env = "${local.env}"
  }
}

inputs = {
    cluster_name = "nginx-demo-cluster"
    cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  services = {
    nginxdemos-1 = {
      cpu    = 512
      memory = 1024

      # Container definition(s)
      container_definitions = {


        ecs-sample = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "nginxdemos/hello"
          port_mappings = [
            {
              name          = "ecs-sample"
              containerPort = 80
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false


          enable_cloudwatch_logging = false
          log_configuration = {
            logDriver = "awsfirelens"
            options = {
              Name                    = "firehose"
              region                  = "ap-southeast-1"
              delivery_stream         = "my-stream"
              log-driver-buffer-limit = "2097152"
            }
          }
          memory_reservation = 100
        }
      }

      service_connect_configuration = {
        namespace = "example"
        service = {
          client_alias = {
            port     = 80
            dns_name = "ecs-sample"
          }
          port_name      = "ecs-sample"
          discovery_name = "ecs-sample"
        }
      }

    //   load_balancer = {
    //     service = {
    //       target_group_arn = "arn:aws:elasticloadbalancing:eu-west-1:1234567890:targetgroup/bluegreentarget1/209a844cd01825a4"
    //       container_name   = "ecs-sample"
    //       container_port   = 80
    //     }
    //   }

    //   subnet_ids = [local.public_subnet_1_id, local.public_subnet_2_id]
      subnet_ids = ["subnet-03da1aa0fca5bce32", "subnet-0c59d7dedbe06d0ed"]

      security_group_rules = {
        alb_ingress_3000 = {
          type                     = "ingress"
          from_port                = 80
          to_port                  = 80
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = "sg-12345678"
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  tags = local.tags 

  
}
