resource "github_actions_secret" "cf_access_service_token_client_id" {
  repository      = var.repository_name
  secret_name     = "CF_ACCESS_SERVICE_TOKEN_ID"
  plaintext_value = cloudflare_access_service_token.ci.id
}

resource "github_actions_secret" "cf_access_service_token_secret" {
  repository      = var.repository_name
  secret_name     = "CF_ACCESS_SERVICE_TOKEN_SECRET"
  plaintext_value = cloudflare_access_service_token.ci.client_secret
}

resource "github_actions_secret" "debug_test" {
  repository      = var.repository_name
  secret_name     = "DEBUG_TEST"
  plaintext_value = "debug test"
}