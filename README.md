# DevOps CI/CD Project (Lesson 8–9)

Цей проєкт демонструє повний CI/CD pipeline з використанням:

- Terraform (AWS інфраструктура)
- EKS (Kubernetes)
- Jenkins (CI)
- Kaniko (build Docker image)
- AWS ECR (registry)
- Helm (deployment)
- Argo CD (CD)

---

# 🚀 1. Як запустити Terraform

### Перейти в папку проєкту

```bash
cd lesson-8-9
```

### Ініціалізувати Terraform

```bash
terraform init
```

### Запустити інфраструктуру

```bash
terraform apply
```

Підтвердити:

```bash
yes
```

---

# ☸️ 2. Підключення до Kubernetes

```bash
aws eks update-kubeconfig --region us-west-2 --name eks-cluster-demo
kubectl get nodes
```

Очікувано:

```
STATUS: Ready
```

---

# ⚙️ 3. Jenkins

### Доступ до Jenkins

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

Відкрити:

```
http://localhost:8080
```

---

### 🔑 Пароль Jenkins

```bash
kubectl get secret jenkins -n jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 -d
```

---

# 🔑 GitHub Token (для Jenkins)

1. GitHub → Settings → Developer settings → Personal access tokens
2. Створити token (scope: `repo`)
3. В Jenkins:
   - Manage Jenkins → Credentials
   - Додати Username + Password
   - ID: `github-token`

---

# 🔄 4. Як перевірити Jenkins Job

1. Відкрити Jenkins
2. Вибрати pipeline `lesson-8-9`
3. Натиснути **Build Now**

Очікувано:

- статус: `SUCCESS`

---

# 📦 5. Перевірка Docker image (ECR)

```bash
aws ecr list-images --repository-name django-app --region us-west-2
```

Очікувано:

```
build-1
build-2
build-3 ...
```

---

# 🚀 6. Argo CD

### Доступ до Argo CD

```bash
kubectl port-forward svc/argo-cd-argocd-server 8081:80 -n argocd
```

Відкрити:

```
http://localhost:8081
```

---

### 🔑 Пароль Argo CD

Логін:

```
admin
```

Пароль:

```bash
kubectl get secret argo-cd-argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

---

# 📊 7. Як перевірити результат в Argo CD

```bash
kubectl get applications -n argocd
kubectl describe application django-app -n argocd
```

Очікувано:

```
Sync Status: Synced
Health: Healthy
```

---

# 🔁 Як працює CI/CD

1. Ти запускаєш Jenkins job
2. Jenkins:
   - будує Docker image
   - пушить в ECR
   - оновлює `values.yaml`

3. GitHub отримує commit
4. Argo CD бачить зміни
5. Kubernetes автоматично оновлює додаток

---

# 🧪 8. Перевірка в Kubernetes

```bash
kubectl get pods
kubectl get svc
```

---

# 🧹 9. Видалення інфраструктури

```bash
terraform destroy
```

---

# ✅ Результат

- Працюючий CI/CD pipeline
- Автоматичний деплой через Argo CD
- Інтеграція AWS + Kubernetes + Jenkins
