resource "aws_iam_role" "jenkins_kaniko_role" {
  name = "${var.cluster_name}-jenkins-kaniko-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.namespace}:jenkins-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "jenkins_ecr_policy" {
  name = "${var.cluster_name}-jenkins-ecr-policy"
  role = aws_iam_role.jenkins_kaniko_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:DescribeRepositories"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "null_resource" "jenkins" {
  triggers = {
    namespace     = var.namespace
    release_name  = var.release_name
    chart_version = var.chart_version
    role_arn      = aws_iam_role.jenkins_kaniko_role.arn
    values_sha    = filesha256("${path.module}/values.yaml")
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command     = <<EOT
set -euo pipefail

kubectl create namespace ${var.namespace} --dry-run=client -o yaml | kubectl apply -f -

cat <<YAML | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp3
YAML

cat <<YAML | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-sa
  namespace: ${var.namespace}
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.jenkins_kaniko_role.arn}
YAML

helm repo add jenkins https://charts.jenkins.io
helm repo update jenkins
helm upgrade --install ${var.release_name} jenkins/jenkins \
  --namespace ${var.namespace} \
  --version ${var.chart_version} \
  -f "${path.module}/values.yaml" \
  --wait \
  --timeout 15m
EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-lc"]
    command     = <<EOT
set +e
helm uninstall ${self.triggers.release_name} -n ${self.triggers.namespace}
kubectl delete namespace ${self.triggers.namespace} --ignore-not-found=true
EOT
  }

  depends_on = [
    aws_iam_role_policy.jenkins_ecr_policy
  ]
}
