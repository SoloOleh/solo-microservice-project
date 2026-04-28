# Final Project — DevOps infrastructure on AWS

Цей проєкт підготовлений для фінального домашнього завдання з DevOps.

Головна ідея: у папці `final-project` зібрана повна інфраструктура:

- AWS VPC
- EKS Kubernetes cluster
- ECR repository
- RDS PostgreSQL або Aurora PostgreSQL
- Jenkins
- Argo CD
- Prometheus
- Grafana
- Django application
- Helm chart для Django
- HPA для autoscaling Django deployment

Проєкт адаптований під репозиторій:

```text
https://github.com/SoloOleh/goit-devops-cicd
```

Гілка:

```text
final-project
```

Шлях у репозиторії:

```text
final-project/
```

## 1. Структура проєкту

```text
final-project/
├── main.tf
├── backend.tf
├── variables.tf
├── outputs.tf
├── README.md
│
├── modules/
│   ├── s3-backend/
│   ├── vpc/
│   ├── ecr/
│   ├── eks/
│   ├── rds/
│   ├── jenkins/
│   ├── argo_cd/
│   └── monitoring/
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
│
└── Django/
    ├── goitproject/
    ├── Dockerfile
    ├── Jenkinsfile
    ├── docker-compose.yaml
    ├── manage.py
    └── requirements.txt
```

---

## 2. Дані, які вже прописані в проєкті

```text
AWS Account ID: 731732766187
AWS region: us-west-2
ECR repo name: django-app
EKS cluster name: eks-cluster-demo
S3 backend bucket: terraform-state-bucket-solo
DynamoDB table: terraform-locks
DB name: goitdb
DB username: postgres
use_aurora: false
```

Ці значення зібрані у файлі:

```text
variables.tf
```

---

## 3. Що треба мати перед запуском

На комп’ютері мають бути встановлені:

```bash
aws --version
terraform version
kubectl version --client
helm version
docker --version
```

Також треба бути залогіненим в AWS:

```bash
aws sts get-caller-identity
```

Якщо команда показує твій AWS Account ID, значить AWS CLI працює.

---

## 4. Запуск інфраструктури

Перейди в папку фінального проєкту:

```bash
cd final-project
```

Відформатуй Terraform-файли:

```bash
terraform fmt -recursive
```

Ініціалізуй Terraform:

```bash
terraform init
```

Перевір конфігурацію:

```bash
terraform validate
```

Запусти створення інфраструктури:

```bash
terraform apply
```

Коли Terraform запитає підтвердження:

```text
Do you want to perform these actions?
```

напиши:

```bash
yes
```

---

## 5. Що створить Terraform

Terraform створить:

- S3 bucket для Terraform state
- DynamoDB table для lock
- VPC
- public subnets
- private subnets
- Internet Gateway
- NAT Gateway
- ECR repository
- EKS cluster
- EKS node group
- EBS CSI Driver
- RDS PostgreSQL, бо `use_aurora = false`
- Jenkins через Helm
- Argo CD через Helm
- Argo CD Application для Django
- Metrics Server
- Prometheus
- Grafana

---

## 7. Якщо ресурс уже існує

в AWS можуть вже існувати ресурси з такими самими іменами:

```text
terraform-state-bucket-solo
terraform-locks
django-app
eks-cluster-demo
```

Тоді Terraform може показати помилку типу:

```text
BucketAlreadyOwnedByYou
ResourceInUseException
RepositoryAlreadyExistsException
```

Це означає, що в AWS вже є ресурс із такою назвою.

Найпростіші варіанти:

1. Видалити старі ресурси через попередню Terraform-папку:

   ```bash
   terraform destroy
   ```

2. Або змінити імена у `variables.tf`, наприклад:
   ```hcl
   s3_backend_bucket = "terraform-state-bucket-solo-final"
   ecr_repo_name     = "django-app-final"
   eks_cluster_name  = "eks-cluster-demo-final"
   ```

---

## 8. Перевірка Kubernetes namespaces

Після завершення `terraform apply` перевір:

```bash
kubectl get nodes
```

Очікувано вузли мають бути в статусі:

```text
Ready
```

Далі перевір Jenkins:

```bash
kubectl get all -n jenkins
```

Перевір Argo CD:

```bash
kubectl get all -n argocd
```

Перевір monitoring:

```bash
kubectl get all -n monitoring
```

---

## 10. Перевірка Jenkins

Запусти port-forward:

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

Відкрий у браузері:

```text
http://localhost:8080
```

Логін:

```text
admin
```

Пароль:

kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo

```text
change-me-after-first-login
```

У реальному проєкті пароль не можна зберігати в GitHub. Але для навчального домашнього завдання це зроблено просто, щоб було легше перевірити роботу.

---

## 9. Що треба налаштувати в Jenkins для CI

У Jenkins треба створити credential для GitHub token.

Назва credential має бути строго:

```text
github-token
```

Тип:

```text
Username with password
```

- Username: твій GitHub username
- Password: GitHub token

Після цього створи Pipeline job або Multibranch Pipeline.

Якщо Jenkins питає шлях до Jenkinsfile, вкажи:

```text
final-project/Django/Jenkinsfile
```

Jenkinsfile робить 2 головні речі:

1. Збирає Docker image через Kaniko.
2. Пушить image в ECR.
3. Оновлює tag у файлі:
   ```text
   final-project/charts/django-app/values.yaml
   ```
4. Пушить зміну назад у гілку:
   ```text
   final-project
   ```

Після цього Argo CD побачить новий tag і оновить Django application у Kubernetes.

---

## 10. Перевірка Argo CD

Запусти port-forward:

```bash
kubectl port-forward svc/argocd-server 8081:80 -n argocd
```

Відкрий у браузері:

```text
https://localhost:8081
```

Логін:

```text
admin
```

Пароль отримай командою:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo
```

У Argo CD має бути application:

```text
django-app
```

Якщо Jenkins ще не збирав Docker image, Django pod може бути в статусі `ImagePullBackOff`. Це нормально для першого запуску. Після першого успішного Jenkins build образ з’явиться в ECR, Jenkins оновить tag у Helm chart, і Argo CD зможе задеплоїти актуальний образ.

---

## 11. Перевірка Django application

Перевір pod-и:

```bash
kubectl get pods
```

Перевір service:

```bash
kubectl get svc
```

Якщо service `django-app` має зовнішній LoadBalancer, можна відкрити його адресу в браузері.

Також можна перевірити через port-forward:

```bash
kubectl port-forward svc/django-app 8000:80
```

Відкрий:

```text
http://localhost:8000
```

Очікувано:

```text
Django app is running in the final DevOps project.
```

---

## 12. Перевірка Prometheus і Grafana

Grafana:

```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

Відкрий:

```text
http://localhost:3000
```

Логін:

```text
admin
```

Пароль:

```text
admin123
```

Prometheus datasource вже доданий у Grafana автоматично.

Також можна перевірити Prometheus напряму:

```bash
kubectl port-forward svc/prometheus-server 9090:80 -n monitoring
```

Відкрий:

```text
http://localhost:9090
```

---

## 13. Перевірка autoscaling

У Helm chart є файл:

```text
charts/django-app/templates/hpa.yaml
```

Він створює HorizontalPodAutoscaler.

Перевір HPA:

```bash
kubectl get hpa
```

Metrics Server встановлюється автоматично через module `monitoring`, тому HPA зможе отримувати CPU metrics.

---

## 14. Перемикання RDS / Aurora

За замовчуванням:

```hcl
use_aurora = false
```

Це означає, що створюється звичайний RDS PostgreSQL instance.

Якщо треба перевірити Aurora, зміни у `variables.tf`:

```hcl
default = true
```

для змінної:

```hcl
variable "use_aurora"
```

Або запусти так:

```bash
terraform apply -var="use_aurora=true"
```

Логіка модуля така:

- `use_aurora = false` → створюється `aws_db_instance`
- `use_aurora = true` → створюється `aws_rds_cluster` + writer instance + reader instance

---

## 15. Backend.tf і чому він закоментований

Файл `backend.tf` у проєкті є, але remote backend закоментований.

Причина проста: Terraform не може в перший запуск одночасно:

1. створити S3 bucket і DynamoDB table;
2. і вже використовувати їх для зберігання свого state.

Тому найнадійніший порядок такий:

1. Перший запуск:

   ```bash
   terraform init
   terraform apply
   ```

2. Після створення bucket/table можна розкоментувати backend у `backend.tf`.

3. Потім перенести state у S3:
   ```bash
   terraform init -migrate-state
   ```

---

## 16. Команди для швидкої перевірки

```bash
terraform fmt -recursive
terraform validate

kubectl get nodes
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
kubectl get hpa
```

Port-forward:

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
kubectl port-forward svc/argocd-server 8081:443 -n argocd
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

---

## 17. Видалення ресурсів після перевірки

Щоб не було зайвих витрат в AWS, після перевірки обов’язково видали ресурси:

```bash
terraform destroy
```

Підтверди:

```bash
yes
```

Перед destroy бажано переконатися, що `kubectl` ще підключений до EKS:

```bash
kubectl get nodes
```

Під час destroy Terraform спочатку видалить Helm releases і namespaces, а потім AWS-ресурси.

---
