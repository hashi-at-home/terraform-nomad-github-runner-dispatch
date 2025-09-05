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
resource "cloudflare_worker" "runner_dispatch" {
  account_id = data.cloudflare_accounts.mine.result[0].id
  name       = "nomad-github-runner-dispatch"
  logpush    = true
  observability = {
    enabled            = true
    head_sampling_rate = 1
    logs = {
      enabled            = true
      head_sampling_rate = 1
      invocation_logs    = true
    }

    subdomain = {
      enabled          = false
      previews_enabled = false
    }
  }
}
