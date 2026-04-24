# pt-arche-kubernetes-datadog-operator

Deploys the Datadog Operator on GKE for cluster-level monitoring, APM, and log collection. Includes a `regional/` submodule for zone-specific configuration.

## Module Structure

This repo contains two distinct OpenTofu modules — each has its own variables, providers, and state:

| Directory | Purpose |
|---|---|
| `regional/` | Deploys the Datadog Operator Helm chart into the cluster |
| `regional/manifests/` | Deploys the `DatadogAgent` CRD that configures the agent |

Optional feature toggles (`enable_*`) live in `regional/manifests/variables.tofu`. Platform invariants are hardcoded directly in `regional/manifests/main.tofu`.

## Platform Invariants

These features are **always enabled** — they are hardcoded `true` in `main.tofu` and have no corresponding variable. Do not add variables for these; they represent the non-negotiable observability and security baseline.

| Feature (CRD field) | Rationale | Cost signal |
|---|---|---|
| `logCollection.enabled` + `containerCollectAll` | Can't operate without logs | Log Management billing |
| `orchestratorExplorer` | Core K8s pod/deployment visibility | Included |
| `externalMetricsServer` | Required for HPA on custom/external metrics | Included |
| `autoscaling.workload` | Core platform autoscaling | Included |
| `npm` | Network visibility for inter-service debugging | $5/host/month |
| `sbom` + `sbom.containerImage` + `sbom.host` | Container and host vulnerability scanning | CSM Pro ($10/host/month) |
| `cspm` | Cloud Security Posture Management | CSM Pro (same SKU as SBOM) |
| `cws` + `cws.network` | Runtime threat detection via eBPF | Workload Protection ($15/host/month) |

## Version Locations

Three version values must be kept in sync:

| What | File | Variable |
|---|---|---|
| Datadog Operator Helm chart | `regional/variables.tofu` | `operator_version` |
| Node Agent image tag | `regional/manifests/variables.tofu` | `node_agent_tag` |
| Cluster Agent image tag | `regional/manifests/variables.tofu` | `cluster_agent_tag` |

Finding latest versions:
- Operator chart: https://github.com/DataDog/helm-charts/releases (filter `datadog-operator-*`)
- Agent / Cluster Agent: https://hub.docker.com/r/datadog/agent/tags (both share the same version)
- CRD spec reference: https://github.com/DataDog/datadog-operator/blob/main/docs/configuration.v2alpha1.md

## Adding a New Agent Feature

For optional features (team or cluster decides):
1. Add an `enable_*` variable to `regional/manifests/variables.tofu`. Include pricing if the feature has a cost (see *Datadog Pricing* section below).
2. Add the feature block inside `spec.features` in `regional/manifests/main.tofu`.
3. If the feature has a hard prerequisite on another variable-driven feature, add a `check` block at the bottom of `main.tofu` and document it in the *Feature Dependency Rules* table below.
4. If the new `check` block would fire with default values, update the test fixture at `tests/fixtures/default/regional/manifests/main.tofu`.

For invariant features (always on, no opt-out): hardcode `true` directly in `main.tofu` — do not add a variable.

## Feature Dependency Rules

These cross-variable constraints are enforced via `check` blocks at the bottom of `regional/manifests/main.tofu`:

| Dependent feature | Requires |
|---|---|
| `enable_apm_instrumentation` | `enable_apm = true` |

Keep this table and the `check` blocks in sync when adding new dependencies. Note: `cws` and `sbom` are platform invariants — any feature that depends on them needs no check block since they are always on.

## Datadog Pricing in Variable Descriptions

Optional variables in `regional/manifests/variables.tofu` include pricing from https://www.datadoghq.com/pricing/. Datadog revises pricing periodically. When modifying or adding feature variables:

1. Verify the current price at https://www.datadoghq.com/pricing/ for the relevant product.
2. Capture both the **annual** and **on-demand** rates, and any prerequisite products.
3. Update the `description` if the price or product name has changed.

| Variable | Pricing page product |
|---|---|
| `enable_apm`, `enable_apm_instrumentation` | Application Performance Monitoring |
| `enable_asm_threats`, `enable_asm_iast`, `enable_asm_sca` | App and API Protection |
| `enable_live_process_collection` | Infrastructure (Enterprise tier feature) |
| `enable_prometheus_scrape` | Infrastructure → Custom Metrics |
| `enable_sbom_enrichment_usage` | Cloud Security → CSM Pro/Enterprise |
| `enable_usm` | Universal Service Monitoring |
