# Aliases para Huawei MaaS en PowerShell (Windows)
# Basado en: https://diariovida.com/deepseek-claude-code-instalacion/

# Función ds (como en el artículo)
function ds {
    $env:ANTHROPIC_BASE_URL = "http://localhost:8082"
    $env:GATEWAY_MODEL_DISCOVERY = "1"
    claude --gateway freecc @args
}

# Función dsdanger (como en el artículo)
function dsdanger {
    $env:ANTHROPIC_BASE_URL = "http://localhost:8082"
    $env:GATEWAY_MODEL_DISCOVERY = "1"
    claude --gateway freecc --dangerously-skip-permissions @args
}

# Función claude-maas (mi versión mejorada)
function claude-maas {
    $env:ANTHROPIC_BASE_URL = "http://localhost:8082"
    $env:GATEWAY_MODEL_DISCOVERY = "1"
    claude --gateway freecc @args
}

# Alias cortos
Set-Alias -Name claude-m -Value claude-maas
Set-Alias -Name cm -Value claude-maas

# Función para verificar proxy
function check-proxy {
    Write-Host "🔍 Verificando conexión al proxy..." -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8082/health" -ErrorAction Stop
        Write-Host "✅ Proxy funcionando en http://localhost:8082" -ForegroundColor Green
        Write-Host "📊 Modelos disponibles:" -ForegroundColor Cyan
        try {
            $models = Invoke-RestMethod -Uri "http://localhost:8082/v1/models"
            $models.data.id | ForEach-Object { Write-Host "   $_" }
        } catch {
            Write-Host "❌ No se pudo obtener modelos" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Proxy no responde. Ejecuta: claude-maas start" -ForegroundColor Red
    }
}

Write-Host "✅ Aliases configurados:" -ForegroundColor Green
Write-Host "   ds        - Claude Code con Huawei MaaS (como en Diario Vida)" -ForegroundColor Yellow
Write-Host "   dsdanger  - Claude Code sin confirmaciones" -ForegroundColor Yellow
Write-Host "   claude-maas - Mi versión mejorada" -ForegroundColor Yellow
Write-Host "   claude-m  - Alias corto" -ForegroundColor Yellow
Write-Host "   cm        - Alias ultra corto" -ForegroundColor Yellow
Write-Host "   check-proxy - Verifica estado del proxy" -ForegroundColor Yellow
