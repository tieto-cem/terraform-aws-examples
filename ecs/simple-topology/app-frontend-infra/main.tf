provider "aws" {
  region = "eu-west-1"
}

locals {
  env = "${terraform.workspace}"
}

#-----------------------
#  ESC Task Definition
#-----------------------

module "container_definition" {
  source         = "github.com/tieto-cem/terraform-aws-ecs-task-definition//modules/container-definition?ref=v0.1.1"
  name           = "${var.container_name}"
  image          = "${var.container_image}"
  mem_soft_limit = "${var.container_mem_soft_limit}"
  port_mappings  = [{
    containerPort = "${var.container_port}"
  }]
  environment    = [{
    name = "API_ENDPOINT", value = "http://${data.terraform_remote_state.shared_state.alb_dns_name}/api/"
  }]
}

module "task_definition" {
  source                = "github.com/tieto-cem/terraform-aws-ecs-task-definition?ref=v0.1.1"
  name                  = "${var.container_name}-${local.env}-task"
  container_definitions = ["${module.container_definition.json}"]
}


#------------------
#  ECS Service
#------------------

module "service" {
  source              = "github.com/tieto-cem/terraform-aws-ecs-service?ref=v0.1.0"
  name                = "${var.container_name}-${local.env}-service"
  cluster_name        = "${data.terraform_remote_state.shared_state.cluster_name}"
  task_definition_arn = "${module.task_definition.arn}"
  desired_count       = 1
  use_load_balancer   = true
  lb_target_group_arn = "${data.terraform_remote_state.shared_state.alb_default_target_group_arn}"
  lb_container_name   = "${var.container_name}"
  lb_container_port   = "${var.container_port}"
}
