#!/bin/bash
# Script de instalación automática para Huawei Cloud MaaS + Claude Code
# Autor: jarceg884
# Fecha: $(date)

set -e

echo "========================================="
echo "Instalador Huawei Cloud MaaS + Claude Code"
echo "========================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Verificar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then 
    print_info "Ejecutando como usuario normal (recomendado)"
else
    print_info "Ejecutando como root"
fi

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

# Verificar dependencias esenciales
check_dependency git || {
    print_info "Instalando git..."
    apt-get update && apt-get install -y git
}

check_dependency curl || {
    print_info "Instalando curl..."
    apt-get install -y curl
}

# 2. Instalar Node.js y npm si no están
print_info "2. Verificando Node.js..."
if ! command -v node &> /dev/null; then
    print_info "Instalando Node.js 20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
    print_success "Node.js instalado: $(node --version)"
else
    print_success "Node.js ya instalado: $(node --version)"
fi

# 3. Instalar uv y Python 3.14
print_info "3. Instalando uv y Python 3.14..."
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
    print_success "uv instalado"
else
    print_success "uv ya instalado"
fi

uv self update
uv python install 3.14
print_success "Python 3.14 instalado"

# 4. Clonar free-claude-code
print_info "4. Clonando free-claude-code..."
cd ~
if [ -d "free-claude-code" ]; then
    print_info "Actualizando repositorio existente..."
    cd free-claude-code
    git pull origin main
else
    git clone https://github.com/Alishahryar1/free-claude-code.git
    cd free-claude-code
fi

# 5. Aplicar parches para Huawei Cloud MaaS
print_info "5. Aplicando parches para Huawei Cloud MaaS..."

# Crear directorio del proveedor Huawei MaaS
mkdir -p providers/huawei_maas

# Copiar archivos del proveedor Huawei MaaS desde el directorio temporal
if [ -d "/root/free-claude-code/providers/huawei_maas" ]; then
    cp -r /root/free-claude-code/providers/huawei_maas/* providers/huawei_maas/
    print_success "Proveedor Huawei MaaS copiado"
else
    print_error "No se encontró el proveedor Huawei MaaS"
    exit 1
fi

# Aplicar modificaciones a los archivos existentes
print_info "Aplicando modificaciones a config/provider_catalog.py..."
# (Las modificaciones ya están aplicadas en el directorio original)

# 6. Instalar dependencias de Python
print_info "6. Instalando dependencias de Python..."
uv sync
print_success "Dependencias instaladas"

# 7. Instalar Claude Code CLI
print_info "7. Instalando Claude Code CLI..."
npm install -g @anthropic-ai/claude-code
print_success "Claude Code CLI instalado: $(claude --version 2>/dev/null || echo 'versión desconocida')"

# 8. Crear archivo de configuración .env
print_info "8. Creando archivo de configuración .env..."
cat > .env << 'EOF'
# Huawei Cloud MaaS Config (uses OpenAI-compatible API)
HUAWEI_MAAS_API_KEY="TU_API_KEY_AQUI"

# All Claude model requests are mapped to these models, plain model is fallback
# Format: provider_type/model/name
MODEL_OPUS="huawei_maas/deepseek-v3.2"
MODEL_SONNET="huawei_maas/deepseek-v3.2"
MODEL_HAIKU="huawei_maas/deepseek-v3.2"
MODEL="huawei_maas/deepseek-v3.2"

# Optional live smoke model overrides
FCC_SMOKE_MODEL_HUAWEI_MAAS="deepseek-v3.2"

# Thinking output
ENABLE_OPUS_THINKING=true
ENABLE_SONNET_THINKING=true
ENABLE_HAIKU_THINKING=true
ENABLE_MODEL_THINKING=true

# Provider config
HUAWEI_MAAS_PROXY=""

PROVIDER_RATE_LIMIT=1
PROVIDER_RATE_WINDOW=3
PROVIDER_MAX_CONCURRENCY=5

# HTTP client timeouts (seconds) for provider API requests
HTTP_READ_TIMEOUT=300
HTTP_WRITE_TIMEOUT=60
HTTP_CONNECT_TIMEOUT=60

# Optional server API key (Anthropic-style)
ANTHROPIC_AUTH_TOKEN="freecc"

# Messaging Platform: "telegram" | "discord" | "none"
MESSAGING_PLATFORM="none"

# Agent Config
CLAUDE_WORKSPACE="./agent_workspace"
ALLOWED_DIR=""
CLAUDE_CLI_BIN="claude"
FAST_PREFIX_DETECTION=true
ENABLE_NETWORK_PROBE_MOCK=true
ENABLE_TITLE_GENERATION_SKIP=true
ENABLE_FILEPATH_EXTRACTION_MOCK=true

# Local Anthropic web_search / web_fetch handling (performs outbound HTTP; on by default)
ENABLE_WEB_SERVER_TOOLS=true
WEB_FETCH_ALLOWED_SCHEMES=http,https
WEB_FETCH_ALLOW_PRIVATE_NETWORKS=false

# Verbose diagnostics
DEBUG_PLATFORM_EDITS=false
DEBUG_SUBAGENT_STACK=false
LOG_RAW_API_PAYLOADS=false
LOG_RAW_SSE_EVENTS=false
LOG_API_ERROR_TRACEBACKS=false
LOG_RAW_MESSAGING_CONTENT=false
LOG_RAW_CLI_DIAGNOSTICS=false
LOG_MESSAGING_ERROR_DETAILS=false
EOF

print_success "Archivo .env creado"
print_info "IMPORTANTE: Edita el archivo .env y reemplaza 'TU_API_KEY_AQUI' con tu API key de Huawei Cloud MaaS"

# 9. Crear script de inicio
print_info "9. Creando scripts de inicio..."
cat > ~/start-huawei-maas-proxy.sh << 'EOF'
#!/bin/bash
# Script para iniciar el proxy Huawei Cloud MaaS

cd ~/free-claude-code

# Cargar variables de entorno desde .env si existe
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Variables requeridas
export HUAWEI_MAAS_API_KEY="${HUAWEI_MAAS_API_KEY:-TU_API_KEY_AQUI}"
export MODEL="${MODEL:-huawei_maas/deepseek-v3.2}"
export MODEL_OPUS="${MODEL_OPUS:-huawei_maas/deepseek-v3.2}"
export MODEL_SONNET="${MODEL_SONNET:-huawei_maas/deepseek-v3.2}"
export MODEL_HAIKU="${MODEL_HAIKU:-huawei_maas/deepseek-v3.2}"

echo "========================================="
echo "Iniciando Huawei Cloud MaaS Proxy"
echo "========================================="
echo "Endpoint: https://api-ap-southeast-1.modelarts-maas.com/openai/v1"
echo "Modelo: deepseek-v3.2"
echo "Proxy URL: http://localhost:8082"
echo "Claude Code config: claude config set endpoint http://localhost:8082"
echo "Claude Code config: claude config set api-key freecc"
echo "========================================="

uv run python server.py
EOF

chmod +x ~/start-huawei-maas-proxy.sh

cat > ~/test-huawei-connection.sh << 'EOF'
#!/bin/bash
# Script para probar la conexión con Huawei Cloud MaaS

echo "========================================="
echo "Prueba de conexión Huawei Cloud MaaS"
echo "========================================="

# Verificar si el proxy está corriendo
if curl -s http://localhost:8082/health > /dev/null 2>&1; then
    echo "✅ Proxy activo en http://localhost:8082"
else
    echo "❌ Proxy no responde en http://localhost:8082"
    echo "   Ejecuta: ~/start-huawei-maas-proxy.sh"
fi

# Probar conexión directa a Huawei MaaS (requiere API key en .env)
if [ -f ~/free-claude-code/.env ]; then
    source ~/free-claude-code/.env
    if [ -n "$HUAWEI_MAAS_API_KEY" ] && [ "$HUAWEI_MAAS_API_KEY" != "TU_API_KEY_AQUI" ]; then
        echo "🔍 Probando conexión directa a Huawei Cloud MaaS..."
        curl -X POST https://api-ap-southeast-1.modelarts-maas.com/openai/v1/chat/completions \
          -H "Authorization: Bearer $HUAWEI_MAAS_API_KEY" \
          -H "Content-Type: application/json" \
          -d '{
            "model": "deepseek-v3.2",
            "messages": [{"role": "user", "content": "Hola, responde OK si funciona"}],
            "max_tokens": 10
          }' 2>/dev/null | grep -q "OK" && echo "✅ Huawei MaaS API funciona" || echo "❌ Error en Huawei MaaS API"
    else
        echo "⚠️  Configura tu API key en ~/free-claude-code/.env"
    fi
fi

# Probar Claude Code config
echo "🔍 Verificando configuración de Claude Code..."
claude config get endpoint 2>/dev/null | grep -q "localhost:8082" && echo "✅ Claude Code configurado con proxy" || echo "❌ Claude Code no configurado"
claude config get api-key 2>/dev/null | grep -q "freecc" && echo "✅ Claude Code con API key correcta" || echo "❌ API key incorrecta"

echo "========================================="
echo "Para configurar Claude Code:"
echo "  claude config set endpoint http://localhost:8082"
echo "  claude config set api-key freecc"
echo "========================================="
EOF

chmod +x ~/test-huawei-connection.sh

# 10. Configurar Claude Code
print_info "10. Configurando Claude Code..."
claude config set endpoint http://localhost:8082 2>/dev/null || true
claude config set api-key freecc 2>/dev/null || true

# 11. Crear servicio systemd
print_info "11. Creando servicio systemd..."
sudo tee /etc/systemd/system/huawei-maas-proxy.service > /dev/null << EOF
[Unit]
Description=Huawei Cloud MaaS Proxy for Claude Code
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/free-claude-code
EnvironmentFile=$HOME/free-claude-code/.env
ExecStart=$HOME/.local/bin/uv run python server.py
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=huawei-maas-proxy

[Install]
WantedBy=multi-user.target
EOF

print_success "Servicio systemd creado"
print_info "Para habilitar el servicio:"
print_info "  sudo systemctl daemon-reload"
print_info "  sudo systemctl enable huawei-maas-proxy"
print_info "  sudo systemctl start huawei-maas-proxy"

# 12. Resumen final
echo ""
echo "========================================="
echo "INSTALACIÓN COMPLETADA"
echo "========================================="
echo ""
echo "✅ Dependencias instaladas"
echo "✅ free-claude-code configurado"
echo "✅ Proveedor Huawei MaaS integrado"
echo "✅ Claude Code CLI instalado"
echo "✅ Scripts de inicio creados"
echo "✅ Servicio systemd configurado"
echo ""
echo "📋 PASOS FINALES:"
echo "1. Edita ~/free-claude-code/.env y agrega tu API key de Huawei Cloud MaaS"
echo "2. Inicia el proxy: ~/start-huawei-maas-proxy.sh"
echo "3. Configura Claude Code:"
echo "   claude config set endpoint http://localhost:8082"
echo "   claude config set api-key freecc"
echo "4. Prueba la conexión: ~/test-huawei-connection.sh"
echo "5. Usa Claude Code: claude 'Hola, prueba'"
echo ""
echo "🔧 PARA USAR COMO SERVICIO:"
echo "   sudo systemctl daemon-reload"
echo "   sudo systemctl enable huawei-maas-proxy"
echo "   sudo systemctl start huawei-maas-proxy"
echo "   sudo systemctl status huawei-maas-proxy"
echo ""
echo "📊 MODELOS DISPONIBLES:"
echo "   • deepseek-v3.2 (recomendado)"
echo "   • deepseek-v4-flash"
echo "   • glm-5.1"
echo "   • llama-3.1-8b"
echo "   • llama-3.1-70b"
echo ""
echo "💰 COSTOS: DeepSeek V3.2 ≈ $0.02/1M tokens (20x más económico que Claude Opus)"
echo "========================================="