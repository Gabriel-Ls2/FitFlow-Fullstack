#!/usr/bin/env bash
# Sair se der erro
set -o errexit

pip install -r requirements.txt

python manage.py collectstatic --no-input
python manage.py migrate