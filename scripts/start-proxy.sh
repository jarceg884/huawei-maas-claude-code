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