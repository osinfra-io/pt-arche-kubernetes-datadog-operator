# Datadog Node Agent Resources
# https://opentofu.org/docs/language/values/outputs

output "node_agent_container_resources" {
  description = "Resource requests and limits configured for each Node Agent container"
  value = {
    for name, override in local.node_agent_container_overrides :
    name => lookup(override, "resources", null)
  }
}
