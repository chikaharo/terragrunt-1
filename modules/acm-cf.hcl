terraform {
    source = "github.com/terraform-aws-modules/terraform-aws-acm.git//.?ref=v4.3.2"
}

dependency "route53" {
    config_path = "${dirname(find_in_parent_folders())}/_env/route53"
    mock_outputs = {
        route53_zone_zone_id = "zone-123456"
    }
}

locals {
    global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
    env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
    env         = local.env_vars.locals.environment
    domain_name = "${lookup(local.global_vars.locals.domain_names, local.env)}"
    root_domain = local.global_vars.locals.root_domain
    tags = {
        Project = "${local.global_vars.locals.project_name}"
        Name = "${local.domain_name}"
        Env = "${local.env}"
    }
}

inputs = {
    domain_name  = local.domain_name
    zone_id      = try(dependency.route53.outputs.route53_zone_zone_id["${local.domain_name}"], "")

    validation_method = "DNS"
    validate_certificate   = true


    subject_alternative_names = [
    "*.${local.domain_name}",
    ]

    create_route53_records = true

    wait_for_validation = false
    tags = local.tags
    validation_allow_overwrite_records = false
}