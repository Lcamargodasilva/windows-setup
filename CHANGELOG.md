# Changelog

Todas as mudanças relevantes deste projeto serão documentadas aqui.

Este projeto segue:
- **Keep a Changelog**
- **Semantic Versioning (SemVer)**

---

## [1.0.1] - 2026-02-06
### 🐛 Corrigido
- Correção de loop infinito ao sair do menu principal
- Ajuste de compatibilidade com execução via `iwr | iex`
- Correção de erro de `ExecutionPolicy` ao executar scripts baixados
- Forçado uso da fonte `winget` para evitar falhas da fonte `msstore`
- Correção do bug de *closure* nos menus (cada opção instala o pacote correto)
- Ordenação correta dos itens numéricos nos menus (1, 2, 10, 11…)

---

## [1.0.0] - 2026-02-04
### ✨ Adicionado
- Script principal `setup.ps1` com função de **bootstrap**
- Execução via PowerShell com **apenas um comando**
- Download automático dos scripts auxiliares a partir do GitHub (RAW)
- Criação de cache local em `%TEMP%\windows-setup`
- Menu principal interativo com perfis:
  - Básicos (Usuário)
  - Suporte de TI
  - Desenvolvedor Frontend
  - Desenvolvedor Backend
  - DevOps / Infraestrutura
- Submenus por perfil com:
  - Instalação individual de softwares
  - Opção para instalar todos
  - Opção para atualizar todos os pacotes
- Biblioteca compartilhada `lib/winget.ps1`
- Uso exclusivo do **Winget** (nativo do Windows)

### 🧠 Decisões técnicas
- Nenhuma dependência de Git ou clone de repositório
- Scripts auditáveis e públicos
- Separação clara de responsabilidades:
  - `setup.ps1`: bootstrap e navegação
  - `profiles/*.ps1`: lógica por perfil
  - `lib/winget.ps1`: funções reutilizáveis

---

## [Unreleased]
### 🔮 Planejado
- Instalação opcional de WSL + Ubuntu
- Configuração automática do Git (user.name / user.email)
- Instalação de extensões do VS Code
- Execução não interativa (modo silencioso)
- Perfil corporativo (proxy / restrições de rede)
- Versionamento por tags e releases no GitHub

---
