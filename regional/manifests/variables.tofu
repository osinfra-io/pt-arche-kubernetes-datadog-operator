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
  default     = "7.78.1"
}

variable "cluster_prefix" {
  description = "Prefix for your cluster name, region, and zone (if applicable) will be added to the end of the cluster name"
  type        = string
}

variable "enable_apm" {
  description = <<EOF
    Enable Application Performance Monitoring (APM)
    Cost: $36.00 per host monthly
    EOF
  type        = bool
  default     = false
}

variable "enable_apm_instrumentation" {
  description = "Enable Application Performance Monitoring (APM) Single-Step instrumentation"
  type        = bool
  default     = false
}

variable "enable_asm_iast" {
  description = "Enable Interactive Application Security Testing (IAST)"
  type        = bool
  default     = false
}

variable "enable_asm_sca" {
  description = "Enable Software Composition Analysis (SCA)"
  type        = bool
  default     = false
}

variable "enable_asm_threats" {
  description = <<EOF
    Enable ASM App & API Protection
    Cost: $36.00 per host monthly
    EOF
  type        = bool
  default     = false
}

variable "enable_autoscaling_cluster" {
  description = "Enable cluster autoscaling product (requires Cluster Agent 7.74.0+)"
  type        = bool
  default     = false
}

variable "enable_autoscaling_workload" {
  description = "Enable workload autoscaling product"
  type        = bool
  default     = true
}

variable "enable_cluster_checks_runners" {
  description = "Enable dedicated cluster checks runner pods to offload cluster-level checks from the cluster agent (recommended for large clusters)"
  type        = bool
  default     = false
}

variable "enable_container_collect_all" {
  description = "Enable log collection for all containers"
  type        = bool
  default     = true
}

variable "enable_cspm" {
  description = <<EOF
    Enable Cloud Security Posture Management (CSPM)
    Cost: $12.00 per host monthly
    EOF
  type        = bool
  default     = false
}

variable "enable_cws" {
  description = <<EOF
    Enable Cloud Workload Security (CWS)
    Cost: $36.00 per host monthly
    EOF
  type        = bool
  default     = false
}

variable "enable_cws_network_detection" {
  description = "Enable Cloud Workload Security (CWS) network detections"
  type        = bool
  default     = false
}

variable "enable_ebpf_check" {
  description = "Enable the eBPF check for kernel-level observability"
  type        = bool
  default     = false
}

variable "enable_external_metrics_server" {
  description = "Enable the External Metrics Server"
  type        = bool
  default     = true
}

variable "enable_helm_check" {
  description = "Enable the Helm check to monitor Helm releases in the cluster"
  type        = bool
  default     = false
}

variable "enable_jmx" {
  description = "Whether the Agent image should support JMX"
  type        = bool
  default     = false
}

variable "enable_live_process_collection" {
  description = "Enable live process monitoring (process details visible in Datadog)"
  type        = bool
  default     = false
}

variable "enable_log_collection" {
  description = "Enable log collection"
  type        = bool
  default     = true
}

variable "enable_npm" {
  description = "Enable Network Performance Monitoring (NPM)"
  type        = bool
  default     = true
}

variable "enable_oom_kill" {
  description = "Enable the OOMKill eBPF-based check to track out-of-memory events"
  type        = bool
  default     = false
}

variable "enable_orchestrator_explorer" {
  description = "Enable Orchestrator Explorer"
  type        = bool
  default     = true
}

variable "enable_otel_collector" {
  description = "Enable the embedded OpenTelemetry collector in the Agent"
  type        = bool
  default     = false
}

variable "enable_otlp_grpc" {
  description = "Enable the OTLP/gRPC receiver (port 4317) to ingest OpenTelemetry traces and metrics"
  type        = bool
  default     = false
}

variable "enable_otlp_http" {
  description = "Enable the OTLP/HTTP receiver (port 4318) to ingest OpenTelemetry traces and metrics"
  type        = bool
  default     = false
}

variable "enable_prometheus_scrape" {
  description = "Enable Prometheus autodiscovery to scrape pods and services exposing Prometheus metrics"
  type        = bool
  default     = false
}

variable "enable_sbom" {
  description = "Enable Software Bill of Materials (SBOM) for container image vulnerability scanning"
  type        = bool
  default     = true
}

variable "enable_sbom_enrichment_usage" {
  description = "Enable SBOM enrichment with runtime package-in-use detection (requires system-probe for eBPF-based file access tracking)"
  type        = bool
  default     = false
}

variable "enable_sbom_host" {
  description = "Enable SBOM collection for host packages"
  type        = bool
  default     = false
}

variable "enable_service_discovery" {
  description = "Enable the service discovery check"
  type        = bool
  default     = false
}

variable "enable_tcp_queue_length" {
  description = "Enable the TCP queue length eBPF-based check"
  type        = bool
  default     = false
}

variable "enable_usm" {
  description = "Enable Universal Service Monitoring (USM)"
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
  default     = "7.78.1"
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
