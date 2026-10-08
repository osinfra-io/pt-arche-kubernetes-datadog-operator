# Kubernetes - Datadog Operator OpenTofu Module

[![OpenTofu Tests](https://img.shields.io/github/actions/workflow/status/osinfra-io/pt-arche-kubernetes-datadog-operator/test.yml?style=for-the-badge&logo=opentofu&color=FEDA15&label=OpenTofu%20Tests)](https://github.com/osinfra-io/pt-arche-kubernetes-datadog-operator/actions/workflows/test.yml) [![Dependabot](https://img.shields.io/github/actions/workflow/status/osinfra-io/pt-arche-kubernetes-datadog-operator/dependabot.yml?style=for-the-badge&logo=github&color=2088FF&label=Dependabot)](https://github.com/osinfra-io/pt-arche-kubernetes-datadog-operator/actions/workflows/dependabot.yml) [![Datadog Security Enabled](https://img.shields.io/badge/Datadog%20Security-Enabled-632CA6?style=for-the-badge&logo=datadog)](https://app.datadoghq.com/security/code-security/repositories?repository_id=pt-arche-kubernetes-datadog-operator)

## Repository Description

Reusable OpenTofu child module for the Datadog Kubernetes Operator on Google Kubernetes Engine (GKE).

## 🔩 Usage

### Module interfaces

| Source path | Purpose | Interface |
| --- | --- | --- |
| `//regional` | Deploys the Datadog Operator Helm release and its API/application-key Secret. | [`regional/variables.tofu`](regional/variables.tofu) |
| `//regional/manifests` | Creates the `DatadogAgent` custom resource, priority class, and Kubernetes monitor templates. | [`regional/manifests/variables.tofu`](regional/manifests/variables.tofu) · [`regional/manifests/outputs.tofu`](regional/manifests/outputs.tofu) |

The repository root is not a consumable module. The operator watches only the `datadog` namespace by default; use `[""]` only when cluster-wide watching is intended. The manifests module enables log collection, orchestrator explorer, external metrics, workload autoscaling, network monitoring, CSPM, runtime security, and host/container SBOM collection as platform invariants. Universal Service Monitoring also defaults to enabled; APM, application security, Prometheus scraping, live processes, and most other optional features default to disabled. Many enabled and optional features are separately licensed or increase log, metric, trace, and security ingestion, so review current Datadog pricing before deployment. API and application keys are sensitive and are stored in a Kubernetes Secret, the `DatadogAgent` resource, and OpenTofu state. Restrict read access to all three resources.

> [!TIP]
> You can check the [tests/fixtures](tests/fixtures) directory for example configurations. These fixtures set up the system for testing by providing all the necessary initial code, thus creating good examples on which to base your configurations.

## 🛠️ Tools

- [helm](https://github.com/helm/helm)
- [osinfra-pre-commit-hooks](https://github.com/osinfra-io/pt-techne-pre-commit-hooks)
- [pre-commit](https://github.com/pre-commit/pre-commit)

## 📋 Skills and Knowledge

- [datadog-operator](https://docs.datadoghq.com/containers/datadog_operator)

## 🔍 Tests

Tests use [mocked providers](https://opentofu.org/docs/cli/commands/test/#the-mock_provider-blocks); no infrastructure or credentials are required.

```none
tofu init
```

```none
tofu test
```

## 📦 Release

To release a new version, simply push a new tag to the repository. The tag should be in the format `vX.Y.Z` where `X`, `Y`, and `Z` are integers.

```none
git tag vX.Y.Z
git push origin vX.Y.Z
```
