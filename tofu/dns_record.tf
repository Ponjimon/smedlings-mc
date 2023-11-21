resource "cloudflare_record" "ssh_app" {
  zone_id = var.cloudflare_zone_id
  name    = "ssh.${var.hostname}"
  value   = "${cloudflare_tunnel.auto_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "webhook_app" {
  zone_id = var.cloudflare_zone_id
  name    = "webhook.${var.hostname}"
  value   = "${cloudflare_tunnel.auto_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "dns_record" {
  zone_id = var.cloudflare_zone_id
  name    = var.hostname
  value   = hcloud_server.instance.ipv4_address
  type    = "A"
}