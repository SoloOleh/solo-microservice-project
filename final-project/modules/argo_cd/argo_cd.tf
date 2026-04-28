resource "null_resource" "argo_cd" {
  triggers = {
    namespace        = var.namespace
    release_name     = var.name
    chart_version    = var.chart_version
    repo_url         = var.repo_url
    target_revision  = var.target_revision
    app_chart_path   = var.app_chart_path
    app_namespace    = var.app_namespace
    image_repository = var.image_repository
    db_host          = var.db_host
    db_name          = var.db_name
    db_username      = var.db_username
    values_sha       = filesha256("${path.module}/values.yaml")
    chart_sha        = filesha256("${path.module}/charts/templates/application.yaml")
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command     = <<EOT
set -euo pipefail

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo

helm upgrade --install ${var.name} argo/argo-cd \
  --namespace ${var.namespace} \
  --create-namespace \
  --version ${var.chart_version} \
  -f "${path.module}/values.yaml" \
  --wait \
  --timeout 15m

kubectl wait --for=condition=Established crd/applications.argoproj.io --timeout=180s
kubectl -n ${var.namespace} rollout status deployment/${var.name}-server --timeout=10m || true

cat > /tmp/argocd-apps-values-${var.namespace}.yaml <<YAML
applications:
  - name: django-app
    namespace: ${var.namespace}
    project: default
    source:
      repoURL: ${var.repo_url}
      path: ${var.app_chart_path}
      targetRevision: ${var.target_revision}
      helm:
        parameters:
          - name: image.repository
            value: ${jsonencode(var.image_repository)}
          - name: config.POSTGRES_HOST
            value: ${jsonencode(var.db_host)}
          - name: config.POSTGRES_DB
            value: ${jsonencode(var.db_name)}
          - name: config.POSTGRES_USER
            value: ${jsonencode(var.db_username)}
          - name: config.POSTGRES_PASSWORD
            value: ${jsonencode(var.db_password)}
    destination:
      server: https://kubernetes.default.svc
      namespace: ${var.app_namespace}
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
repositories: []
YAML

helm upgrade --install ${var.name}-apps "${path.module}/charts" \
  --namespace ${var.namespace} \
  -f /tmp/argocd-apps-values-${var.namespace}.yaml \
  --wait \
  --timeout 5m
EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-lc"]
    command     = <<EOT
set +e
helm uninstall ${self.triggers.release_name}-apps -n ${self.triggers.namespace}
helm uninstall ${self.triggers.release_name} -n ${self.triggers.namespace}
kubectl delete namespace ${self.triggers.namespace} --ignore-not-found=true
EOT
  }
}
