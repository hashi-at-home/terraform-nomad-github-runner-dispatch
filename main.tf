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

locals {
  queue_id = [for queue in data.cloudflare_queues.all.result : queue.queue_name == "brucellino-ci-build-queued" ? queue.queue_id : ""]
}

resource "cloudflare_worker_version" "runner_dispatch" {
  account_id = data.cloudflare_accounts.mine.result[0].id
  worker_id  = cloudflare_worker.runner_dispatch.id
  bindings = [{
    name = "CI_BUILD_QUEUED_Q"
    type = "queue"
    # queue_name = join("", local.queue_id)
    queue_name = "brucellino-ci-build-queued"
  }]
  compatibility_flags = ["nodejs_compat"]
  compatibility_date  = "2025-09-05"
  main_module         = "index.mjs"
  modules = [{
    content_type = "application/javascript+module"
    content_file = "worker-scripts/nomad-github-runner-dispatch/index.mjs"
    name         = "index.mjs"
  }]

}
