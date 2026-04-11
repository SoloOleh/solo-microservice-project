# Lesson 7 — Розгортання Django-застосунку в EKS за допомогою Helm

## Опис проєкту

Цей проєкт містить інфраструктуру та Helm-конфігурацію для розгортання Django-застосунку в Amazon EKS.

Домашнє завдання включає:

- створення AWS-інфраструктури за допомогою Terraform
- створення ECR-репозиторію для Docker-образу
- завантаження Docker-образу Django до ECR
- розгортання застосунку в Kubernetes за допомогою Helm
- використання ConfigMap для змінних середовища
- налаштування Horizontal Pod Autoscaler (HPA)

## Структура проєкту

```text
lesson-7/
│
├── main.tf
├── backend.tf
├── outputs.tf
│
├── modules/
│   ├── s3-backend/
│   ├── vpc/
│   ├── ecr/
│   └── eks/
│
├── charts/
│   └── django-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── configmap.yaml
│           └── hpa.yaml
```

## Використані технології

- Terraform
- AWS EKS
- AWS ECR
- AWS RDS PostgreSQL
- Kubernetes
- Helm
- Docker
- Django

## Компоненти інфраструктури

Цей проєкт створює та використовує такі AWS-ресурси:

- S3 bucket для Terraform state
- DynamoDB table для блокування Terraform state
- VPC з публічними та приватними subnet
- NAT Gateway
- EKS cluster
- EKS node group
- ECR repository
- RDS PostgreSQL database

## Попередні вимоги

Перед запуском проєкту потрібно встановити та налаштувати:

- AWS CLI
- Terraform
- kubectl
- Helm
- Docker Desktop

Перевірка версій:

```bash
aws --version
terraform version
kubectl version --client
helm version
docker --version
```

Налаштування AWS CLI:

```bash
aws configure
aws sts get-caller-identity
```

## Крок 1. Ініціалізація Terraform

Якщо backend-ресурси ще не створені:

```bash
mv backend.tf backend.tf.disabled
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
mv backend.tf.disabled backend.tf
terraform init -migrate-state
```

## Крок 2. Створення інфраструктури

Створи основну інфраструктуру:

```bash
terraform plan
terraform apply
```

Перевір outputs:

```bash
terraform output
```

## Крок 3. Підключення kubectl до EKS

```bash
aws eks update-kubeconfig --region us-west-2 --name eks-cluster-demo
kubectl get nodes
```

## Крок 4. Збірка та завантаження Docker-образу в ECR

Логін в ECR:

```bash
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com
```

Збери та завантаж Docker-образ.

Якщо Dockerfile знаходиться в папці `web`:

docker buildx build \
 --platform linux/amd64 \
 -t <AWS_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/django-app:latest \
 --push .

````

## Крок 5. Налаштування Helm values

Відредагуй файл:

```bash
charts/django-app/values.yaml
````

Приклад конфігурації:

```yaml
replicaCount: 1

image:
  repository: <AWS_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/django-app
  tag: latest
  pullPolicy: Always

service:
  type: LoadBalancer
  port: 80
  targetPort: 8000

config:
  DJANGO_SECRET_KEY: your-secret-key
  DEBUG: "False"
  ALLOWED_HOSTS: "*"
  POSTGRES_HOST: your-rds-endpoint.us-west-2.amazonaws.com
  POSTGRES_PORT: "5432"
  POSTGRES_DB: appdb
  POSTGRES_USER: goituser
  POSTGRES_PASSWORD: your-db-password

autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 6
  targetCPUUtilizationPercentage: 70
```

## Крок 6. Перевірка Helm chart

```bash
helm lint ./charts/django-app
helm template django-app ./charts/django-app
```

## Крок 7. Розгортання застосунку через Helm

```bash
helm upgrade --install django-app ./charts/django-app
```

Перевір ресурси:

```bash
kubectl get pods
kubectl get svc
kubectl get configmap
kubectl get hpa
kubectl get all
```

## Крок 8. Встановлення metrics-server

```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args={--kubelet-insecure-tls}
```

Перевір метрики:

```bash
kubectl top nodes
kubectl top pods
kubectl get hpa
```

## Доступ до застосунку

Після розгортання отримай зовнішню адресу:

```bash
kubectl get svc
```

Застосунок доступний через LoadBalancer EXTERNAL-IP.

Приклад:

- `/admin/` — сторінка Django admin

## Фінальна перевірка

```bash
terraform output
kubectl get nodes
kubectl get all
kubectl get configmap
kubectl get hpa
helm list -A
```

## Результат

Реалізовано:

- EKS cluster через Terraform
- ECR repository з Django image
- Helm chart з Deployment, Service, ConfigMap, HPA
- ConfigMap підключений до застосунку
- metrics-server встановлений для HPA metrics
- зовнішній доступ до Django-застосунку через LoadBalancer
