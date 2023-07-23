resource "random_password" "unix_password" {
  length  = 16
  special = true
}

resource "hcloud_server" "web" {
  name        = var.name
  server_type = var.server_type
  image       = var.image
  location    = var.location
  user_data = templatefile("./server.tpl",
    {
      domain        = var.domain,
      account       = var.cloudflare_account_id,
      email         = var.cloudflare_email,
      unix_password = random_password.unix_password.result,
      tunnel_id     = cloudflare_argo_tunnel.auto_tunnel.id,
      tunnel_name   = cloudflare_argo_tunnel.auto_tunnel.name,
      secret        = random_id.tunnel_secret.b64_std
      ssh_ca_cert   = cloudflare_access_ca_certificate.ssh_short_lived.public_key
  })
}

# DNS settings to CNAME to tunnel target for SSH
resource "cloudflare_record" "ssh_app" {
  zone_id = var.cloudflare_zone_id
  name    = "ssh-${var.domain}"
  value   = "${cloudflare_argo_tunnel.auto_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}