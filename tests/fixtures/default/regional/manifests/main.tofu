# Required Providers
# https://opentofu.org/docs/language/providers/requirements

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# Kubernetes Datadog Operator
# https://github.com/osinfra-io/pt-arche-kubernetes-datadog-operator

module "test_manifests" {
  source = "../../../../../regional/manifests"

  api_key        = "mock"
  app_key        = "mock"
  cluster_prefix = "mock"

  enable_apm                 = true
  enable_apm_instrumentation = true

  node_agent_container_resources = {
    agent = {
      limits = {
        cpu    = "500m"
        memory = "512Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "256Mi"
      }
    }

    "system-probe" = {
      limits = {
        cpu    = "500m"
        memory = "768Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "640Mi"
      }
    }
  }

  node_agent_tolerations = [
    {
      effect   = "NoExecute"
      key      = "dedicated"
      operator = "Equal"
      value    = "mock"
    }
  ]

  registry = "mock-docker.pkg.dev/mock-project/mock-virtual"
  team     = "mock-team"
}
