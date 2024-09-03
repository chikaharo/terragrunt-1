// terraform {
//   source = "tfr:///terraform-aws-modules/vpc/aws?version=5.8.1"
// }

terraform {
    source = "${dirname(find_in_parent_folders())}/local-modules/vpc"
}

// include "root" {
//   path = find_in_parent_folders()
// }

locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"), {})

  name = local.global_vars.locals.vpc_settings["name"]
  cidr = local.global_vars.locals.vpc_settings["cidr"]
  azs = local.global_vars.locals.vpc_settings["azs"]
  public_subnets = local.global_vars.locals.vpc_settings["public_subnets"]
  private_subnets = local.global_vars.locals.vpc_settings["private_subnets"]
  enable_nat_gateway = local.global_vars.locals.vpc_settings["enable_nat_gateway"]
  enable_vpn_gateway = local.global_vars.locals.vpc_settings["enable_vpn_gateway"]
  tags = local.global_vars.locals.vpc_settings["tags"]
}


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

inputs = {
    cidr = local.cidr
    enable_dns_support = local.global_vars.locals.vpc_settings["enable_dns_support"]
    enable_dns_hostnames = local.global_vars.locals.vpc_settings["enable_dns_hostnames"]
    
    azs = local.azs

    public_subnet_cidrs = local.global_vars.locals.vpc_settings["public_subnet_cidrs"]
    private_subnet_cidrs = local.global_vars.locals.vpc_settings["private_subnet_cidrs"]

    tags = local.tags
}