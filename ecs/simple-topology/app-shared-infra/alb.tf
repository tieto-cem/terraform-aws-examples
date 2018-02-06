#-------------
#    ALB
#-------------

module "alb_sg" {
  source      = "github.com/tieto-cem/terraform-aws-sg?ref=v0.1.0"
  name        = "${local.app_env_name}-alb-sg"
  vpc_id      = "${module.vpc.id}"
  allow_cidrs = {
    "80"  = ["0.0.0.0/0"]
    "443" = ["0.0.0.0/0"]
  }
}

module "alb" {
  source                         = "github.com/tieto-cem/terraform-aws-alb?ref=v0.1.2"
  name                           = "${local.app_env_name}"
  lb_internal                    = false
  lb_subnet_ids                  = "${module.vpc.public_subnet_ids}"
  lb_security_group_ids          = ["${module.alb_sg.id}"]
  tg_vpc_id                      = "${module.vpc.id}"
  http_listener_enabled          = true
  https_listener_enabled         = true
  https_listener_certificate_arn = "${aws_iam_server_certificate.iam_certificate.arn}"
}


#-------------------
#  TLS Certificate
#-------------------

# Self-signed certificate

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "tls_certificate" {
  key_algorithm         = "${tls_private_key.private_key.algorithm}"
  private_key_pem       = "${tls_private_key.private_key.private_key_pem}"

  subject {
    common_name  = "myapp.org"
    organization = "My Org"
  }

  validity_period_hours = "${24 * 365 * 2}"

  allowed_uses          = ["key_encipherment", "digital_signature", "server_auth"]
}

resource "aws_iam_server_certificate" "iam_certificate" {
  name             = "${local.app_env_name}-alb-certificate"
  certificate_body = "${tls_self_signed_cert.tls_certificate.cert_pem}"
  private_key      = "${tls_private_key.private_key.private_key_pem}"
}
