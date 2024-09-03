terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-cloudfront.git//.?ref=v3.2.1"
}

dependency "ssl" {
  config_path = "${dirname(find_in_parent_folders())}/_env/acm-cf"
  mock_outputs = {
    acm_certificate_arn = "acm::1235"
  }
}

dependency "bucket" {
  config_path = "${dirname(find_in_parent_folders())}/_env/s3"
  mock_outputs = {
    s3_bucket_id = "bucket::1235"
  }
}

// dependency "ssl" {
//     config_path = "${dirname(find_in_parent_folders())}/_env/acm-cf"
// }

// dependency "lambda" {
//   config_path = "${dirname(find_in_parent_folders())}/_env/lambda"
//   mock_outputs = {
//     lambda_function_qualified_arn = "lambda::1235"
//   }
// }

# dependency "loadbalancer" {
#   config_path = "${dirname(find_in_parent_folders())}/_env/alb"
#   mock_outputs = {
#     lb_dns_name = "lb::1235"
#   }
# }

# dependency "waf" {
#   config_path = "${dirname(find_in_parent_folders())}/_env/waf"
#   mock_outputs = {
#     web_acl_arn = "waf::1235"
#   }
# }


## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env          = local.env_vars.locals.environment
  project_name = local.global_vars.locals.project_name
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region = local.region_vars.locals.region
  root_domain = local.global_vars.locals.root_domain                                                                                        
  s3_rname    = try(local.global_vars.locals.cf_settings["s3_rname"], "frontend")
  s3_patterns = try(local.global_vars.locals.cf_settings["behavior"]["patterns"], ["/api_test/*"])

  enable_cached_backend = try(local.global_vars.locals.cf_settings["enable_cached_backend"], true)
  cached_backend        = try(local.global_vars.locals.cf_settings["cached_backend"], {})

  tags = {
      Name = lower("${local.project_name}-${local.env}-cdn")
      Env  = local.env
    }
}

inputs = {
  aliases = ["${local.project_name}.${local.root_domain}", "*.${local.project_name}.${local.root_domain}"]
  
  # web_acl_id = dependency.waf.outputs.web_acl_arn
  comment             = "CDN of dev-${local.project_name}"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = true
  
  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "Cloudfront ${local.project_name} can access"
  }

  origin = {
    s3_one = {
      domain_name = "${dependency.bucket.outputs.s3_bucket_id}.s3.${local.region}.amazonaws.com"
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
      }
    }
   
  }

  default_cache_behavior = {
    target_origin_id       = "s3_one"
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
    // lambda_function_association = {
    //   viewer-request = {
    //     lambda_arn = dependency.lambda.outputs.lambda_function_qualified_arn
    //   }
      # origin-request = {
      #   lambda_arn = var.lambda_request
      # }
    // }
  }



  default_root_object = "index.html"

  custom_error_response = [
    {
      error_code            = "403"
      response_code         = "403"
      response_page_path    = "/index.html"
      error_caching_min_ttl = "300"
    },
    {
      error_code            = "404"
      response_code         = "404"
      response_page_path    = "/index.html"
      error_caching_min_ttl = "300"
    }
  ]

    viewer_certificate = {
        acm_certificate_arn = "arn:aws:acm:us-east-1:117001856078:certificate/a2a7dc42-df84-4cf1-89e9-7a0a714b77ae"
        minimum_protocol_version = "TLSv1"
        ssl_support_method  = "sni-only"
    }

  origin_bucket = dependency.bucket.outputs.s3_bucket_id
  aws_region    = dependency.bucket.outputs.s3_bucket_region


  tags = {
    Name = "${local.project_name}"
    Env = "${local.env}"
  }
}
