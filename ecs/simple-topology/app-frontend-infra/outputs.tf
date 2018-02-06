
output "frontend_url" {
  value = "http://${data.terraform_remote_state.shared_state.alb_dns_name}/"
}