# Lesson 8-9 — Jenkins + Terraform + Helm + Argo CD

## Що робить цей проєкт

Цей проєкт реалізує повний CI/CD ланцюжок для Django-застосунку:

1. Terraform створює AWS-інфраструктуру.
2. Terraform через Helm встановлює Jenkins у кластер EKS.
3. Terraform через Helm встановлює Argo CD у той самий кластер.
4. Jenkins pipeline збирає Docker image через Kaniko.
5. Jenkins пушить image в Amazon ECR.
6. Jenkins оновлює `values.yaml` у Git-репозиторії з Helm chart.
7. Argo CD бачить зміну в Git і автоматично синхронізує застосунок у Kubernetes.

## Структура проєкту

```text
lesson-9/
├── main.tf
├── backend.tf
├── outputs.tf
├── README.md
├── Jenkinsfile
├── charts/
│   └── django-app/
├── modules/
│   ├── s3-backend/
│   ├── vpc/
│   ├── ecr/
│   ├── eks/
│   ├── jenkins/
│   └── argo_cd/
```

## Що потрібно перед стартом

- AWS CLI
- Terraform
- kubectl
- Helm
- Docker
- Git
- GitHub repo з Helm chart для Django-застосунку
- GitHub repo з цим Terraform/Jenkins кодом

## Важливо перед `terraform init`

Якщо S3 backend ще не створений, спочатку створи ресурси бекенду локально:

```bash
mv backend.tf backend.tf.disabled
terraform init
terraform apply
mv backend.tf.disabled backend.tf
terraform init -migrate-state
```

## Як застосувати Terraform

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply
```

Після створення інфраструктури підключи `kubectl` до EKS:

```bash
aws eks update-kubeconfig --region us-west-2 --name eks-cluster-demo
kubectl get nodes
```

## Що треба налаштувати в Jenkins

### 1. Створи credentials

У Jenkins треба створити такі credentials:

- `github-token` — тип **Username with password**
  - username = ваш GitHub username
  - password = ваш GitHub Personal Access Token
- `chart-repo-url` не потрібен як credential, бо URL вказується прямо в `Jenkinsfile`

### 2. Створи Pipeline job

- New Item → Pipeline
- Pipeline script from SCM
- SCM: Git
- Repository URL: репозиторій, де лежить цей `Jenkinsfile`
- Branch: `*/main`
- Script Path: `Jenkinsfile`

## Як працює Jenkins job

Pipeline виконує 3 основні етапи:

1. Клонує репозиторій з кодом.
2. Збирає та пушить Docker image в ECR через Kaniko.
3. Клонує репозиторій з Helm chart, оновлює `charts/django-app/values.yaml` і пушить зміни в `main`.

## Як перевірити Jenkins job

Після запуску job перевір:

```bash
kubectl get pods -n jenkins
kubectl get svc -n jenkins
```

У самому Jenkins перевір, що build:

- завершився успішно;
- створив новий tag образу;
- виконав commit у репозиторій з chart;
- запушив зміни в `main`.

Також можна перевірити новий image в ECR:

```bash
aws ecr describe-images --repository-name django-app --region us-west-2
```

## Як працює Argo CD

Argo CD встановлюється Terraform через Helm і створює Application, яка стежить за Git-репозиторієм із Helm chart.

У `modules/argo_cd/chart/values.yaml` треба вказати:

- `repoURL` — репозиторій з chart;
- `path` — шлях до chart у репозиторії;
- `targetRevision` — зазвичай `main`.

## Як подивитися результат в Argo CD

Перевір ресурси:

```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
kubectl get applications -n argocd
```

Отримай пароль адміністратора:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

Отримай зовнішню адресу сервісу:

```bash
kubectl get svc -n argocd
```

Після цього відкрий Argo CD UI і переконайся, що Application:

- має статус `Synced`;
- має статус `Healthy`;
- після нового коміту в chart-репозиторій автоматично оновлюється.

## Схема CI/CD

```text
Git repo with app source
        │
        ▼
     Jenkins
        │
        ├── build image with Kaniko
        ├── push image to Amazon ECR
        └── update Helm values.yaml in Git
                               │
                               ▼
                     Git repo with Helm chart
                               │
                               ▼
                           Argo CD
                               │
                               ▼
                          Kubernetes
```

## Що обов'язково перевірити перед здачею

- `main.tf` без синтаксичних помилок
- Jenkins встановлюється через Terraform + Helm
- Argo CD встановлюється через Terraform + Helm
- Є робочий `Jenkinsfile`
- Є Argo CD Application
- `README.md` описує запуск, перевірку Jenkins і перевірку Argo CD

## Видалення ресурсів

Після перевірки видали ресурси:

```bash
terraform destroy
```

Пам'ятай: якщо був видалений весь backend, для наступного запуску S3 bucket і DynamoDB треба буде створювати знову у правильному порядку.
