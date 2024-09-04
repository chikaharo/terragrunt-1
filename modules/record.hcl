terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records"
}
dependency "alb" {
  config_path = "${dirname(find_in_parent_folders())}/_env/alb"
  mock_outputs = {
    load_balancers_dns = "lb-1234"
  }
}

dependency "zone"{
  config_path = "${dirname(find_in_parent_folders())}/_env/route53"
  mock_outputs = {
    route53_zone_zone_id = "ADFADFADFA"
  }
}
## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env          = local.env_vars.locals.environment
  project_name = local.global_vars.locals.project_name
  domain_name  = lookup(local.global_vars.locals.domain_names, local.env)
  tags = {
    Name = "${local.domain_name}"
    Env = "${local.env}"
  }
}

inputs = {
    zone_name = keys(dependency.zone.outputs.route53_zone_zone_id)[0]

    records = [
        {
            name    = "api-dev"
            type    = "CNAME"
            ttl     = 300
            records = ["${dependency.alb.outputs.load_balancers_dns}"]
        }
    ]
}