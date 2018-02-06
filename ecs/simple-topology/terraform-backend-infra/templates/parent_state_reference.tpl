
data "terraform_remote_state" "${parent_state_key}_state" {
  backend = "s3"
  config {
    bucket = "${state_bucket_name}"
    key    = "env:/$${terraform.workspace}/${parent_state_key}"
    region = "eu-west-1"
  }
}