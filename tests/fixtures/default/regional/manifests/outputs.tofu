# Datadog Node Agent Resources
# https://opentofu.org/docs/language/values/outputs

output "node_agent_container_resources" {
  description = "Resource requests and limits configured for each Node Agent container"
  value       = module.test_manifests.node_agent_container_resources
}
