resource "random_password" "unix_password" {
  length  = 16
  special = true
}

resource "hcloud_server" "instance" {
  name        = var.hostname
  server_type = var.server_type
  image       = var.image
  location    = var.location
  user_data = templatefile("./server.tpl",
    {
      hostname      = var.hostname,
      account       = var.cloudflare_account_id,
      email         = var.cloudflare_email,
      webhook_url   = var.webhook_url,
      unix_password = random_password.unix_password.result,
      tunnel_id     = cloudflare_tunnel.auto_tunnel.id,
      tunnel_name   = cloudflare_tunnel.auto_tunnel.name,
      secret        = random_id.tunnel_secret.b64_std
      ssh_ca_cert   = cloudflare_access_ca_certificate.ssh_short_lived.public_key
  })
}