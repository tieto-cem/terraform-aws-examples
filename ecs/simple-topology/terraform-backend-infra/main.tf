provider "aws" {
  region = "eu-west-1"
}

locals {
  backends_to_configure = "${concat(list(var.parent_state_name), var.child_state_names)}"
}

#-----------------------------------------------------------------------
# This creates backend resources for storing Terraform state files etc.
#-----------------------------------------------------------------------

module "terraform_s3_backend" {
  source                          = "github.com/tieto-cem/terraform-aws-s3-backend?ref=v0.1.5"
  state_bucket_name_prefix        = "${var.application_name}-tf-state"
  state_lock_table_name           = "${var.application_name}-tf-state-locks"
  state_bucket_versioning_enabled = false        # just to ease example cleanup, don't do this in real projects
  state_bucket_force_destroy      = true         # just to ease example cleanup, don't do this in real projects
}

#-----------------------------------------------------------------
#  This generates a configuration file which children use to access parent state.
#-----------------------------------------------------------------

data "template_file" "parent_state_reference_template" {
  template = "${file("templates/parent_state_reference.tpl")}"
  vars {
    state_bucket_name = "${module.terraform_s3_backend.state_bucket_name}"
    parent_state_key  = "${var.parent_state_name}"
  }
}

resource "local_file" "parent_state_reference" {
  filename = "configurations/${var.parent_state_name}-state-ref.tf"
  content  = "${data.template_file.parent_state_reference_template.rendered}"
}

#-----------------------------------------------------------------------------
#  This generates backend configuration file for the parent and the children
#-----------------------------------------------------------------------------

data "template_file" "backend_configuration_template" {
  count    = "${length(local.backends_to_configure)}"
  template = "${file("templates/backend_configuration.tpl")}"
  vars {
    state_bucket_name     = "${module.terraform_s3_backend.state_bucket_name}"
    state_lock_table_name = "${module.terraform_s3_backend.lock_table_name}"
    state_key             = "${local.backends_to_configure[count.index]}"
  }
}

resource "local_file" "backend_configurations" {
  count    = "${length(local.backends_to_configure)}"
  filename = "configurations/${element(local.backends_to_configure, count.index)}-state.tf"
  content  = "${data.template_file.backend_configuration_template.*.rendered[count.index]}"
}

