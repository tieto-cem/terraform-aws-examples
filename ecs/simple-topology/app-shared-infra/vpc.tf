#--------
#  VPC
#--------

module "vpc" {
  source               = "github.com/tieto-cem/terraform-aws-vpc?ref=v0.1.1"
  name_prefix          = "${local.app_env_name}"
  cidr                 = "${lookup(var.vpc_cidr, local.env)}"
  azs                  = "${var.azs}"
  private_subnet_cidrs = "${var.vpc_private_subnets[local.env]}"
  public_subnet_cidrs  = "${var.vpc_public_subnets[local.env]}"
  enable_nat_gateway   = true
  single_nat_gateway   = "${lookup(var.single_nat_gateway, local.env)}"
}
