# Kubernetes Manifest Resource
# https://search.opentofu.org/provider/hashicorp/kubernetes/latest/docs/resources/manifest

resource "kubernetes_manifest" "agent" {
  field_manager {
    force_conflicts = true
    name            = "OpenTofu"
  }

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
          agentCommunicationMode = "service"
          enabled                = true
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
          cluster = {
            enabled = var.enable_autoscaling_cluster
          }

          workload = {
            enabled = var.enable_autoscaling_workload
          }
        }

        clusterChecks = {
          useClusterChecksRunners = var.enable_cluster_checks_runners
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

        ebpfCheck = {
          enabled = var.enable_ebpf_check
        }

        externalMetricsServer = {
          enabled = var.enable_external_metrics_server
        }

        helmCheck = {
          enabled = var.enable_helm_check
        }

        liveProcessCollection = {
          enabled = var.enable_live_process_collection
        }

        logCollection = {
          containerCollectAll = var.enable_container_collect_all
          enabled             = var.enable_log_collection
        }

        npm = {
          enabled = var.enable_npm
        }

        oomKill = {
          enabled = var.enable_oom_kill
        }

        orchestratorExplorer = {
          enabled = var.enable_orchestrator_explorer
        }

        otelCollector = {
          enabled = var.enable_otel_collector
        }

        otlp = {
          receiver = {
            protocols = {
              grpc = {
                enabled = var.enable_otlp_grpc
              }

              http = {
                enabled = var.enable_otlp_http
              }
            }
          }
        }

        prometheusScrape = {
          enabled = var.enable_prometheus_scrape
        }

        sbom = {
          containerImage = {
            enabled                   = var.enable_sbom
            uncompressedLayersSupport = true
          }

          enabled = var.enable_sbom

          enrichment = {
            usage = {
              enabled = var.enable_sbom_enrichment_usage
            }
          }

          host = {
            enabled = var.enable_sbom_host
          }
        }

        serviceDiscovery = {
          enabled = var.enable_service_discovery
        }

        tcpQueueLength = {
          enabled = var.enable_tcp_queue_length
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

        registry = local.registry
      }

      override = {
        clusterAgent = {
          containers = {
            "cluster-agent" = {
              resources = {
                limits = {
                  cpu    = var.cluster_agent_limits_cpu
                  memory = var.cluster_agent_limits_memory
                }

                requests = {
                  cpu    = var.cluster_agent_requests_cpu
                  memory = var.cluster_agent_requests_memory
                }
              }
            }
          }

          env = local.cluster_agent_env_vars_merged

          image = {
            tag = var.cluster_agent_tag
          }

          labels = {
            "tags.datadoghq.com/env"     = module.core_helpers.environment
            "tags.datadoghq.com/service" = "datadog-cluster-agent"
            "tags.datadoghq.com/version" = var.cluster_agent_tag
          }
        }

        nodeAgent = {
          containers = {
            agent = {
              logLevel = var.node_agent_log_level
            }

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

            trace-agent = {
              env = local.trace_agent_env_vars
            }
          }

          env = local.node_agent_env_vars

          extraConfd = {
            configDataMap = {
              "cilium.yaml" = <<-EOF
              ad_identifiers:
                - cilium
              init_config:
              instances:
                - agent_endpoint: http://%%host%%:9990/metrics
                  use_openmetrics: true
              EOF

              "envoy.yaml" = <<-EOF
              ad_identifiers:
                - proxyv2
              init_config:
              instances:
                - openmetrics_endpoint: http://%%host%%:15020/stats/prometheus
              logs:
                - source: envoy
              EOF
            }
          }

          image = {
            jmxEnabled = var.enable_jmx
            name       = var.node_agent_image
            tag        = var.node_agent_tag
          }

          labels = {
            "tags.datadoghq.com/env"     = module.core_helpers.environment
            "tags.datadoghq.com/service" = "datadog-agent"
            "tags.datadoghq.com/version" = var.node_agent_tag
          }

          priorityClassName = kubernetes_priority_class_v1.datadog.metadata.0.name
          tolerations       = var.node_agent_tolerations
        }
      }
    }
  }
}

check "apm_instrumentation_requires_apm" {
  assert {
    condition     = !var.enable_apm_instrumentation || var.enable_apm
    error_message = "enable_apm_instrumentation requires enable_apm to be true."
  }
}

check "cws_network_requires_cws" {
  assert {
    condition     = !var.enable_cws_network_detection || var.enable_cws
    error_message = "enable_cws_network_detection requires enable_cws to be true."
  }
}

check "sbom_enrichment_requires_sbom" {
  assert {
    condition     = !var.enable_sbom_enrichment_usage || var.enable_sbom
    error_message = "enable_sbom_enrichment_usage requires enable_sbom to be true."
  }
}

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
      message = each.value.message
      name    = each.value.name

      options = {
        notifyNoData = false

        thresholds = {
          critical = each.value.thresholds_critical
          warning  = each.value.thresholds_warning
        }
      }

      priority = each.value.priority
      query    = each.value.query
      tags     = local.kubernetes_monitor_tags
      type     = each.value.type
    }
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
