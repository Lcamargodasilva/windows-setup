# 🖥️ Windows Setup Automatizado (Winget)

Este repositório fornece um **setup automatizado para Windows 10/11**, utilizando **Winget (nativo do Windows)**, com foco em:

- Pós-formatação rápida
- Zero dependência de Git
- Execução com **apenas um comando**
- Perfis separados (Usuário, Suporte TI, Dev Frontend, Dev Backend, DevOps)
- Menus interativos para escolher **o que instalar**

---

## 🎯 Objetivo

Após formatar o computador, o usuário só precisa:

1. Abrir o **PowerShell**
2. Colar **um comando**
3. Escolher os softwares no menu

👉 O script baixa automaticamente todos os arquivos necessários do GitHub e inicia a instalação.

---

## ✅ Requisitos

- Windows 10 ou Windows 11
- Winget instalado (App Installer)

Verificar:
```powershell
winget --version
````

> 💡 **Observação:**
> Em ambientes como **Windows Sandbox**, a Microsoft Store pode estar indisponível.
> Este projeto força o uso da fonte `winget`, evitando erros da fonte `msstore`.

---

## 🚀 Uso rápido (one-liner)

Abra o **PowerShell (preferencialmente como Administrador)** e execute:

```powershell
iwr -useb https://raw.githubusercontent.com/Lcamargodasilva/windows-setup/main/setup.ps1 | iex
```

Isso irá:

* Criar um cache local em `%TEMP%\windows-setup`
* Baixar todos os scripts (`lib` + `profiles`)
* Exibir o **menu principal**

---

## 🧭 Menu principal

Ao executar, você verá algo como:

```
Windows Setup (Winget) — Menu Principal

1) Básicos (Usuário)
2) Suporte de TI
3) Dev Frontend
4) Dev Backend
5) DevOps / Infra
0) Sair
```

Cada opção leva para um **submenu específico**.

---

## 📦 Perfis e menus

### 👤 Básicos (Usuário)

Softwares comuns para qualquer usuário, com opção de instalar **um por um** ou **todos**:

* Google Chrome
* Mozilla Firefox
* Brave
* 7-Zip
* WinRAR
* VLC
* Adobe Reader
* Notepad++
* PowerToys
* Windows Terminal
* Everything
* ShareX

Menu exemplo:

```
0) Voltar
1) Instalar Google.Chrome
2) Instalar Mozilla.Firefox
...
A) Instalar TODOS
U) Atualizar tudo
```

---

### 🛠️ Suporte de TI

Ferramentas comuns para suporte técnico:

* Sysinternals
* Wireshark
* PuTTY
* RustDesk
* AnyDesk
* Navegadores
* Utilitários básicos

---

### 🎨 Dev Frontend

Ambiente para desenvolvimento frontend:

* Git
* VS Code
* Windows Terminal
* Node.js LTS
* Chrome / Firefox
* Postman
* Docker Desktop
* GitHub CLI

---

### 🧑‍💻 Dev Backend

Ambiente completo para backend:

* Git
* VS Code
* Windows Terminal
* Postman
* Docker Desktop
* Node.js LTS
* Python 3.12
* Java JDK 21
* DBeaver
* GitHub CLI

---

### ☁️ DevOps / Infra

Ferramentas para DevOps e infraestrutura:

* Terraform
* kubectl
* Helm
* Docker Desktop
* GitHub CLI
* AWS CLI
* Azure CLI
* Google Cloud SDK
* Windows Terminal

---

## 🔄 Atualização de pacotes

Em todos os submenus existe a opção:

```
U) Atualizar tudo
```

Ela executa internamente:

```
winget upgrade --all --source winget
```

---

## 🔐 Segurança

* Repositório público e auditável
* Nenhuma ação destrutiva
* Apenas comandos Winget:

  * `winget install`
  * `winget upgrade`
* Scripts baixados **exclusivamente** do próprio repositório do projeto

---

## 🧠 Boas práticas

* Execute logo após formatar o Windows
* Ajuste os pacotes conforme sua realidade
* [Versonamento](https://github.com/Lcamargodasilva/windows-setup/blob/main/CHANGELOG.md)
* Ideal para:

  * Uso pessoal
  * Times de TI
  * Padronização de máquinas
  * Ambientes corporativos

---

## Autor

[<img src="https://github.com/Lcamargodasilva.png" width="100" alt="Lcamargodasilva">](https://www.github.com/Lcamargodasilva)
