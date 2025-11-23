# FitFlow - Health & Wellness Tracker

![Badge em Desenvolvimento](http://img.shields.io/static/v1?label=STATUS&message=EM%20DESENVOLVIMENTO&color=GREEN&style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Django](https://img.shields.io/badge/django-%23092E20.svg?style=for-the-badge&logo=django&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)

O **FitFlow** é uma aplicação Fullstack completa para rastreamento de hábitos saudáveis. O objetivo é permitir que o usuário registre e monitore sua hidratação, sono, exercícios e alimentação, visualizando seu progresso através de gráficos interativos.

O projeto consiste em uma API robusta construída com **Django REST Framework** e um aplicativo móvel moderno e responsivo desenvolvido em **Flutter**.

---

## Funcionalidades

- [x] **Autenticação Completa**: Login, Cadastro e Recuperação de Senha (via código OTP 6 dígitos).
- [x] **Dashboard Interativa**: Resumo diário, cronômetro de exercícios em tempo real.
- [x] **Registro de Atividades**:
  - Hidratação (com atalhos rápidos).
  - Sono (slider de horas).
  - Exercícios (tipo, duração e intensidade).
  - Refeições.
- [x] **Gráficos e Relatórios**: Histórico dos últimos 7 dias visualizado com `fl_chart`.
- [x] **Gerenciamento de Metas**: Definição de objetivos personalizados.
- [x] **Modo Escuro (Dark Mode)**: Interface moderna e agradável.

---

## Tecnologias Utilizadas

### Backend (API)
- **Linguagem:** Python 3.10+
- **Framework:** Django 5 & Django REST Framework (DRF)
- **Autenticação:** dj-rest-auth, django-allauth (Token Authentication)
- **Banco de Dados:** SQLite (Desenvolvimento)

### Frontend (Mobile)
- **Framework:** Flutter (Dart)
- **Gerenciamento de Requisições:** Dio
- **Gráficos:** fl_chart
- **Armazenamento Local:** flutter_secure_storage (para tokens JWT)
- **Design:** Google Fonts (Poppins), Material Design 3

---


## Como rodar o projeto

Este repositório é um **Monorepo**. Você precisará de dois terminais abertos: um para o Backend e outro para o Frontend.

### Pré-requisitos
- Python instalado.
- Flutter SDK instalado.
- Git.

### 1. Configurando o Backend (Django)

```bash
# Clone o repositório
git clone https://github.com/Gabriel-Ls2/FitFlow-Fullstack.git
cd fitflow

# Crie um ambiente virtual
python -m venv venv

# Ative o ambiente virtual
# No Windows:
venv\Scripts\activate
# No Mac/Linux:
source venv/bin/activate

# Instale as dependências
pip install django djangorestframework django-cors-headers dj-rest-auth django-allauth requests

# Realize as migrações do banco de dados
python manage.py migrate

# Crie um superusuário (Opcional, para acessar o /admin)
python manage.py createsuperuser

# Inicie o servidor
python manage.py runserver

### 2. Configurando o Frontend (Flutter)

# Em outro terminal 
cd app_fitflow

# Instale as dependências do Flutter
flutter pub get

# Configure os ícones (Opcional)
dart run flutter_launcher_icons

# Execute o aplicativo
# Para rodar no Navegador (Chrome):
flutter run -d chrome


Recuperação de Senha (Dev Mode)
Como o projeto está em modo de desenvolvimento, o envio de e-mail está configurado para o Console. Ao solicitar a recuperação de senha no App:

1. Verifique o terminal onde o Django está rodando.

2. O código de 6 dígitos aparecerá impresso lá.