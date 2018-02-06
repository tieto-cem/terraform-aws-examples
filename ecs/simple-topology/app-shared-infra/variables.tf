variable "application_name" {}

variable "instance_type" {}

variable "ecs_optimized_ami" {}

variable "cluster_desired_size" {}

variable "azs" {
  type = "list"
}

variable "vpc_cidr" {
  type = "map"
}

variable "vpc_public_subnets" {
  type = "map"
}

variable "vpc_private_subnets" {
  type = "map"
}

variable "single_nat_gateway" {
  type = "map"
}
