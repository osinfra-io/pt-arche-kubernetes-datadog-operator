# Local Values
# https://opentofu.org/docs/language/values/locals

locals {
  cluster_agent_env_vars = [

    # Datadog Inferred Services:

    {
      name  = "DD_APM_COMPUTE_STATS_BY_SPAN_KIND"
      value = "true"
    },
    {
      name  = "DD_APM_PEER_TAGS_AGGREGATION"
      value = "true"
    }
  ]

  cluster_agent_env_vars_merged = concat(local.cluster_agent_env_vars, var.cluster_agent_env_vars)

  cluster_name = module.core_helpers.zone != null ? "${var.cluster_prefix}-${module.core_helpers.region}-${module.core_helpers.zone}-${module.core_helpers.env}" : "${var.cluster_prefix}-${module.core_helpers.region}-${module.core_helpers.env}"

  kubernetes_monitor_tags = concat(local.tags, ["integration:kubernetes"])

  kubernetes_monitor_templates = {
    "crash-loop-backoff" = {
      message = <<-EOF
      Pod {{pod_name.name}} is in CrashLoopBackOff in {{kube_namespace.name}} on cluster: {{kube_cluster_name.name}}.

      The status CrashloopBackOff means that a container in the Pod is started, crashes, and is restarted, over and
      over again. This monitor tracks when a pod is in a CrashloopBackOff state for your Kubernetes integration.

      @hangouts-platform-medium-low-info-priority
      EOF

      name                = "[Kubernetes: ${local.cluster_name}] Pods in CrashLoopBackOff"
      priority            = 4
      query               = "max(last_10m):default_zero(max:kubernetes_state.container.status_report.count.waiting{reason:crashloopbackoff, kube_cluster_name:${local.cluster_name}} by {kube_namespace,pod_name}) >= 1"
      thresholds_critical = 1
      thresholds_warning  = null
      type                = "query alert"
    }

    "failing-deployment-replicas" = {
      message = <<-EOF
      More than one Deployments Replica pods are down in Deployment {{kube_namespace.name}}/{{kube_deployment.name}} on cluster: {{kube_cluster_name.name}}."

      Kubernetes replicas are clones that facilitate self-healing for pods. Each pod has a desired number of
      replica Pods that should be running at any given time. This monitor tracks the number of replicas that are
      failing per deployment.

      @hangouts-platform-medium-low-info-priority
      EOF

      name                = "[Kubernetes: ${local.cluster_name}] Deployments Replica Pods are Down"
      priority            = 4
      query               = "avg(last_15m):avg:kubernetes_state.deployment.replicas_desired{kube_cluster_name:${local.cluster_name}} by {kube_namespace,kube_deployment} - avg:kubernetes_state.deployment.replicas_available{kube_cluster_name:${local.cluster_name}} by {kube_namespace,kube_deployment} >= 2"
      thresholds_critical = 2
      thresholds_warning  = null
      type                = "query alert"
    }

    "failing-pods" = {
      message = <<-EOF
      More than ten pods are failing on cluster: {{kube_cluster_name.name}}.

      When a pod is failing it means the container either exited with non-zero status or was terminated by the
      system. This monitor tracks when more than 10 pods are failing for a given Kubernetes cluster.

      @hangouts-platform-medium-low-info-priority
      EOF

      name                = "[Kubernetes: ${local.cluster_name}] Pods are failing"
      priority            = 4
      query               = "change(avg(last_5m),last_5m):default_zero(sum:kubernetes_state.pod.status_phase{pod_phase:failed, kube_cluster_name:${local.cluster_name}} by {kube_namespace,pod_name}) > 10"
      thresholds_critical = 10
      thresholds_warning  = 5
      type                = "query alert"
    }

    "failing-statefulset-replicas" = {
      message = <<-EOF
      More than one Statefulset Replica pods are down in Statefulset {{kube_namespace.name}}/{{kube_stateful_set.name}} on cluster: {{kube_cluster_name.name}}.

      Kubernetes replicas are clones that facilitate self-healing for pods. Each pod has a desired number of
      replica Pods that should be running at any given time. This monitor tracks when the number of replicas per
      statefulset is falling.

      @hangouts-platform-medium-low-info-priority
      EOF

      name                = "[Kubernetes: ${local.cluster_name}] Statefulset Replicas are Down"
      priority            = 4
      query               = "max(last_15m):sum:kubernetes_state.statefulset.replicas_desired{kube_cluster_name:${local.cluster_name}} by {kube_namespace,kube_stateful_set} - sum:kubernetes_state.statefulset.replicas_ready{kube_cluster_name:${local.cluster_name}} by {kube_namespace,kube_stateful_set} >= 2"
      thresholds_critical = 2
      thresholds_warning  = null
      type                = "query alert"
    }

    "high-cpu-usage" = {
      message = <<-EOF
      Pod CPU usage is over 90% on {{kube_namespace.name}}/{{pod_name.name}} on cluster: {{kube_cluster_name.name}}.

      High CPU usage in a Kubernetes pod can indicate that the application or service running inside the pod is
      consuming more processing power than expected.

      @hangouts-platform-medium-low-info-priority
      EOF

      name                = "[Kubernetes: ${local.cluster_name}] Pod CPU Usage is High"
      priority            = 5
      query               = "avg(last_5m):(avg:kubernetes.cpu.usage.total{kube_cluster_name:${local.cluster_name}} by {kube_namespace,pod_name} / 10000000) / avg:kubernetes.cpu.limits{kube_cluster_name:${local.cluster_name}} by {kube_namespace,pod_name} > 90"
      thresholds_critical = 90
      thresholds_warning  = 80
      type                = "metric alert"
    }

    "high-memory-usage" = {
      message = <<-EOF
      Pod memory usage is over 90% on {{kube_namespace.name}}/{{pod_name.name}} on cluster: {{kube_cluster_name.name}}.

      High memory usage in a Kubernetes pod occurs when the application inside the pod consumes more memory than expected.

      @hangouts-platform-medium-low-info-priority
      EOF

      name                = "[Kubernetes: ${local.cluster_name}] Pod Memory Usage is High"
      priority            = 5
      query               = "avg(last_5m):avg:kubernetes.memory.usage{kube_cluster_name:${local.cluster_name}} by {kube_namespace,pod_name} / avg:kubernetes.memory.limits{kube_cluster_name:${local.cluster_name}} by {kube_namespace,pod_name} * 100 > 90"
      thresholds_critical = 90
      thresholds_warning  = 80
      type                = "metric alert"
    }

    "image-pull-backoff" = {
      message = <<-EOF
      Pod {{pod_name.name}} is in ImagePullBackOff on {{kube_namespace.name}}.

      The status ImagePullBackOff means that a container could not start because Kubernetes could not pull a
      container image. This monitor tracks when a pod is in an ImagePullBackOff state for your Kubernetes integration.

      @hangouts-platform-medium-low-info-priority
      EOF

      name                = "[Kubernetes: ${local.cluster_name}] Pods in ImagePullBackOff"
      priority            = 4
      query               = "max(last_10m):default_zero(max:kubernetes_state.container.status_report.count.waiting{reason:imagepullbackoff, kube_cluster_name:${local.cluster_name}} by {kube_namespace,pod_name}) >= 1"
      thresholds_critical = 1
      thresholds_warning  = null
      type                = "query alert"
    }

    "restarting-pods" = {
      message = <<-EOF
      Pod {{pod_name.name}} restarted multiple times in the last five minutes on {{kube_namespace.name}} on cluster: {{kube_cluster_name.name}}.

      Kubernetes pods restart according to the restart policy. A restarting container can indicate problems with
      memory, CPU usage, or an application exiting prematurely. This monitor tracks when pods are restarting multiple times.

      @hangouts-platform-medium-low-info-priority
      EOF

      name                = "[Kubernetes: ${local.cluster_name}] Pods Restarting"
      priority            = 4
      query               = "change(max(last_5m),last_5m):sum:kubernetes.containers.restarts{kube_cluster_name:${local.cluster_name}} by {pod_name} > 5"
      thresholds_critical = 5
      thresholds_warning  = 3
      type                = "query alert"
    }

    "unschedulable-node" = {
      message = <<-EOF
      More than 20% of nodes are unschedulable on cluster: {{kube_cluster_name.name}}.

      Kubernetes nodes can either be schedulable or unschedulable. When unschedulable, the node prevents the scheduler
      from placing new pods onto that node. This monitor tracks the percentage of schedulable nodes.

      @hangouts-platform-medium-low-info-priority
      EOF

      name                = "[Kubernetes: ${local.cluster_name}] Unschedulable Nodes"
      priority            = 4
      query               = "max(last_15m):default_zero(sum:kubernetes_state.node.status{status:schedulable, kube_cluster_name:${local.cluster_name}} * 100 / sum:kubernetes_state.node.status{kube_cluster_name:${local.cluster_name}}) < 80"
      thresholds_critical = 80
      thresholds_warning  = 90
      type                = "query alert"
    }
  }

  node_agent_env_vars = [
    {
      name  = "DD_CONTAINER_EXCLUDE"
      value = "kube_namespace:^gke-managed-cim$ kube_namespace:^gke-managed-system kube_namespace:^gke-mcs$ kube_namespace:^gmp-system$ kube_namespace:^kube-node-lease$ kube_namespace:^kube-public$ kube_namespace:^kube-system$ ${var.node_agent_env_dd_container_exclude}"
    },
    {
      name  = "DD_IGNORE_AUTOCONF"
      value = "cilium ${var.node_agent_env_dd_ignore_auto_conf}"
    }
  ]

  registry = "${var.registry}/datadog"

  tags = [
    "cluster:${local.cluster_name}",
    "env:${module.core_helpers.environment}",
    "generated:kubernetes",
    "region:${module.core_helpers.region}",
    "team:${var.team}"
  ]

  trace_agent_env_vars = [

    # Ignoring Unwanted Resources in APM
    # https://docs.datadoghq.com/tracing/guide/ignoring_apm_resources

    {
      name  = "DD_APM_FILTER_TAGS_REGEX_REJECT"
      value = "http.useragent:kube-probe/\\d+\\.\\d+ http.url:https?:\\/\\/[^\\/]+\\/favicon\\.ico ${var.trace_agent_env_dd_apm_filter_tags_regex_reject}"
    }
  ]
}
