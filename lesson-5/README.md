# Terraform AWS Infrastructure — lesson-5

## Опис проєкту

Цей проєкт створює інфраструктуру AWS за допомогою Terraform.

У проєкті реалізовано:

- S3 backend для збереження Terraform state
- DynamoDB для блокування state
- VPC з публічними та приватними підмережами
- Internet Gateway для публічних підмереж
- NAT Gateway для приватних підмереж
- ECR репозиторій для зберігання Docker-образів

## Структура проєкту

```text
lesson-5/
│
├── main.tf
├── backend.tf
├── outputs.tf
├── README.md
├── .gitignore
│
├── modules/
│   │
│   ├── s3-backend/
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── vpc/
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── ecr/
│       ├── ecr.tf
│       ├── variables.tf
│       └── outputs.tf
```

## Опис модулів

### s3-backend

Модуль створює:

- S3 bucket для Terraform state
- DynamoDB table для блокування state
- versioning для S3 bucket

### vpc

Модуль створює:

- VPC
- 3 public subnets
- 3 private subnets
- Internet Gateway
- NAT Gateway
- route tables та associations

### ecr

Модуль створює:

- ECR repository
- image scanning on push
- policy для репозиторію

## Перший запуск проєкту

Оскільки S3 backend не може створити свій бакет у той самий момент, коли Terraform вже намагається використовувати його для state, перший запуск виконується у 2 етапи:

1. Тимчасово вимкнути або закоментувати `backend.tf`
2. Ініціалізувати Terraform і створити S3 bucket та DynamoDB table
3. Повернути `backend.tf`
4. Мігрувати локальний state у S3 backend

Команди:

```bash
mv backend.tf backend.tf.disabled
terraform init
terraform apply
mv backend.tf.disabled backend.tf
rm -rf .terraform
terraform init -migrate-state
```

## Команди для подальшої роботи

### Ініціалізація Terraform

```bash
terraform init
```

### Перегляд плану

```bash
terraform plan
```

### Створення або оновлення ресурсів

```bash
terraform apply
```

### Видалення ресурсів

```bash
terraform destroy
```

### Очистити локальну службову частину Terraform

```bash
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f terraform.tfstate terraform.tfstate.backup
```

## Backend

У проєкті використовується S3 backend для збереження Terraform state та DynamoDB для блокування state.

## Outputs

Після виконання `terraform apply` виводяться:

- ім'я S3 bucket
- ім'я DynamoDB table
- URL ECR repository
- ID VPC
