#!/bin/bash

set -e

echo "Початок роботи..."

check_python_version() {
  python3 - <<'PY'
import sys
sys.exit(0 if sys.version_info >= (3, 9) else 1)
PY
}

ensure_local_bin_in_path() {
  if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  fi

  export PATH="$HOME/.local/bin:$PATH"
}

ensure_local_bin_in_path

# Docker
if command -v docker >/dev/null 2>&1; then
  echo "Docker вже встановлений: $(docker --version)"
else
  echo "Встановлюю Docker..."
  sudo apt-get update
  sudo apt-get install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
  echo "Docker встановлено."
fi

# Docker Compose
if docker compose version >/dev/null 2>&1; then
  echo "Docker Compose вже встановлений: $(docker compose version)"
elif command -v docker-compose >/dev/null 2>&1; then
  echo "Docker Compose вже встановлений: $(docker-compose --version)"
else
  echo "Встановлюю Docker Compose..."
  sudo apt-get update

  if apt-cache show docker-compose-plugin >/dev/null 2>&1; then
    sudo apt-get install -y docker-compose-plugin
    echo "Docker Compose plugin встановлено."
  else
    echo "docker-compose-plugin недоступний. Пробую встановити docker-compose..."
    sudo apt-get install -y docker-compose
    echo "Docker Compose встановлено: $(docker-compose --version)"
  fi
fi

# Python
if command -v python3 >/dev/null 2>&1 && check_python_version; then
  echo "Python вже встановлений: $(python3 --version)"
else
  echo "Встановлюю Python..."
  sudo apt-get update
  sudo apt-get install -y python3 python3-pip python3-venv

  if check_python_version; then
    echo "Python встановлено: $(python3 --version)"
  else
    echo "Помилка: потрібен Python 3.9 або новіший."
    exit 1
  fi
fi

# pip
if command -v pip3 >/dev/null 2>&1; then
  echo "pip вже встановлений: $(pip3 --version)"
else
  echo "Встановлюю pip..."
  sudo apt-get update
  sudo apt-get install -y python3-pip
fi

ensure_local_bin_in_path

# Django
if python3 -m django --version >/dev/null 2>&1; then
  echo "Django вже встановлений: $(python3 -m django --version)"
else
  echo "Встановлюю Django..."

  if python3 -m pip install Django --break-system-packages; then
    echo "Django встановлено: $(python3 -m django --version)"
  else
    echo "Повторюю встановлення Django без --break-system-packages..."
    python3 -m pip install Django
    echo "Django встановлено: $(python3 -m django --version)"
  fi
fi

echo "Перевірка доступності команд..."
if command -v django-admin >/dev/null 2>&1; then
  echo "django-admin доступний: $(django-admin --version)"
fi

if command -v sqlformat >/dev/null 2>&1; then
  echo "sqlformat доступний."
fi

echo "Готово. Усі потрібні інструменти встановлені або вже були в системі."