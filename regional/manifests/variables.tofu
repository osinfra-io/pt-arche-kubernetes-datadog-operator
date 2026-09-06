# Input Variables
# https://opentofu.org/docs/language/values/variables

variable "api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true
}

variable "app_key" {
  description = "Datadog APP key"
  type        = string
  sensitive   = true
}

variable "cluster_agent_env_vars" {
  description = "Environment variables for the cluster agent"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "cluster_agent_limits_cpu" {
  description = "CPU limits for the Datadog cluster agent"
  type        = string
  default     = "200m"
}

variable "cluster_agent_limits_memory" {
  description = "Memory limits for the Datadog cluster agent"
  type        = string
  default     = "256Mi"
}

variable "cluster_agent_requests_cpu" {
  description = "CPU requests for the Datadog cluster agent"
  type        = string
  default     = "100m"
}

variable "cluster_agent_requests_memory" {
  description = "Memory requests for the Datadog cluster agent"
  type        = string
  default     = "128Mi"
}

variable "cluster_agent_tag" {
  description = "Tag for the Datadog cluster agent image"
  type        = string
  default     = "7.81.1"
}

variable "cluster_prefix" {
  description = "Prefix for your cluster name, region, and zone (if applicable) will be added to the end of the cluster name"
  type        = string
}

variable "enable_apm" {
  description = <<EOF
    Enable Application Performance Monitoring (APM).
    Cost: $31/host/month (annual) with Infrastructure Monitoring; $36/host/month standalone.
    On-demand: $48/host/month with Infra, $36 standalone.
    Includes Universal Service Monitoring (USM) on the same host at no additional cost.
    Allotments: 150 GB ingested spans and 1M indexed spans per APM host per month.
    EOF
  type        = bool
  default     = false
}

variable "enable_apm_instrumentation" {
  description = "Enable Application Performance Monitoring (APM) Single-Step instrumentation. No additional cost beyond the APM license; requires enable_apm = true."
  type        = bool
  default     = false
}

variable "enable_usm" {
  description = <<EOF
    Enable Universal Service Monitoring (USM) — automatic service discovery and RED metrics via eBPF, no code changes required.
    Cost: $9/host/month (annual); $13/host/month on-demand. Requires Infrastructure Monitoring.
    Free on hosts where APM is already purchased (APM includes USM at no additional cost).
    EOF
  type        = bool
  default     = true
}

variable "node_agent_env_dd_container_exclude" {
  description = "Environment variable for the Datadog node agent to exclude containers"
  type        = string
  default     = ""
}

variable "node_agent_env_dd_ignore_auto_conf" {
  description = "Environment variable for the Datadog node agent to ignore auto configuration"
  type        = string
  default     = ""
}

variable "node_agent_image" {
  description = "Image for the Datadog node agent, relative to datadog"
  type        = string
  default     = "agent"
}

variable "node_agent_limits_cpu" {
  description = "CPU limits for the Datadog Node Agent"
  type        = string
  default     = "200m"
}

variable "node_agent_limits_memory" {
  description = "Memory limits for the Datadog Node Agent"
  type        = string
  default     = "256Mi"
}

variable "node_agent_log_level" {
  description = "Node Agent log level"
  type        = string
  default     = "info"
}

variable "node_agent_requests_cpu" {
  description = "CPU requests for the Datadog Node Agent"
  type        = string
  default     = "100m"
}

variable "node_agent_requests_memory" {
  description = "Memory requests for the Datadog Node Agent"
  type        = string
  default     = "128Mi"
}

variable "node_agent_tag" {
  description = "Tag for the Datadog node agent image"
  type        = string
  default     = "7.81.1"
}

variable "node_agent_tolerations" {
  description = "Tolerations for the Datadog node agent"
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  default = []
}

variable "registry" {
  description = "Docker registry for the Datadog container images"
  type        = string
}

variable "team" {
  description = "Team name to be used as a tag in Datadog"
  type        = string
}

variable "trace_agent_env_dd_apm_filter_tags_regex_reject" {
  description = "Environment variable values for the Datadog trace agent to regex reject APM tags"
  type        = string
  default     = ""
}
