
variable "application_name" {
  description = "Name of the application"
}

variable "parent_state_name" {
  description = "Name of the parent / shared Terraform state. This state doesn't reference to any other Terraform state"
}

variable "child_state_names" {
  description = "List of child state names that reference parent state file"
  type = "list"
}
