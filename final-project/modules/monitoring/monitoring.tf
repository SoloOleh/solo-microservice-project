resource "null_resource" "monitoring" {
  triggers = {
    namespace                   = var.namespace
    prometheus_release_name     = var.prometheus_release_name
    grafana_release_name        = var.grafana_release_name
    metrics_server_release_name = var.metrics_server_release_name
    grafana_values_sha          = filesha256("${path.module}/grafana-values.yaml")
    prometheus_values_sha       = filesha256("${path.module}/prometheus-values.yaml")
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command = <<EOT
set -euo pipefail

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

helm upgrade --install ${var.metrics_server_release_name} metrics-server/metrics-server \
  --namespace kube-system \
  --set 'args={--kubelet-insecure-tls}' \
  --wait \
  --timeout 5m

kubectl create namespace ${var.namespace} --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install ${var.prometheus_release_name} prometheus-community/prometheus \
  --namespace ${var.namespace} \
  -f "${path.module}/prometheus-values.yaml" \
  --wait \
  --timeout 10m

helm upgrade --install ${var.grafana_release_name} grafana/grafana \
  --namespace ${var.namespace} \
  -f "${path.module}/grafana-values.yaml" \
  --wait \
  --timeout 10m
EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-lc"]
    command = <<EOT
set +e
helm uninstall ${self.triggers.grafana_release_name} -n ${self.triggers.namespace}
helm uninstall ${self.triggers.prometheus_release_name} -n ${self.triggers.namespace}
helm uninstall ${self.triggers.metrics_server_release_name} -n kube-system
kubectl delete namespace ${self.triggers.namespace} --ignore-not-found=true
EOT
  }
}
