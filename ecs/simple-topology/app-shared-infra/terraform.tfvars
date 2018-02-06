application_name      = "myapp"

instance_type         = "t2.small"

ecs_optimized_ami     = "ami-1d46df64"

cluster_desired_size  = 1

single_nat_gateway    = {
  dev  = true
  test = true
  prod = false
}

azs                   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

# Network calculator: http://jodies.de/ipcalc
# Example VPCs and subnets have 4096

vpc_cidr              = {
  dev  = "10.0.0.0/20"
  test = "10.0.16.0/20"
  prod = "10.0.32.0/20"
}

vpc_public_subnets    = {
  dev  = ["10.0.0.0/23", "10.0.2.0/23", "10.0.4.0/23"]
  test = ["10.0.16.0/23", "10.0.18.0/23", "10.0.20.0/23"]
  prod = ["10.0.32.0/23", "10.0.34.0/23", "10.0.36.0/23"]
}

vpc_private_subnets   = {
  dev  = ["10.0.6.0/23", "10.0.8.0/23", "10.0.10.0/23"]
  test = ["10.0.22.0/23", "10.0.24.0/23", "10.0.26.0/23"]
  prod = ["10.0.38.0/23", "10.0.40.0/23", "10.0.42.0/23"]
}


