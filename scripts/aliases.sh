#!/bin/bash
# Aliases para Huawei MaaS como en el artículo de Diario Vida
# Basado en: https://diariovida.com/deepseek-claude-code-instalacion/

# Alias ds (como en el artículo)
alias ds="ANTHROPIC_BASE_URL=http://localhost:8082 GATEWAY_MODEL_DISCOVERY=1 claude --gateway freecc"

# Alias dsdanger (como en el artículo)
alias dsdanger="ANTHROPIC_BASE_URL=http://localhost:8082 GATEWAY_MODEL_DISCOVERY=1 claude --gateway freecc --dangerously-skip-permissions"

# Alias claude-maas (mi versión mejorada)
alias claude-maas="ANTHROPIC_BASE_URL=http://localhost:8082 GATEWAY_MODEL_DISCOVERY=1 claude --gateway freecc"

# Alias corto claude-m
alias claude-m="claude-maas"

# Alias ultra corto cm
alias cm="claude-maas"

# Función para verificar que todo funciona
check-proxy() {
    echo "🔍 Verificando conexión al proxy..."
    if curl -s http://localhost:8082/health > /dev/null; then
        echo "✅ Proxy funcionando en http://localhost:8082"
        echo "📊 Modelos disponibles:"
        curl -s http://localhost:8082/v1/models | jq -r '.data[].id' 2>/dev/null || echo "❌ No se pudo obtener modelos"
    else
        echo "❌ Proxy no responde. Ejecuta: claude-maas start"
    fi
}

# Exportar funciones
export -f check-proxy

echo "✅ Aliases configurados:"
echo "   ds        - Claude Code con Huawei MaaS (como en Diario Vida)"
echo "   dsdanger  - Claude Code sin confirmaciones"
echo "   claude-maas - Mi versión mejorada"
echo "   claude-m  - Alias corto"
echo "   cm        - Alias ultra corto"
echo "   check-proxy - Verifica estado del proxy"
