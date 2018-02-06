
terraform {

  backend "s3" {
    bucket                      = "${state_bucket_name}"
    key                         = "${state_key}"
    region                      = "eu-west-1"
    dynamodb_table              = "${state_lock_table_name}"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_get_ec2_platforms      = true
  }
}
