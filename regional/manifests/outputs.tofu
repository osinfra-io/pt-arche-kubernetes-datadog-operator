# Datadog Node Agent Resources
# https://opentofu.org/docs/language/values/outputs

output "node_agent_container_resources" {
  description = "Resource requests and limits configured for each Node Agent container"
  value = {
    for name, override in local.node_agent_container_overrides :
    name => lookup(override, "resources", null)
  }
}

output "node_agent_extra_confd_config_data" {
  description = "Autodiscovery configuration data mounted into the Node Agent"
  value       = kubernetes_manifest.agent.manifest.spec.override.nodeAgent.extraConfd.configDataMap
}

output "prometheus_scrape_enabled" {
  description = "Whether cluster-wide Prometheus annotation autodiscovery is enabled"
  value       = kubernetes_manifest.agent.manifest.spec.features.prometheusScrape.enabled
}
