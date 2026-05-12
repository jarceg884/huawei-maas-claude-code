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