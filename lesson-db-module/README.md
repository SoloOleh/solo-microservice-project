# DevOps Project + Lesson 10 RDS Module

Цей проєкт містить:

- Інфраструктуру з попередніх модулів:
  - Terraform
  - AWS VPC
  - EKS
  - ECR
  - Jenkins
  - Argo CD
- Модуль з Lesson 10:
  - універсальний Terraform-модуль `rds`
  - підтримка **звичайного RDS**
  - підтримка **Aurora Cluster**

---

# Важливо

Цей проєкт НЕ запускається коректно з нуля одним `terraform apply`.

Причина:
у root-конфігурації є блоки, які звертаються до EKS ще до того, як кластер створений:

- `data.aws_eks_cluster`
- `data.aws_eks_cluster_auth`
- `provider "kubernetes"`
- `provider "helm"`
- `module "jenkins"`
- `module "argo_cd"`

Тому запуск треба робити **у 2 етапи**.

Правильний порядок роботи з цим проєктом:

1. Підготувати AWS CLI / Terraform / kubectl
2. Етап 1: підняти базову AWS інфраструктуру
3. Підключити kubeconfig до EKS
4. Етап 2: підняти Jenkins і Argo CD
5. Перевірити Lesson 10:
   - `use_aurora = false`
   - `use_aurora = true`

Такий сценарій відповідає реальній структурі проєкту і не ламається через залежність від ще не створеного EKS cluster.

---

# 1. Що треба мати перед стартом

Перевір, що в тебе встановлено:

- AWS CLI
- Terraform
- kubectl
- доступ до AWS акаунта
- налаштований AWS профіль

Перевірка:

```bash
aws sts get-caller-identity
terraform version
kubectl version --client
```

---

# 2. Перейти в папку проєкту

```bash
cd lesson-db-module
```

---

# 3. Етап 1 — створення базової AWS інфраструктури

На цьому етапі треба створити:

- `s3_backend`
- `vpc`
- `ecr`
- `eks`
- `rds`

Але **ще не запускати** блоки, які залежать від готового EKS API:

- `data.aws_eks_cluster`
- `data.aws_eks_cluster_auth`
- `provider "kubernetes"`
- `provider "helm"`
- `module "jenkins"`
- `module "argo_cd"`

## Як зробити

Тимчасово прибери або закоментуй у `main.tf`:

- `data "aws_eks_cluster" "eks"`
- `data "aws_eks_cluster_auth" "eks"`
- `provider "kubernetes"`
- `provider "helm"`
- `module "jenkins"`
- `module "argo_cd"`

В `outputs.tf` є outputs, які посилаються на:

- `module.jenkins`
- `module.argo_cd`

їх теж треба тимчасово прибрати або закоментувати.

## Потім запусти

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform apply
```

Підтверди:

```bash
yes
```

## Що має створитися

- S3 bucket для state
- DynamoDB table для lock
- VPC
- public/private subnet
- Internet Gateway
- NAT Gateway
- ECR repository
- EKS cluster
- EKS node group
- RDS або Aurora — залежно від `use_aurora`

---

# 4. Підключення до EKS після створення кластера

Після успішного створення EKS запусти:

```bash
aws eks update-kubeconfig --region us-west-2 --name eks-cluster-demo
kubectl get nodes
```

Очікувано:

```bash
STATUS: Ready
```

---

# 5. Етап 2 — Jenkins і Argo CD

Тепер поверни назад у `main.tf`:

- `data "aws_eks_cluster" "eks"`
- `data "aws_eks_cluster_auth" "eks"`
- `provider "kubernetes"`
- `provider "helm"`
- `module "jenkins"`
- `module "argo_cd"`

І поверни назад в `outputs.tf` outputs для:

- Jenkins
- Argo CD

Потім знову запусти:

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform apply
```

Підтверди:

```bash
yes
```

---

# 6. Перевірка Jenkins

Запусти port-forward:

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

Відкрий у браузері:

```text
http://localhost:8080
```

Отримати пароль Jenkins:

```bash
kubectl get secret jenkins -n jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 -d
```

---

# 7. Перевірка Argo CD

Запусти port-forward:

```bash
kubectl port-forward svc/argo-cd-argocd-server 8081:80 -n argocd
```

Відкрий у браузері:

```text
http://localhost:8081
```

Логін:

```text
admin
```

Пароль:

```bash
kubectl get secret argo-cd-argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

---

# 8. Перевірка Lesson 10 — модуль RDS

Модуль `rds` підтримує 2 режими:

- `use_aurora = false` → звичайний RDS instance
- `use_aurora = true` → Aurora Cluster + writer + reader(s)

---

# 9. Перевірка звичайного RDS

У `main.tf` в блоці `module "rds"`:

```hcl
use_aurora = false
```

Рекомендовано для перевірки:

```hcl
instance_class = "db.t3.micro"
multi_az       = false
```

Потім запусти:

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

## Що має бути в плані

Повинні бути ресурси:

- `aws_db_instance`
- `aws_db_subnet_group`
- `aws_security_group`
- `aws_db_parameter_group`

---

# 10. Перевірка Aurora

У `main.tf` в блоці `module "rds"`:

```hcl
use_aurora = true
```

Потім запусти:

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

## Що має бути в плані

Повинні бути ресурси:

- `aws_rds_cluster`
- `aws_rds_cluster_instance`
- `aws_rds_cluster_parameter_group`
- `aws_db_subnet_group`
- `aws_security_group`

---

# 11. Приклад використання модуля RDS

```hcl
module "rds" {
  source = "./modules/rds"

  name                  = "myapp-db"
  use_aurora            = false
  aurora_instance_count = 2

  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  engine_cluster                = "aurora-postgresql"
  engine_version_cluster        = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"

  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "myapp"
  username                = "postgres"
  password                = "admin123AWS23"
  subnet_private_ids      = module.vpc.private_subnets
  subnet_public_ids       = module.vpc.public_subnets
  publicly_accessible     = false
  vpc_id                  = module.vpc.vpc_id
  multi_az                = false
  backup_retention_period = 7
  allowed_cidr_blocks     = ["0.0.0.0/0"]

  parameters = {
    max_connections = "200"
    log_statement   = "ddl"
    work_mem        = "4096"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

---

# 12. Як змінити тип бази

## Для звичайного PostgreSQL RDS

```hcl
use_aurora     = false
engine         = "postgres"
engine_version = "17.2"
```

## Для звичайного MySQL RDS

```hcl
use_aurora     = false
engine         = "mysql"
engine_version = "8.0"
```

## Для Aurora PostgreSQL

```hcl
use_aurora             = true
engine_cluster         = "aurora-postgresql"
engine_version_cluster = "15.3"
```

## Для Aurora MySQL

```hcl
use_aurora             = true
engine_cluster         = "aurora-mysql"
engine_version_cluster = "8.0.mysql_aurora.3.05.2"
```

---

# 13. Як змінити клас інстансу

Приклад:

```hcl
instance_class = "db.t3.micro"
```

Інші приклади:

```hcl
instance_class = "db.t3.small"
instance_class = "db.t3.medium"
```

> Для реального `apply` завжди перевіряй сумісність класу з engine і регіоном.

---

# 14. Як видалити інфраструктуру

```bash
terraform destroy
```

Підтверди:

```bash
yes
```

---
