# Configuración Huawei Cloud MaaS para Claude Code

## Archivo de configuración .env

Copia este archivo como `.env` en el directorio `free-claude-code`:

```bash
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
```

## Obtener API Key de Huawei Cloud MaaS

1. Ve a [Huawei Cloud Console](https://console.huaweicloud.com/ai/maas/)
2. Inicia sesión con tu cuenta
3. Ve a "ModelArts" → "MaaS" (Model as a Service)
4. Crea un nuevo proyecto o selecciona uno existente
5. Ve a "API Keys" o "Credentials"
6. Genera una nueva API Key
7. Copia la key y reemplaza `TU_API_KEY_AQUI` en el archivo `.env`

## Modelos disponibles

| Modelo Huawei MaaS | Descripción | Costo aproximado |
|-------------------|-------------|------------------|
| `deepseek-v3.2` | Modelo principal recomendado | ~$0.02/1M tokens |
| `deepseek-v4-flash` | Versión más rápida | ~$0.015/1M tokens |
| `glm-5.1` | Modelo GLM de 5.1B parámetros | ~$0.01/1M tokens |
| `llama-3.1-8b` | Llama 3.1 8B | ~$0.008/1M tokens |
| `llama-3.1-70b` | Llama 3.1 70B | ~$0.035/1M tokens |

## Cambiar modelo

Para cambiar el modelo, edita las variables `MODEL_*` en el archivo `.env`:

```bash
# Usar DeepSeek V4 Flash (más rápido, más económico)
MODEL_OPUS="huawei_maas/deepseek-v4-flash"
MODEL_SONNET="huawei_maas/deepseek-v4-flash"
MODEL_HAIKU="huawei_maas/deepseek-v4-flash"
MODEL="huawei_maas/deepseek-v4-flash"

# Usar GLM-5.1 (más económico)
MODEL_OPUS="huawei_maas/glm-5.1"
MODEL_SONNET="huawei_maas/glm-5.1"
MODEL_HAIKU="huawei_maas/glm-5.1"
MODEL="huawei_maas/glm-5.1"
```

## Configuración de Claude Code

```bash
# Configurar endpoint del proxy
claude config set endpoint http://localhost:8082

# Configurar API key (usar "freecc" como key para el proxy)
claude config set api-key freecc

# Verificar configuración
claude config get endpoint
claude config get api-key

# Restaurar configuración original de Claude (si es necesario)
claude config set endpoint https://api.anthropic.com
claude config set api-key tu_api_key_anthropic
```

## Variables de entorno importantes

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `HUAWEI_MAAS_API_KEY` | API Key de Huawei Cloud MaaS | Requerido |
| `MODEL` | Modelo por defecto | `huawei_maas/deepseek-v3.2` |
| `ANTHROPIC_AUTH_TOKEN` | Token para autenticar al proxy | `freecc` |
| `PROVIDER_RATE_LIMIT` | Límite de tasa de requests | `1` |
| `PROVIDER_RATE_WINDOW` | Ventana de tiempo para límite de tasa | `3` (segundos) |
| `HTTP_READ_TIMEOUT` | Timeout de lectura HTTP | `300` (segundos) |

## Configuración avanzada

### Usar proxy HTTP/SOCKS5
Si necesitas usar un proxy para conectarte a Huawei Cloud MaaS:

```bash
HUAWEI_MAAS_PROXY="http://usuario:contraseña@proxy:puerto"
# o
HUAWEI_MAAS_PROXY="socks5://usuario:contraseña@proxy:puerto"
```

### Configurar límites de tasa
Ajusta según tus necesidades:

```bash
# Máximo 5 requests por segundo
PROVIDER_RATE_LIMIT=5
PROVIDER_RATE_WINDOW=1

# Máximo 10 conexiones concurrentes
PROVIDER_MAX_CONCURRENCY=10
```

### Habilitar logging detallado
Para debugging:

```bash
LOG_RAW_API_PAYLOADS=true
LOG_RAW_SSE_EVENTS=true
LOG_API_ERROR_TRACEBACKS=true
```

## Verificación de configuración

```bash
# Verificar que todas las variables estén configuradas
cd ~/free-claude-code
grep -v "^#" .env | grep -v "^$"

# Probar conexión directa a Huawei MaaS
curl -X POST https://api-ap-southeast-1.modelarts-maas.com/openai/v1/chat/completions \
  -H "Authorization: Bearer $HUAWEI_MAAS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-v3.2",
    "messages": [{"role": "user", "content": "Hola"}],
    "max_tokens": 10
  }'

# Verificar que el proxy esté funcionando
curl http://localhost:8082/health
```