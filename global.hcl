locals {
    env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl", "env.hcl"))
    env = local.env_vars.locals.environment
    project_name = "sep-app"

    root_domain = "dinhuy.io.vn"
    domain_names = {
        dev   = "dev.${local.root_domain}"
        stage = "stage.${local.root_domain}"
        prod  = "prod..${local.root_domain}"
    }

    vpc_settings = {
        name = "sepapp-vpc"
        cidr = "10.0.0.0/16"

        azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
        private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
        public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
        public_subnet_cidrs = ["10.0.4.0/24", "10.0.6.0/24"]
        private_subnet_cidrs = ["10.0.10.0/24", "10.0.12.0/24"]

        enable_nat_gateway = true
        enable_vpn_gateway = false

        enable_dns_support = true
        enable_dns_hostnames = true

        tags = {
            Name = "myapp-vpc"
            Environment = "${local.env}"
        }
    }

    ec2_settings = {
        instance_type = "t2.micro"
        key_name = "user1"
        monitoring = true
        
    }

    sg_settings = {
        ec2_cidr_blocks = ["183.91.3.171/32", "113.190.227.88/32", "104.28.160.186/32"]
    }

    cf_settings = {
      s3_rname = "frontend"
      behavior = {
        patterns = [
          # "/api/*",
          "/upload/*",
        ]

        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods  = ["GET", "HEAD"]
        compress        = true
        default_ttl     = 0
        max_ttl         = 0
        min_ttl         = 0
        query_string    = true
        headers         = ["Access-Control-Request-Headers", "Access-Control-Request-Method", "Origin"]
        cookies_forward = "all"

      }

      origin_config = {
        origin_protocol_policy   = "https-only"
        origin_keepalive_timeout = 60
        origin_read_timeout      = 60
      }
      headers             = ["Access-Control-Request-Headers", "Access-Control-Request-Method", "Origin", "Host"]
      cookies_forward     = "all"
      default_root_object = ""
      custom_header_name  = "${upper(local.project_name)}-X-SECURE"
      connection_timeout  = 10

      enable_cached_backend = true
      cached_backend = {
        target_origin_id       = "backend"
        viewer_protocol_policy = "redirect-to-https"

        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods  = ["GET", "HEAD"]
        compress        = true
        default_ttl     = 0
        max_ttl         = 0
        min_ttl         = 0
        query_string    = true
        headers         = ["Access-Control-Request-Headers", "Access-Control-Request-Method", "Origin"]
        cookies_forward = "all"
      }

      prod = {
        alias               = ["${local.root_domain}", "*.${local.root_domain}"]
        price_class         = "PriceClass_All"
        custom_header_value = "${local.project_name}-prod-35Sr52P2kbBx7C6j"
      }
      stage = {
        alias               = ["${local.domain_names["stage"]}", "*.${local.domain_names["stage"]}"]
        price_class         = "PriceClass_200"
        custom_header_value = "${local.project_name}-stage-19A2ZSKgvD635TrQ"
      }
      dev = {
        alias               = ["${lower(local.domain_names["dev"])}", "*.${lower(local.domain_names["dev"])}"]
        price_class         = "PriceClass_200"
        custom_header_value = "${local.project_name}-dev-IDNLD3s7d5HHJ22S"
      }

      dns_alias_enabled = false
    }

    database_setting = {
      name = "t${local.project_name}-${local.env}-db"
      engine         = "aurora-mysql"
      master_username = "admin"
      master_password = "password"
      # vpc_id               = local.vpc_id
      create_db_subnet_group = true
      db_subnet_group_name = "t${local.project_name}-${local.env}-subnet-group"
      # subnets = local.db_subnet_group
      create_security_group = false
      storage_encrypted   = true
      apply_immediately   = true

      prod = {
        engine_version = "8.0"
        instance_class = "db.t3.medium"
        instances = {
            write-instance = {}
            read-instance = {}
        }
        create_cloudwatch_log_group = true
        storage_encrypted   = true
        monitoring_interval = 10

        enabled_cloudwatch_logs_exports = ["general"]
      }

      stage = {
        engine_version = "8.0"
        instance_class = "db.t3.medium"

        instances = {
            instance = {}
        }
        create_cloudwatch_log_group = false
        storage_encrypted   = false
        monitoring_interval = 10

        enabled_cloudwatch_logs_exports = ["general"]
      }

      dev = {
        engine_version = "8.0"
        instance_class = "db.t3.medium"

        instances = {
            instance = {}
        }
        create_cloudwatch_log_group = false
        storage_encrypted   = false
        monitoring_interval = 10
        enabled_cloudwatch_logs_exports = ["general"]
      }
      tags = {
        Environment = "${local.env}"
        Terraform   = "true"
        Project = "${local.project_name}"
      }
    }

    alb_setting = {
        name    = "${local.project_name}-${local.env}-alb"
        # vpc_id  = "${local.vpc_id}"
        # subnets = ["${local.subnets}"]
        create_security_group = false
        http_tcp_listeners = [
          {
            port               = 80
            protocol           = "HTTP"
            target_group_index = 0

            action_type = "redirect"
            redirect = {
              host        = "#{host}"
              port        = "443"
              protocol    = "HTTPS"
              status_code = "HTTP_301"
              path        = "/#{path}"
              query       = "#{query}"
            }
          }
        ]
        https_listeners = [
          {
            port            = 443
            protocol        = "HTTPS"
            certificate_arn = "arn:aws:acm:ap-northeast-1:851725533811:certificate/cb74e117-1b73-45e4-a6e3-156a3ca96205"
            action_type     = "fixed-response"
            fixed_response = {
              content_type = "text/html"
              message_body = "Access denied"
              status_code  = "403"
            }
          }
        ]

    }


    ecs_settings = {
        launch_type                        = "FARGATE"
        propagate_tags                     = "SERVICE"
        deployment_minimum_healthy_percent = 100
        ignore_changes_task_definition     = false
        assign_public_ip                   = true

        cpu = 512
        memory_reservation = 512
        memory = 512
        target_cpu = 128
        target_mem = 128
        scale_in_cooldown = 300
        scale_out_cooldown = 60 

        assign_public_ip = true
        port = 80

        min_capacity = 1
        max_capacity = 3
        desired_count = 1
    }


}