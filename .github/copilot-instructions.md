# pt-arche-kubernetes-datadog-operator

Deploys the Datadog Operator on GKE for cluster-level monitoring, APM, and log collection. Includes a `regional/` submodule for zone-specific configuration.

## Datadog Pricing in Variable Descriptions

Many variables in `regional/manifests/variables.tofu` include pricing from https://www.datadoghq.com/pricing/ to help operators understand the cost impact of enabling features.

**Keep pricing current:** Datadog revises its pricing periodically. When modifying any `enable_*` variable or adding new feature variables:

1. Verify the current price at https://www.datadoghq.com/pricing/ for the relevant product.
2. Note both the **annual** and **on-demand** rates, and any prerequisite products (e.g. "requires Infrastructure Pro or Enterprise").
3. Update the `description` in `variables.tofu` if the price or product name has changed.

Pricing to verify when touching these variables:

| Variable | Pricing page product |
|---|---|
| `enable_apm`, `enable_apm_instrumentation` | Application Performance Monitoring |
| `enable_asm_threats`, `enable_asm_iast`, `enable_asm_sca` | App and API Protection |
| `enable_cspm` | Cloud Security → CSM Pro |
| `enable_cws`, `enable_cws_network_detection` | Workload Protection / CSM Enterprise |
| `enable_npm` | Network Monitoring → Cloud Network Monitoring |
| `enable_usm` | Universal Service Monitoring |
| `enable_live_process_collection` | Infrastructure (Enterprise tier feature) |
| `enable_log_collection`, `enable_container_collect_all` | Log Management |
| `enable_prometheus_scrape` | Infrastructure → Custom Metrics |
| `enable_sbom`, `enable_sbom_host`, `enable_sbom_enrichment_usage` | Cloud Security → CSM Pro/Enterprise |
