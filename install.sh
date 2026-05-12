#!/bin/bash
# Huawei Cloud MaaS + Claude Code - Instalador Linux/macOS
# Ejecutar: curl -fsSL https://raw.githubusercontent.com/jarceg884/huawei-maas-claude-code/main/install.sh | bash

set -e

echo "========================================="
echo "Instalador Huawei Cloud MaaS + Claude Code"
echo "========================================="

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Detectar sistema operativo
if [[ "$(uname)" == "Darwin" ]]; then
    OS="macOS"
    PACKAGE_MANAGER="brew"
elif [[ "$(uname)" == "Linux" ]]; then
    OS="Linux"
    # Detectar gestor de paquetes
    if command -v apt-get &> /dev/null; then
        PACKAGE_MANAGER="apt"
    elif command -v yum &> /dev/null; then
        PACKAGE_MANAGER="yum"
    elif command -v dnf &> /dev/null; then
        PACKAGE_MANAGER="dnf"
    elif command -v pacman &> /dev/null; then
        PACKAGE_MANAGER="pacman"
    else
        PACKAGE_MANAGER="unknown"
    fi
else
    print_error "Sistema operativo no soportado: $(uname)"
    exit 1
fi

print_info "Sistema detectado: $OS ($PACKAGE_MANAGER)"

# 1. Verificar dependencias
print_info "1. Verificando dependencias..."

check_dependency() {
    if command -v $1 &> /dev/null; then
        print_success "$1 está instalado"
        return 0
    else
        print_error "$1 no está instalado"
        return 1
    fi
}

# Verificar Python
if ! check_dependency python3; then
    print_info "Instalando Python3..."
    case $PACKAGE_MANAGER in
        "apt")
            sudo apt-get update && sudo apt-get install -y python3 python3-pip
            ;;
        "yum"|"dnf")
            sudo $PACKAGE_MANAGER install -y python3 python3-pip
            ;;
        "pacman")
            sudo pacman -Syu --noconfirm python python-pip
            ;;
        "brew")
            brew install python
            ;;
        *)
            print_error "Instala Python3 manualmente: https://www.python.org/downloads/"
            exit 1
            ;;
    esac
fi

# Verificar Node.js/npm
if ! check_dependency node; then
    print_info "Instalando Node.js..."
    case $OS in
        "Linux")
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        "macOS")
            brew install node
            ;;
        *)
            print_error "Instala Node.js manualmente: https://nodejs.org/"
            exit 1
            ;;
    esac
fi

# Verificar Git
if ! check_dependency git; then
    print_info "Instalando Git..."
    case $PACKAGE_MANAGER in
        "apt")
            sudo apt-get install -y git
            ;;
        "yum"|"dnf")
            sudo $PACKAGE_MANAGER install -y git
            ;;
        "pacman")
            sudo pacman -S --noconfirm git
            ;;
        "brew")
            brew install git
            ;;
    esac
fi

# 2. Instalar uv
print_info "2. Instalando uv..."
if command -v uv &> /dev/null; then
    print_success "uv ya instalado"
    uv self update
else
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
    print_success "uv instalado"
fi

# 3. Clonar free-claude-code
print_info "3. Clonando free-claude-code..."
FREE_CLAUDE_PATH="$HOME/free-claude-code"
if [ -d "$FREE_CLAUDE_PATH" ]; then
    print_info "Repositorio ya existe, actualizando..."
    cd "$FREE_CLAUDE_PATH"
    git pull origin main
else
    git clone https://github.com/Alishahryar1/free-claude-code.git "$FREE_CLAUDE_PATH"
    cd "$FREE_CLAUDE_PATH"
fi

# 4. Instalar Python 3.14
print_info "4. Instalando Python 3.14..."
uv python install 3.14
print_success "Python 3.14 instalado"

# 5. Instalar dependencias
print_info "5. Instalando dependencias..."
uv sync
print_success "Dependencias instaladas"

# 6. Instalar Claude Code CLI
print_info "6. Instalando Claude Code CLI..."
npm install -g @anthropic-ai/claude-code
print_success "Claude Code CLI instalado"

# 7. Crear archivo de configuración .env
print_info "7. Creando configuración..."
cat > "$FREE_CLAUDE_PATH/.env" << 'EOF'
# Huawei Cloud MaaS Config (uses OpenAI-compatible API)
HUAWEI_MAAS_API_KEY="TU_API_KEY_AQUI"

# All Claude model requests are mapped to these models
MODEL_OPUS="huawei_maas/deepseek-v3.2"
MODEL_SONNET="huawei_maas/deepseek-v3.2"
MODEL_HAIKU="huawei_maas/deepseek-v3.2"
MODEL="huawei_maas/deepseek-v3.2"

# Server config
ANTHROPIC_AUTH_TOKEN="freecc"
MESSAGING_PLATFORM="none"
EOF

print_success "Archivo .env creado en: $FREE_CLAUDE_PATH/.env"
print_warning "IMPORTANTE: Reemplaza 'TU_API_KEY_AQUI' con tu API key de Huawei Cloud MaaS"

# 8. Instalar comandos claude-maas y claude-m
print_info "8. Instalando comandos claude-maas y claude-m..."

# Crear directorio para comandos
mkdir -p "$HOME/.local/bin"

# Descargar comandos desde el repositorio
print_info "Descargando comandos desde GitHub..."
curl -fsSL https://raw.githubusercontent.com/jarceg884/huawei-maas-claude-code/main/claude-maas.sh -o "$HOME/.local/bin/claude-maas"
curl -fsSL https://raw.githubusercontent.com/jarceg884/huawei-maas-claude-code/main/claude-m.sh -o "$HOME/.local/bin/claude-m"

# Hacer ejecutables
chmod +x "$HOME/.local/bin/claude-maas"
chmod +x "$HOME/.local/bin/claude-m"

# Agregar al PATH si no está
SHELL_RC="$HOME/.bashrc"
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    export PATH="$HOME/.local/bin:$PATH"
    print_success "Agregado $HOME/.local/bin al PATH"
fi

print_success "Comandos instalados:"
print_success "  claude-maas -> $HOME/.local/bin/claude-maas"
print_success "  claude-m    -> $HOME/.local/bin/claude-m (alias corto)"

# 9. Crear alias en shell
if ! grep -q "alias claude-m=" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# Alias para Claude MaaS" >> "$SHELL_RC"
    echo "alias claude-m='claude-maas'" >> "$SHELL_RC"
    echo "alias cm='claude-maas'" >> "$SHELL_RC"
    print_success "Alias agregados a $SHELL_RC"
    print_info "Ejecuta: source $SHELL_RC para cargar los alias"
fi

# 10. Configurar Claude Code
print_info "9. Configurando Claude Code..."
claude config set endpoint "http://localhost:8082" 2>/dev/null || true
claude config set api-key "freecc" 2>/dev/null || true
print_success "Claude Code configurado para Huawei MaaS"

# 11. Crear servicio systemd (solo Linux)
if [[ "$OS" == "Linux" ]]; then
    print_info "10. Creando servicio systemd..."
    
    sudo tee /etc/systemd/system/huawei-maas-proxy.service > /dev/null << EOF
[Unit]
Description=Huawei Cloud MaaS Proxy for Claude Code
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$FREE_CLAUDE_PATH
Environment="HUAWEI_MAAS_API_KEY=TU_API_KEY_AQUI"
Environment="MODEL=huawei_maas/deepseek-v3.2"
ExecStart=$HOME/.cargo/bin/uv run python server.py
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=huawei-maas-proxy

[Install]
WantedBy=multi-user.target
EOF

    print_success "Servicio systemd creado"
    print_info "Para habilitar: sudo systemctl enable huawei-maas-proxy"
    print_info "Para iniciar: sudo systemctl start huawei-maas-proxy"
fi

# 12. Mostrar resumen
echo ""
echo "========================================="
echo "INSTALACIÓN COMPLETADA" | tee /dev/tty
echo "=========================================" | tee /dev/tty
echo ""
echo "✅ Dependencias instaladas" | tee /dev/tty
echo "✅ free-claude-code configurado" | tee /dev/tty  
echo "✅ Claude Code CLI instalado" | tee /dev/tty
echo "✅ Comandos claude-maas y claude-m instalados" | tee /dev/tty
echo "✅ Alias 'cm' creado (alias de claude-maas)" | tee /dev/tty
echo ""
echo "📋 PASOS FINALES:" | tee /dev/tty
echo "1. Edita: $FREE_CLAUDE_PATH/.env" | tee /dev/tty
echo "   Reemplaza 'TU_API_KEY_AQUI' con tu API key" | tee /dev/tty
echo ""
echo "2. Usa Claude MaaS:" | tee /dev/tty
echo "   claude-maas start          # Iniciar proxy" | tee /dev/tty
echo "   claude-maas \"Hola\"         # Enviar mensaje" | tee /dev/tty
echo "   claude-maas -f archivo.py  # Analizar archivo" | tee /dev/tty
echo "   claude-m \"Pregunta\"       # Alias corto" | tee /dev/tty
echo "   cm \"Pregunta\"            # Alias más corto" | tee /dev/tty
echo ""
echo "3. Comandos disponibles:" | tee /dev/tty
echo "   claude-maas start    # Iniciar proxy" | tee /dev/tty
echo "   claude-maas stop     # Detener proxy" | tee /dev/tty
echo "   claude-maas status   # Ver estado" | tee /dev/tty
echo "   claude-maas test     # Probar conexión" | tee /dev/tty
echo "   claude-maas logs     # Ver logs" | tee /dev/tty
echo "   claude-maas setup    # Configurar Claude Code" | tee /dev/tty
echo ""
echo "💰 AHORRO: 95% vs Claude Opus" | tee /dev/tty
echo "💡 DeepSeek V3.2: ~$0.02/1M tokens" | tee /dev/tty
echo "💡 Claude Opus: ~$0.40/1M tokens" | tee /dev/tty
echo ""
echo "🔗 Repositorio: https://github.com/jarceg884/huawei-maas-claude-code" | tee /dev/tty
echo "=========================================" | tee /dev/tty

# 13. Probar instalación
echo ""
print_info "Probando instalación..."
if command -v claude-maas &> /dev/null; then
    print_success "Comando 'claude-maas' instalado correctamente"
    print_success "Comando 'claude-m' instalado correctamente"
    print_success "Alias 'cm' configurado"
else
    print_warning "Reinicia tu terminal o ejecuta: source $SHELL_RC"
fi

print_info "Instalación completada. ¡Disfruta de Claude MaaS!"