// terraform {
//   source = "tfr:///terraform-aws-modules/vpc/aws?version=5.8.1"
// }

// terraform {
//     source = "${dirname(find_in_parent_folders())}/local-modules/vpc-test"
// }

// include "root" {
//   path = find_in_parent_folders()
// }

// locals {
//   global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
//   region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"), {})

//   name = local.global_vars.locals.vpc_settings["name"]
//   cidr = local.global_vars.locals.vpc_settings["cidr"]
//   azs = local.global_vars.locals.vpc_settings["azs"]
//   public_subnets = local.global_vars.locals.vpc_settings["public_subnets"]
//   private_subnets = local.global_vars.locals.vpc_settings["private_subnets"]
//   enable_nat_gateway = local.global_vars.locals.vpc_settings["enable_nat_gateway"]
//   enable_vpn_gateway = local.global_vars.locals.vpc_settings["enable_vpn_gateway"]
//   tags = local.global_vars.locals.vpc_settings["tags"]
// }


// inputs = {
//   name = "3108-vpc"
//   cidr = "10.0.0.0/16"

//   azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
//   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
//   public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

//   enable_nat_gateway = true
//   enable_vpn_gateway = false

//   tags = {
//     IAC = "true"
//     Environment = "dev"
//   }
// }

// inputs = {
//     name = local.name
//     cidr = local.cidr

//     azs = local.azs
//     private_subnets = local.private_subnets
//     public_subnets = local.public_subnets


//     enable_nat_gateway = local.enable_nat_gateway
//     enable_vpn_gateway = local.enable_vpn_gateway
//     tags = local.tags
// }

// inputs = {
//     cidr = local.cidr
//     enable_dns_support = local.global_vars.locals.vpc_settings["enable_dns_support"]
//     enable_dns_hostnames = local.global_vars.locals.vpc_settings["enable_dns_hostnames"]
    
//     azs = local.azs

//     public_subnet_cidrs = local.global_vars.locals.vpc_settings["public_subnet_cidrs"]
//     private_subnet_cidrs = local.global_vars.locals.vpc_settings["private_subnet_cidrs"]

//     tags = local.tags
// }

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc.git"
}


## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"), {})
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env          = local.env_vars.locals.environment
  aws_region   = local.region_vars.locals.region

  name         = "${local.global_vars.locals.project_name}-${local.env}"
  cidr         = try(local.global_vars.locals.vpc_settings["cidr"], "10.0.0.0/20")
  azs = local.global_vars.locals.vpc_settings["azs"]
  public_subnets = local.global_vars.locals.vpc_settings["public_subnets"]
  private_subnets = local.global_vars.locals.vpc_settings["private_subnets"]
  database_subnets = local.global_vars.locals.vpc_settings["database_subnets"]
  global_tags  = try(local.global_vars.locals.tags, {})

}

inputs = {
  name = upper(local.name)
  cidr = local.cidr
  azs = local.azs
  // azs  = [for v in dependency.aws-data.outputs.available_aws_availability_zones_names : v]

  // public_subnets = [
  //   "${cidrsubnet(local.cidr, local.cidr_newbits, 0)}",
  //   "${cidrsubnet(local.cidr, local.cidr_newbits, 1)}",
  // ]
  // private_subnets = [
  //   "${cidrsubnet(local.cidr, local.cidr_newbits, 2)}",
  //   "${cidrsubnet(local.cidr, local.cidr_newbits, 3)}",
  // ]

  public_subnets = local.public_subnets
  private_subnets = local.private_subnets
  database_subnets = local.database_subnets


  // database_subnets = [
  //   "${cidrsubnet(local.cidr, local.cidr_newbits, 4)}",
  //   "${cidrsubnet(local.cidr, local.cidr_newbits, 5)}",
  // ]

  enable_nat_gateway       = try(local.global_vars.locals.vpc_settings["${local.env}"]["enable_nat_gateway"], true)
  single_nat_gateway       = try(local.global_vars.locals.vpc_settings["${local.env}"]["single_nat_gateway"], true)
  enable_dns_support       = try(local.global_vars.locals.vpc_settings["${local.env}"]["enable_dns_support"], true)
  enable_dns_hostnames     = try(local.global_vars.locals.vpc_settings["${local.env}"]["enable_dns_hostnames"], true)
  // enable_vpn_gateway       = try(local.global_vars.locals.vpc_settings["${local.env}"]["enable_vpn_gateway"], false)
  map_public_ip_on_launch  = try(local.global_vars.locals.vpc_settings["${local.env}"]["map_public_ip_on_launch"], false)

  tags = merge(
    local.global_tags,
    {
      Env = local.env
    }
  )

}
