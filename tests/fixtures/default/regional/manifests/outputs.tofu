# Datadog Node Agent Resources
# https://opentofu.org/docs/language/values/outputs

output "node_agent_container_resources" {
  description = "Resource requests and limits configured for each Node Agent container"
  value       = module.test_manifests.node_agent_container_resources
}

output "node_agent_extra_confd_config_data" {
  description = "Autodiscovery configuration data mounted into the Node Agent"
  value       = module.test_manifests.node_agent_extra_confd_config_data
}

output "prometheus_scrape_enabled" {
  description = "Whether cluster-wide Prometheus annotation autodiscovery is enabled"
  value       = module.test_manifests.prometheus_scrape_enabled
}
