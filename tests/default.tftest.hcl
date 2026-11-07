# Test
# https://opentofu.org/docs/cli/commands/test

# Mock Providers
# https://opentofu.org/docs/cli/commands/test/#the-mock_provider-blocks

mock_provider "kubernetes" {}
mock_provider "helm" {}

run "default_regional" {
  command = apply

  module {
    source = "./tests/fixtures/default/regional"
  }
}

run "operator_unified_tags" {
  command = plan

  module {
    source = "./regional"
  }

  override_module {
    target = module.core_helpers
    outputs = {
      env         = "prod"
      environment = "production"
      region      = "us-east1"
      zone        = "b"
    }
  }

  variables {
    api_key        = "mock"
    app_key        = "mock"
    cluster_prefix = "mock"
  }

  assert {
    condition = yamldecode(helm_release.datadog_operator.values[1]).podLabels == {
      "tags.datadoghq.com/env"     = "production"
      "tags.datadoghq.com/service" = "datadog-operator"
      "tags.datadoghq.com/version" = var.operator_version
    }
    error_message = "Datadog operator pod templates must carry all unified service tags together."
  }
}

run "default_manifests" {
  command = apply

  module {
    source = "./tests/fixtures/default/regional/manifests"
  }

  assert {
    condition = alltrue([
      output.node_agent_container_resources["agent"].requests.cpu == "100m",
      output.node_agent_container_resources["agent"].limits.memory == "512Mi",
      output.node_agent_container_resources["process-agent"].limits.memory == "128Mi",
      !contains(keys(output.node_agent_container_resources["process-agent"]), "requests"),
      output.node_agent_container_resources["system-probe"].requests.memory == "640Mi",
      !contains(keys(output.node_agent_container_resources["system-probe"]), "limits")
    ])
    error_message = "Node Agent resource overrides must support complete and one-sided resource configurations."
  }

  assert {
    condition = output.prometheus_scrape_enabled && alltrue([
      !contains(keys(output.node_agent_extra_confd_config_data), "ztunnel.yaml"),
      !contains(keys(yamldecode(output.node_agent_extra_confd_config_data["envoy.yaml"])), "logs"),
      strcontains(output.node_agent_extra_confd_config_data["gatekeeper.yaml"], "- gatekeeper"),
      strcontains(output.node_agent_extra_confd_config_data["gatekeeper.yaml"], "gatekeeper_health_endpoint: http://%%host%%:9090"),
      strcontains(output.node_agent_extra_confd_config_data["gatekeeper.yaml"], "prometheus_url: http://%%host%%:8888/metrics")
    ])
    error_message = "Prometheus scraping and Gatekeeper health and metrics endpoints must be configured without conflicting Istio log configurations."
  }
}

run "monitor_thresholds" {
  command = plan

  module {
    source = "./regional/manifests"
  }

  override_module {
    target = module.core_helpers
    outputs = {
      env         = "prod"
      environment = "production"
      region      = "us-east1"
      zone        = "b"
    }
  }

  variables {
    api_key        = "mock"
    app_key        = "mock"
    cluster_prefix = "mock"
    registry       = "mock-docker.pkg.dev/mock-project/mock-virtual"
    team           = "mock-team"
  }

  assert {
    condition     = kubernetes_manifest.agent.manifest.spec.override.nodeAgent.containers.agent.logLevel == "warn"
    error_message = "The Node Agent must default to warning-level logging."
  }

  assert {
    condition = (
      contains(kubernetes_manifest.agent.manifest.spec.global.tags, "env:production") &&
      kubernetes_manifest.agent.manifest.spec.override.nodeAgent.labels["tags.datadoghq.com/env"] == "production" &&
      kubernetes_manifest.agent.manifest.spec.override.clusterAgent.labels["tags.datadoghq.com/env"] == "production"
    )
    error_message = "Agent global tags and both Agent pod templates must use the same full core-helper environment."
  }

  assert {
    condition = alltrue([
      for name in ["crash-loop-backoff", "failing-deployment-replicas", "failing-statefulset-replicas", "image-pull-backoff"] :
      !contains(keys(kubernetes_manifest.kubernetes_monitor_templates[name].manifest.spec.options.thresholds), "warning")
    ])
    error_message = "Monitors without warning alerts must omit the warning threshold rather than send null to Kubernetes."
  }

  assert {
    condition = alltrue([
      for name, monitor in kubernetes_manifest.kubernetes_monitor_templates :
      monitor.manifest.spec.options.thresholds.critical == local.kubernetes_monitor_templates[name].thresholds_critical &&
      (
        local.kubernetes_monitor_templates[name].thresholds_warning == null ||
        try(monitor.manifest.spec.options.thresholds.warning == local.kubernetes_monitor_templates[name].thresholds_warning, false)
      )
    ])
    error_message = "Configured critical and warning thresholds must remain unchanged."
  }
}
