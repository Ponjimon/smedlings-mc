# DNS settings to CNAME to tunnel target for SSH
resource "cloudflare_record" "ssh_app" {
  zone_id = var.cloudflare_zone_id
  name    = "ssh.${var.hostname}"
  value   = "${cloudflare_tunnel.auto_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

# Create a DNS record for the Minecraft server
resource "cloudflare_record" "dns_record" {
  zone_id = var.cloudflare_zone_id
  name    = var.hostname
  value   = hcloud_server.instance.ipv4_address
  type    = "A"
}