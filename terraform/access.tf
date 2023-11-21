data "cloudflare_access_identity_provider" "discord" {
  name       = "Discord"
  account_id = var.cloudflare_account_id
}

resource "cloudflare_access_application" "ssh_app" {
  type                      = "ssh"
  zone_id                   = var.cloudflare_zone_id
  name                      = "Access protection for ssh.${var.hostname}"
  domain                    = "ssh.${var.hostname}"
  session_duration          = "1h"
  skip_interstitial         = true
  allowed_idps              = [data.cloudflare_access_identity_provider.discord.id]
  auto_redirect_to_identity = true
}

resource "cloudflare_access_application" "webhook_app" {
  type                      = "self_hosted"
  zone_id                   = var.cloudflare_zone_id
  name                      = "Access protection for webhook.${var.hostname}"
  domain                    = "webhook.${var.hostname}"
  session_duration          = "1h"
  skip_interstitial         = true
  allowed_idps              = [data.cloudflare_access_identity_provider.discord.id]
  auto_redirect_to_identity = true
}

resource "cloudflare_access_policy" "ssh_policy" {
  application_id = cloudflare_access_application.ssh_app.id
  zone_id        = var.cloudflare_zone_id
  name           = "Policy for ssh.${var.hostname}"
  precedence     = "1"
  decision       = "allow"

  include {
    group = [var.cloudflare_access_group_id]
  }
}

resource "cloudflare_access_policy" "policy_service_token" {
  application_id = cloudflare_access_application.ssh_app.id
  zone_id        = var.cloudflare_zone_id
  name           = "Service Token Policy for ssh.${var.hostname}"
  precedence     = "2"
  decision       = "non_identity"

  include {
    service_token = [var.cloudflare_service_token_id]
  }
}

resource "cloudflare_access_policy" "webhook_policy" {
  application_id = cloudflare_access_application.webhook_app.id
  zone_id        = var.cloudflare_zone_id
  name           = "Policy for webhook.${var.hostname}"
  precedence     = "1"
  decision       = "allow"

  include {
    group = [var.cloudflare_access_group_id]
  }
}

resource "cloudflare_access_policy" "policy_service_token_webhook" {
  application_id = cloudflare_access_application.webhook_app.id
  zone_id        = var.cloudflare_zone_id
  name           = "Service Token Policy for webhook.${var.hostname}"
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