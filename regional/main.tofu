# Helm Release
# https://search.opentofu.org/provider/hashicorp/helm/latest/docs/resources/release

resource "helm_release" "datadog_operator" {
  chart      = "datadog-operator"
  name       = "datadog-operator"
  namespace  = "datadog"
  repository = "https://helm.datadoghq.com"

  set = local.helm_values

  set_sensitive = local.helm_sensitive_values

  timeout = 900

  values = [
    file("${path.module}/helm/datadog-operator.yml")
  ]

  version = var.operator_version
}

# Kubernetes Secret Resource
# https://search.opentofu.org/provider/hashicorp/kubernetes/latest/docs/resources/secret_v1

resource "kubernetes_secret_v1" "datadog_operator_secret" {
  data = {
    "api-key" = var.api_key
    "app-key" = var.app_key
  }

  metadata {
    name      = "datadog-operator-secret"
    namespace = "datadog"
  }
}
