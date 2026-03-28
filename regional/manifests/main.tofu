# Kubernetes Manifest Resource
# https://search.opentofu.org/provider/hashicorp/kubernetes/latest/docs/resources/manifest

resource "kubernetes_manifest" "agent" {
  manifest = {
    apiVersion = "datadoghq.com/v2alpha1"
    kind       = "DatadogAgent"

    metadata = {
      name      = "datadog"
      namespace = "datadog"
    }

    spec = {
      features = {
        admissionController = {
          enabled                = true
          agentCommunicationMode = "service"
        }

        apm = {
          enabled = var.enable_apm

          hostPortConfig = {
            enabled  = true
            hostPort = 8126
          }

          instrumentation = {
            enabled = var.enable_apm_instrumentation
          }
        }

        asm = {
          iast = {
            enabled = var.enable_asm_iast
          }

          sca = {
            enabled = var.enable_asm_sca
          }

          threats = {
            enabled = var.enable_asm_threats
          }
        }

        autoscaling = {
          workload = {
            enabled = true
          }
        }

        cspm = {
          enabled = var.enable_cspm
        }

        cws = {
          enabled = var.enable_cws

          network = {
            enabled = var.enable_cws_network_detection
          }
        }

        externalMetricsServer = {
          enabled = var.enable_external_metrics_server
        }

        logCollection = {
          containerCollectAll = var.enable_container_collect_all
          enabled             = var.enable_log_collection
        }

        npm = {
          enabled = var.enable_npm
        }

        orchestratorExplorer = {
          enabled = var.enable_orchestrator_explorer
        }

        sbom = {
          containerImage = {
            enabled                   = var.enable_sbom
            uncompressedLayersSupport = true
          }

          enabled = var.enable_sbom
        }

        usm = {
          enabled = var.enable_usm
        }
      }

      global = {
        clusterName = local.cluster_name

        credentials = {
          apiKey = var.api_key
          appKey = var.app_key
        }

        registry = "${var.registry}/datadog"
      }

      override = {
        clusterAgent = {
          env = concat(local.cluster_agent_env_vars, var.cluster_agent_env_vars)

          labels = {
            "tags.datadoghq.com/env"     = module.helpers.environment
            "tags.datadoghq.com/service" = "datadog-cluster-agent"
            "tags.datadoghq.com/version" = var.node_agent_tag
          }
        }

        nodeAgent = {
          containers = {
            all = {
              resources = {

                # Currently it's not ideal how we have to set the resources for the various components.
                # Looking into support at the workload level for setting resources:
                # https://github.com/DataDog/datadog-operator/issues/1408

                limits = {
                  cpu    = var.node_agent_limits_cpu
                  memory = var.node_agent_limits_memory
                }

                requests = {
                  cpu    = var.node_agent_requests_cpu
                  memory = var.node_agent_requests_memory
                }
              }
            }

            agent = {
              logLevel = var.node_agent_log_level
            }

            trace-agent = {
              env = local.trace_agent_env_vars
            }
          }

          env = local.node_agent_env_vars

          extraConfd = {
            configDataMap = {
              "envoy.yaml" = <<-EOF
              ad_identifiers:
                - proxyv2
              init_config:
              instances:
                - openmetrics_endpoint: http://%%host%%:15020/stats/prometheus
              logs:
                - source: envoy
              EOF

              "cilium.yaml" = <<-EOF
              ad_identifiers:
                - cilium
              init_config:
              instances:
                - agent_endpoint: http://%%host%%:9990/metrics
                  use_openmetrics: true
              EOF
            }
          }

          image = {
            jmxEnabled = var.enable_jmx
            name       = var.node_agent_image
            tag        = var.node_agent_tag
          }

          labels = {
            "tags.datadoghq.com/env"     = module.helpers.environment
            "tags.datadoghq.com/service" = "datadog-agent"
            "tags.datadoghq.com/version" = var.node_agent_tag
          }

          priorityClassName = kubernetes_priority_class_v1.datadog.metadata.0.name
          tolerations       = var.node_agent_tolerations
        }
      }
    }
  }

  field_manager {
    name            = "OpenTofu"
    force_conflicts = true
  }
}

# Kubernetes Priority Class Resource
# https://search.opentofu.org/provider/hashicorp/kubernetes/latest/docs/resources/priority_class_v1

resource "kubernetes_priority_class_v1" "datadog" {
  description    = "Allow Datadog Agent Components to be scheduled with higher priority."
  global_default = false

  metadata {
    name = "datadog"
  }

  value = 1000000
}

# Kubernetes Manifest Resource
# https://search.opentofu.org/provider/hashicorp/kubernetes/latest/docs/resources/manifest

resource "kubernetes_manifest" "kubernetes_monitor_templates" {
  for_each = local.kubernetes_monitor_templates

  manifest = {
    apiVersion = "datadoghq.com/v1alpha1"
    kind       = "DatadogMonitor"

    metadata = {
      name      = each.key
      namespace = "datadog"
    }

    spec = {
      query   = each.value.query
      type    = each.value.type
      name    = each.value.name
      message = each.value.message

      tags = concat(local.tags,
        [
          "integration:kubernetes"
        ]
      )

      options = {
        thresholds = {
          critical = each.value.thresholds_critical
          warning  = each.value.thresholds_warning
        }

        notifyNoData = false
      }

      priority = each.value.priority
    }
  }
}
