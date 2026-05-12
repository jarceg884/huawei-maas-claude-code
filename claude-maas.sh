#!/bin/bash
# claude-maas - Huawei Cloud MaaS + Claude Code Wrapper
# Uso: claude-maas "tu pregunta" [opciones]

set -e

# Configuración
PROXY_URL="http://localhost:8082"
API_KEY="freecc"
HUAWEI_MAAS_API_KEY="${HUAWEI_MAAS_API_KEY:-TU_API_KEY_AQUI}"
MODEL="huawei_maas/deepseek-v3.2"
FREE_CLAUDE_PATH="${FREE_CLAUDE_PATH:-$HOME/free-claude-code}"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Verificar si el proxy está corriendo
check_proxy() {
    if curl -s "$PROXY_URL/health" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Iniciar proxy si no está corriendo
start_proxy() {
    print_info "Iniciando proxy Huawei Cloud MaaS..."
    
    # Verificar si ya hay un proceso del proxy
    if pgrep -f "python server.py" > /dev/null; then
        print_info "Proxy ya está corriendo (PID: $(pgrep -f "python server.py"))"
        return 0
    fi
    
    # Verificar que el directorio existe
    if [ ! -d "$FREE_CLAUDE_PATH" ]; then
        print_error "Directorio $FREE_CLAUDE_PATH no encontrado"
        print_info "Instala primero: curl -fsSL https://raw.githubusercontent.com/jarceg884/huawei-maas-claude-code/main/install.sh | bash"
        return 1
    fi
    
    # Cambiar al directorio
    cd "$FREE_CLAUDE_PATH" || {
        print_error "No se pudo acceder a $FREE_CLAUDE_PATH"
        return 1
    }
    
    # Exportar variables de entorno
    export HUAWEI_MAAS_API_KEY="$HUAWEI_MAAS_API_KEY"
    export MODEL="$MODEL"
    export MODEL_OPUS="$MODEL"
    export MODEL_SONNET="$MODEL"
    export MODEL_HAIKU="$MODEL"
    
    # Iniciar proxy en background
    print_info "Iniciando proxy en $FREE_CLAUDE_PATH..."
    nohup uv run python server.py > /tmp/claude-maas-proxy.log 2>&1 &
    PROXY_PID=$!
    
    # Esperar a que el proxy esté listo
    print_info "Esperando que el proxy inicie (PID: $PROXY_PID)..."
    for i in {1..30}; do
        if check_proxy; then
            print_success "Proxy iniciado en $PROXY_URL"
            echo $PROXY_PID > /tmp/claude-maas-proxy.pid
            return 0
        fi
        sleep 1
        echo -n "."
    done
    
    print_error "Proxy no inició después de 30 segundos"
    print_info "Ver logs: tail -f /tmp/claude-maas-proxy.log"
    return 1
}

# Detener proxy
stop_proxy() {
    if [ -f /tmp/claude-maas-proxy.pid ]; then
        PID=$(cat /tmp/claude-maas-proxy.pid)
        if kill $PID 2>/dev/null; then
            print_info "Proxy detenido (PID: $PID)"
            rm -f /tmp/claude-maas-proxy.pid
        fi
    fi
    
    # También matar cualquier proceso de server.py
    pkill -f "python server.py" 2>/dev/null && print_info "Procesos de proxy terminados"
}

# Configurar Claude Code para usar Huawei MaaS
setup_claude() {
    print_info "Configurando Claude Code para Huawei MaaS..."
    
    # Verificar si Claude Code está instalado
    if ! command -v claude &> /dev/null; then
        print_error "Claude Code no está instalado"
        print_info "Instala con: npm install -g @anthropic-ai/claude-code"
        return 1
    fi
    
    # Configurar endpoint y API key
    claude config set endpoint "$PROXY_URL" 2>/dev/null || true
    claude config set api-key "$API_KEY" 2>/dev/null || true
    
    print_success "Claude Code configurado para Huawei MaaS"
    print_info "Endpoint: $PROXY_URL"
    print_info "API Key: $API_KEY"
    print_info "Modelo: $MODEL"
}

# Restaurar configuración original de Claude
restore_claude() {
    print_info "Restaurando configuración original de Claude..."
    
    if command -v claude &> /dev/null; then
        claude config set endpoint "https://api.anthropic.com" 2>/dev/null || true
        print_info "Endpoint restaurado a Anthropic"
    fi
}

# Mostrar ayuda
show_help() {
    echo -e "${BLUE}Claude MaaS - Huawei Cloud MaaS + Claude Code${NC}"
    echo ""
    echo "Uso: claude-maas [OPCIÓN] [TEXTO]"
    echo "     claude-m [OPCIÓN] [TEXTO]          # Alias corto"
    echo ""
    echo "Opciones:"
    echo "  [texto]              Enviar texto a Claude con Huawei MaaS"
    echo "  -f, --file ARCHIVO   Enviar archivo a Claude"
    echo "  -c, --context TEXTO  Agregar contexto"
    echo "  start                Iniciar proxy Huawei MaaS"
    echo "  stop                 Detener proxy Huawei MaaS"
    echo "  status               Ver estado del proxy"
    echo "  setup                Configurar Claude Code para Huawei MaaS"
    echo "  restore              Restaurar configuración original de Claude"
    echo "  logs                 Ver logs del proxy"
    echo "  test                 Probar conexión con Huawei MaaS"
    echo "  help, --help, -h     Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  claude-maas \"Explica este código\""
    echo "  claude-m \"¿Cómo optimizar?\"          # Alias corto"
    echo "  claude-maas -f script.py \"Analiza\""
    echo "  claude-maas start    # Iniciar proxy"
    echo "  claude-maas status   # Ver estado"
    echo ""
    echo "Configuración:"
    echo "  Proxy: $PROXY_URL"
    echo "  Modelo: $MODEL"
    echo "  Ahorro: 95% vs Claude Opus"
}

# Ver estado del proxy
show_status() {
    echo -e "${BLUE}=== Estado Huawei Cloud MaaS Proxy ===${NC}"
    
    # Verificar proxy
    if check_proxy; then
        echo -e "${GREEN}✅ Proxy activo en $PROXY_URL${NC}"
        
        # Verificar PID
        if [ -f /tmp/claude-maas-proxy.pid ]; then
            PID=$(cat /tmp/claude-maas-proxy.pid)
            if ps -p $PID > /dev/null 2>&1; then
                echo "PID: $PID"
            else
                echo -e "${YELLOW}⚠️  PID file existe pero proceso no corre${NC}"
            fi
        fi
    else
        echo -e "${RED}❌ Proxy inactivo${NC}"
    fi
    
    # Verificar configuración Claude
    echo ""
    echo -e "${BLUE}=== Configuración Claude Code ===${NC}"
    if command -v claude &> /dev/null; then
        ENDPOINT=$(claude config get endpoint 2>/dev/null || echo "No configurado")
        echo "Endpoint: $ENDPOINT"
        
        if [ "$ENDPOINT" = "$PROXY_URL" ]; then
            echo -e "${GREEN}✅ Configurado para Huawei MaaS${NC}"
        else
            echo -e "${YELLOW}⚠️  No configurado para Huawei MaaS${NC}"
            echo "Ejecuta: claude-maas setup"
        fi
    else
        echo -e "${RED}❌ Claude Code no instalado${NC}"
        echo "Instala con: npm install -g @anthropic-ai/claude-code"
    fi
    
    # Verificar conexión Huawei MaaS
    echo ""
    echo -e "${BLUE}=== Conexión Huawei Cloud MaaS ===${NC}"
    if curl -s -X POST https://api-ap-southeast-1.modelarts-maas.com/openai/v1/chat/completions \
        -H "Authorization: Bearer $HUAWEI_MAAS_API_KEY" \
        -H "Content-Type: application/json" \
        -d '{"model":"deepseek-v3.2","messages":[{"role":"user","content":"test"}],"max_tokens":5}' \
        --max-time 5 2>/dev/null | grep -q "choices"; then
        echo -e "${GREEN}✅ Huawei MaaS API conectada${NC}"
    else
        echo -e "${RED}❌ Error conectando a Huawei MaaS${NC}"
        echo "Verifica tu API key en ~/free-claude-code/.env"
    fi
}

# Ver logs del proxy
show_logs() {
    if [ -f /tmp/claude-maas-proxy.log ]; then
        echo -e "${BLUE}=== Últimas 50 líneas del log ===${NC}"
        tail -50 /tmp/claude-maas-proxy.log
    else
        echo -e "${YELLOW}⚠️  No hay archivo de log${NC}"
        echo "Inicia el proxy primero: claude-maas start"
    fi
}

# Probar conexión
test_connection() {
    echo -e "${BLUE}=== Probando conexión Huawei Cloud MaaS ===${NC}"
    
    # Probar API directa
    print_info "Probando API Huawei MaaS..."
    RESPONSE=$(curl -s -X POST https://api-ap-southeast-1.modelarts-maas.com/openai/v1/chat/completions \
        -H "Authorization: Bearer $HUAWEI_MAAS_API_KEY" \
        -H "Content-Type: application/json" \
        -d '{"model":"deepseek-v3.2","messages":[{"role":"user","content":"Responde OK si funciona"}],"max_tokens":10}')
    
    if echo "$RESPONSE" | grep -q "choices"; then
        echo -e "${GREEN}✅ Huawei MaaS API funciona${NC}"
        CONTENT=$(echo "$RESPONSE" | grep -o '"content":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo "Respuesta: $CONTENT"
    else
        echo -e "${RED}❌ Error en Huawei MaaS API${NC}"
        echo "Response: $RESPONSE"
    fi
    
    # Probar proxy
    echo ""
    print_info "Probando proxy local..."
    if check_proxy; then
        echo -e "${GREEN}✅ Proxy activo en $PROXY_URL${NC}"
        
        # Probar endpoint del proxy
        RESPONSE=$(curl -s -X POST "$PROXY_URL/v1/messages" \
            -H "Content-Type: application/json" \
            -H "x-api-key: $API_KEY" \
            -H "anthropic-version: 2023-06-01" \
            -d '{"model":"claude-3-5-sonnet-20241022","messages":[{"role":"user","content":"OK"}],"max_tokens":10}' 2>/dev/null | head -5)
        
        if echo "$RESPONSE" | grep -q "message_start"; then
            echo -e "${GREEN}✅ Proxy funcionando correctamente${NC}"
        else
            echo -e "${YELLOW}⚠️  Proxy responde pero con error${NC}"
            echo "Response: $RESPONSE"
        fi
    else
        echo -e "${RED}❌ Proxy no disponible${NC}"
        echo "Inicia con: claude-maas start"
    fi
}

# Manejar argumentos
case "$1" in
    start)
        start_proxy
        ;;
    stop)
        stop_proxy
        ;;
    status)
        show_status
        ;;
    setup)
        setup_claude
        ;;
    restore)
        restore_claude
        ;;
    logs)
        show_logs
        ;;
    test)
        test_connection
        ;;
    help|--help|-h)
        show_help
        ;;
    -f|--file)
        if [ -z "$2" ]; then
            print_error "Debes especificar un archivo"
            show_help
            exit 1
        fi
        FILE="$2"
        shift 2
        TEXT="$*"
        
        # Iniciar proxy si no está corriendo
        check_proxy || start_proxy
        
        # Configurar Claude si no está configurado
        CURRENT_ENDPOINT=$(claude config get endpoint 2>/dev/null || echo "")
        if [ "$CURRENT_ENDPOINT" != "$PROXY_URL" ]; then
            setup_claude
        fi
        
        # Ejecutar Claude con archivo
        print_info "Enviando archivo: $FILE"
        print_info "Contexto: $TEXT"
        claude -f "$FILE" "$TEXT"
        ;;
    -c|--context)
        if [ -z "$2" ]; then
            print_error "Debes especificar contexto"
            show_help
            exit 1
        fi
        CONTEXT="$2"
        shift 2
        TEXT="$*"
        
        # Iniciar proxy si no está corriendo
        check_proxy || start_proxy
        
        # Configurar Claude si no está configurado
        CURRENT_ENDPOINT=$(claude config get endpoint 2>/dev/null || echo "")
        if [ "$CURRENT_ENDPOINT" != "$PROXY_URL" ]; then
            setup_claude
        fi
        
        # Ejecutar Claude con contexto
        print_info "Contexto: $CONTEXT"
        print_info "Pregunta: $TEXT"
        claude --context "$CONTEXT" "$TEXT"
        ;;
    "")
        show_help
        ;;
    *)
        # Modo normal: enviar texto a Claude
        TEXT="$*"
        
        # Iniciar proxy si no está corriendo
        if ! check_proxy; then
            start_proxy
        fi
        
        # Configurar Claude si no está configurado
        CURRENT_ENDPOINT=$(claude config get endpoint 2>/dev/null || echo "")
        if [ "$CURRENT_ENDPOINT" != "$PROXY_URL" ]; then
            setup_claude
        fi
        
        # Ejecutar Claude
        print_info "Enviando a Huawei MaaS: $TEXT"
        claude "$TEXT"
        ;;
esac