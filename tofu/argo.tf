resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_tunnel" "auto_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "zero_trust_ssh_http"
  secret     = random_id.tunnel_secret.b64_std
}