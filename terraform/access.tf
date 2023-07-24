# Access application to apply zero trust policy over SSH endpoint
resource "cloudflare_access_application" "ssh_app" {
  type             = "ssh"
  zone_id          = var.cloudflare_zone_id
  name             = "Access protection for ssh.${var.hostname}"
  domain           = "ssh.${var.hostname}"
  session_duration = "1h"
}

# Access policy that the above appplication uses. (i.e. who is allowed in)
resource "cloudflare_access_policy" "ssh_policy" {
  application_id = cloudflare_access_application.ssh_app.id
  zone_id        = var.cloudflare_zone_id
  name           = "Policy for ssh.${var.hostname}"
  precedence     = "1"
  decision       = "allow"

  include {
    email = [var.cloudflare_email]
  }
}

resource "cloudflare_access_policy" "ssh_policy_service_token" {
  application_id = cloudflare_access_application.ssh_app.id
  zone_id        = var.cloudflare_zone_id
  name           = "Service Token Policy for ssh.${var.hostname}"
  precedence     = "2"
  decision       = "non_identity"

  include {
    service_token = [var.cloudflare_service_token_id]
  }
}

resource "cloudflare_access_ca_certificate" "ssh_short_lived" {
  zone_id        = var.cloudflare_zone_id
  application_id = cloudflare_access_application.ssh_app.id
}