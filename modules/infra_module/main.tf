locals {
  cicd_name_prefix = "cicd"
  host_name_prefix = "host"
  cicd_user_data   = templatefile("${path.module}/tpl/cicd_instance_userdata.sh.tpl", {})
}

module "vpc" {
  source             = "../vpc"
  name               = "vpc-${var.env}"
  cidr_block         = var.vpc_cidr_block
  public_subnets     = var.vpc_public_subnets
  private_subnets    = var.vpc_private_subnets
  availability_zones = var.vpc_availability_zones
  enable_nat_gateway = var.vpc_enable_nat_gateway
}

module "cicd_instance" {
  source             = "../ec2_instance"
  env                = var.env
  deployment_account = var.deployment_account
  name_prefix        = local.cicd_name_prefix
  vpc_id             = module.vpc.id
  user_data          = local.cicd_user_data
  instance_subnet_id = module.vpc.public_subnet_ids[0]
}

module "host_instance" {
  source             = "../ec2_instance"
  env                = var.env
  deployment_account = var.deployment_account
  name_prefix        = local.host_name_prefix
  vpc_id             = module.vpc.id
  instance_subnet_id = module.vpc.private_subnets_ids[0]
}

module "load_balancer" {
  source             = "../load_balancer"
  env                = var.env
  deployment_account = var.deployment_account
  vpc_id             = module.vpc.id
  targets = [module.host_instance.instance_id]
  alb_subnets = [module.vpc.public_subnet_ids[0],module.vpc.public_subnet_ids[1]]
}