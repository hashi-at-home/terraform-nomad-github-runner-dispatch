# Main definition

# Get Cloudflare accounts
data "cloudflare_accounts" "mine" {}
#
# Lookup queue
data "cloudflare_queues" "all" {
  account_id = data.cloudflare_accounts.mine.result[0].id
  # queue_id      = "brucellino-ci-build-queued"
}

# Get Nomad namespaces
data "nomad_namespace" "chardm" {
  name = "CHARDM"
}

# Create dispatch token
#
# Add dispatch token to cloudflare secrets
#
# Create dispatch worker bound to queue and secret
