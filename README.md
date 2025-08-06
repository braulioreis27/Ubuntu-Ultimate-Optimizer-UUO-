# Ubuntu Ultimate Optimizer (UUO) 🚀

![Banner](https://user-images.githubusercontent.com/3280/123456789-bb9c8d00-d5e8-11eb-9f3a-1234567890ab.png) *(opcional: incluir um banner depois)*

O **Ubuntu Ultimate Optimizer (UUO)** é um script completo para gerenciamento, otimização e personalização de sistemas Ubuntu através do terminal. Tudo em um só lugar!

## 📦 Recursos

### 🔄 Atualização do Sistema
- Atualização completa (update, upgrade, dist-upgrade)
- Limpeza automática (autoremove, autoclean)

### 📦 Gerenciamento de Pacotes
- Instalação via:
  - **APT** (repositórios tradicionais)
  - **Flatpak** (com integração Flathub)
  - **Snap** (com suporte a pacotes populares)

### ⚡ Otimizações
- **Desempenho:**
  - Ajuste de swappiness (10)
  - Configuração para SSDs:
    - Desativação de swapfile
    - TRIM automático diário
  - CPU Governor (performance mode)
  - Pré-carregamento com Preload

- **Configurações:**
  - Definir aplicativos padrão (Chrome, VLC)
  - Ativar firewall (UFW)
  - Mostrar programas ocultos

### 🛠️ Ferramentas
- Instalação automática de:
  - Wine (com suporte a 32/64 bits)
  - Codecs multimídia
  - Ferramentas de desenvolvimento
  - Utilitários de monitoramento

## 🚀 Como Usar

1. Baixe o script:
```bash
wget https://raw.githubusercontent.com/seu-usuario/ubuntu-ultimate-optimizer/main/uuoptimizer.sh
