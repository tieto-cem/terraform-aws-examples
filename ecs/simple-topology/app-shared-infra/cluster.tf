#---------------
#  ECS Cluster
#---------------

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${local.app_env_name}"
}

# Security Group for cluster instances

resource "aws_security_group" "ecs_cluster_sg" {
  name   = "${local.app_env_name}-cluster-sg"
  vpc_id = "${module.vpc.id}"

  ingress {
    from_port       = 32768
    to_port         = 60999
    protocol        = "tcp"
    security_groups = ["${module.alb_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${local.app_env_name}-cluster-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Container instances to be associated with the ECS cluster

module "cluster_instances" {
  source                  = "github.com/tieto-cem/terraform-aws-ecs-container-instance?ref=v0.1.3"
  name                    = "${local.app_env_name}"
  ecs_cluster_name        = "${aws_ecs_cluster.ecs_cluster.name}"
  lc_instance_type        = "${var.instance_type}"
  lc_security_group_ids   = ["${aws_security_group.ecs_cluster_sg.id}"]
  lc_ecs_optimized_ami_id = "${var.ecs_optimized_ami}"
  asg_subnet_ids          = "${module.vpc.private_subnet_ids}"
  asg_desired_size        = "${var.cluster_desired_size}"

}
