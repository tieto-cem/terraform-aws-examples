output "alb_dns_name" {
  value = "${module.alb.alb_dns_name}"
}

output "alb_default_target_group_arn" {
  value = "${module.alb.target_group_arn}"
}

output "alb_https_listener_arn" {
  value = "${module.alb.https_listener_arn}"
}

output "alb_http_listener_arn" {
  value = "${module.alb.http_listener_arn}"
}

output "cluster_name" {
  value = "${aws_ecs_cluster.ecs_cluster.name}"
}

output "vpc_id" {
  value = "${module.vpc.id}"
}
