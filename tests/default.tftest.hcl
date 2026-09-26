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
}
