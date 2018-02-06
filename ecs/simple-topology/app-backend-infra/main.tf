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
  image          = "tapantim/clojure-example-backend"
  mem_soft_limit = "${var.container_mem_soft_limit}"
  port_mappings  = [{
    containerPort = "${var.container_port}"
  }]
}

module "task_definition" {
  source                = "github.com/tieto-cem/terraform-aws-ecs-task-definition?ref=v0.1.1"
  name                  = "${var.container_name}-${local.env}-task"
  container_definitions = ["${module.container_definition.json}"]
}

#----------------------------------------------------
#  Mapping /backend/* to backend container target group
#----------------------------------------------------

// TODO, create a module for mapping listener path to target group

resource "aws_lb_target_group" "backend_target_group" {
  name     = "${var.container_name}-${local.env}-tg"
  vpc_id   = "${data.terraform_remote_state.shared_state.vpc_id}"
  port     = "${var.container_port}"
  protocol = "HTTP"

  health_check {
    interval = 5
    timeout  = 2
    path     = "${var.container_health_check_path}"
  }
}

resource "aws_lb_listener_rule" "api_https_listener_rule" {
  listener_arn = "${data.terraform_remote_state.shared_state.alb_https_listener_arn}"
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.backend_target_group.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/api/*"]
  }
}

resource "aws_lb_listener_rule" "api_http_listener_rule" {
  listener_arn = "${data.terraform_remote_state.shared_state.alb_http_listener_arn}"
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.backend_target_group.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/api/*"]
  }
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
  lb_target_group_arn = "${aws_lb_target_group.backend_target_group.arn}"
  lb_container_name   = "${var.container_name}"
  lb_container_port   = "${var.container_port}"
}
