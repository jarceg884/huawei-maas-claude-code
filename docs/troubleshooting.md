# Huawei Cloud MaaS + Claude Code - Solución de problemas

## Problemas comunes y soluciones

### ❌ Error: "HUAWEI_MAAS_API_KEY is not set"

**Síntoma:**
```
500: HUAWEI_MAAS_API_KEY is not set. Add it to your .env file.
```

**Solución:**
1. Verifica que el archivo `.env` exista en `~/free-claude-code/`
2. Asegúrate de que contenga tu API key:
   ```bash
   HUAWEI_MAAS_API_KEY="tu_api_key_aqui"
   ```
3. Exporta la variable manualmente:
   ```bash
   export HUAWEI_MAAS_API_KEY="tu_api_key_aqui"
   ```

### ❌ Error: "Cannot connect to proxy"

**Síntoma:**
```
Error: Cannot connect to http://localhost:8082
```

**Solución:**
1. Verifica que el servidor esté corriendo:
   ```bash
   ps aux | grep server.py
   ```
2. Inicia el servidor:
   ```bash
   cd ~/free-claude-code
   ./start-huawei-maas-proxy.sh
   ```
3. Verifica el puerto:
   ```bash
   netstat -tlnp | grep :8082
   ```

### ❌ Error: "Connection refused"

**Síntoma:**
```
curl: (7) Failed to connect to localhost port 8082: Connection refused
```

**Solución:**
1. El servidor no está corriendo. Inícialo:
   ```bash
   cd ~/free-claude-code
   export HUAWEI_MAAS_API_KEY="tu_api_key"
   uv run python server.py
   ```
2. Verifica que no haya otro proceso usando el puerto 8082:
   ```bash
   sudo lsof -i :8082
   ```

### ❌ Error: "Invalid API key" de Huawei Cloud MaaS

**Síntoma:**
```
401: Invalid authentication
```

**Solución:**
1. Verifica tu API key en [Huawei Cloud Console](https://console.huaweicloud.com/ai/maas/)
2. Asegúrate de que la key tenga permisos suficientes
3. Verifica que no haya espacios en blanco:
   ```bash
   echo "API Key: |$HUAWEI_MAAS_API_KEY|"
   ```
4. Regenera la API key si es necesario

### ❌ Error: "Rate limit exceeded"

**Síntoma:**
```
429: Rate limit exceeded
```

**Solución:**
1. Reduce la frecuencia de requests:
   ```bash
   # En .env
   PROVIDER_RATE_LIMIT=1
   PROVIDER_RATE_WINDOW=5
   ```
2. Espera unos minutos antes de reintentar
3. Considera actualizar tu plan en Huawei Cloud MaaS

### ❌ Error: "Model not found"

**Síntoma:**
```
404: Model not found
```

**Solución:**
1. Verifica el nombre del modelo en `.env`:
   ```bash
   MODEL="huawei_maas/deepseek-v3.2"
   ```
2. Modelos disponibles:
   - `deepseek-v3.2`
   - `deepseek-v4-flash`
   - `glm-5.1`
   - `llama-3.1-8b`
   - `llama-3.1-70b`
3. Verifica en [Huawei Cloud Console](https://console.huaweicloud.com/ai/maas/) qué modelos tienes acceso

### ❌ Error: Claude Code no responde

**Síntoma:**
Claude Code se queda cargando sin respuesta

**Solución:**
1. Verifica la configuración de Claude Code:
   ```bash
   claude config get endpoint
   claude config get api-key
   ```
2. Configura correctamente:
   ```bash
   claude config set endpoint http://localhost:8082
   claude config set api-key freecc
   ```
3. Prueba el endpoint directamente:
   ```bash
   curl -X POST http://localhost:8082/v1/messages \
     -H "Content-Type: application/json" \
     -H "x-api-key: freecc" \
     -H "anthropic-version: 2023-06-01" \
     -d '{"model": "claude-3-5-sonnet-20241022", "messages": [{"role": "user", "content": "Hola"}]}'
   ```

### ❌ Error: "uv: command not found"

**Síntoma:**
```
bash: uv: command not found
```

**Solución:**
1. Instala uv:
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```
2. Agrega uv al PATH:
   ```bash
   export PATH="$HOME/.cargo/bin:$PATH"
   echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
   ```

### ❌ Error: "Python 3.14 not found"

**Síntoma:**
```
error: Python 3.14 not found
```

**Solución:**
1. Instala Python 3.14 con uv:
   ```bash
   uv python install 3.14
   ```
2. Verifica la instalación:
   ```bash
   uv python list
   ```

### ❌ Error: "npm: command not found"

**Síntoma:**
```
bash: npm: command not found
```

**Solución:**
1. Instala Node.js y npm:
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
   apt-get install -y nodejs
   ```
2. Verifica la instalación:
   ```bash
   node --version
   npm --version
   ```

## Diagnóstico paso a paso

### 1. Verificar conexión a Huawei Cloud MaaS

```bash
# Probar API directamente
curl -X POST https://api-ap-southeast-1.modelarts-maas.com/openai/v1/chat/completions \
  -H "Authorization: Bearer $HUAWEI_MAAS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-v3.2",
    "messages": [{"role": "user", "content": "Test"}],
    "max_tokens": 5
  }'
```

### 2. Verificar proxy local

```bash
# Iniciar proxy en modo verbose
cd ~/free-claude-code
export HUAWEI_MAAS_API_KEY="tu_api_key"
LOG_RAW_API_PAYLOADS=true uv run python server.py

# En otra terminal, probar proxy
curl -X POST http://localhost:8082/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: freecc" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model": "claude-3-5-sonnet-20241022", "messages": [{"role": "user", "content": "Test"}]}'
```

### 3. Verificar logs del proxy

```bash
# Ver logs en tiempo real
tail -f ~/free-claude-code/server.log 2>/dev/null || \
  journalctl -u huawei-maas-proxy -f

# Ver errores específicos
grep -i "error\|exception\|traceback" ~/free-claude-code/server.log
```

### 4. Verificar configuración de Claude Code

```bash
# Listar toda la configuración
claude config list

# Ver configuración específica
claude config get endpoint
claude config get api-key

# Restablecer configuración
claude config reset
claude config set endpoint http://localhost:8082
claude config set api-key freecc
```

## Problemas de red

### ❌ Error: "Network is unreachable"

**Solución:**
1. Verifica tu conexión a internet:
   ```bash
   ping 8.8.8.8
   ```
2. Verifica que puedas alcanzar Huawei Cloud:
   ```bash
   curl -I https://api-ap-southeast-1.modelarts-maas.com
   ```
3. Si usas proxy corporativo, configúralo:
   ```bash
   export HTTP_PROXY="http://proxy:puerto"
   export HTTPS_PROXY="http://proxy:puerto"
   ```

### ❌ Error: "SSL certificate problem"

**Solución:**
1. Actualiza certificados SSL:
   ```bash
   apt-get update && apt-get install -y ca-certificates
   update-ca-certificates
   ```
2. Deshabilita verificación SSL (solo para testing):
   ```bash
   export CURL_CA_BUNDLE=""
   # No recomendado para producción
   ```

## Recursos útiles

### Logs del sistema
```bash
# Ver todos los logs del servicio
sudo journalctl -u huawei-maas-proxy -n 100

# Seguir logs en tiempo real
sudo journalctl -u huawei-maas-proxy -f

# Ver logs desde el inicio
sudo journalctl -u huawei-maas-proxy --since "2024-01-01"
```

### Monitoreo de recursos
```bash
# Ver uso de CPU/Memoria
top -p $(pgrep -f "python server.py")

# Ver conexiones de red
ss -tlnp | grep :8082

# Ver uso de puertos
sudo lsof -i :8082
```

### Reiniciar servicio
```bash
# Reiniciar completamente
sudo systemctl daemon-reload
sudo systemctl restart huawei-maas-proxy
sudo systemctl status huawei-maas-proxy

# Ver logs después del reinicio
sudo journalctl -u huawei-maas-proxy --since "5 minutes ago"
```

## Soporte adicional

Si los problemas persisten:

1. **Verifica la documentación oficial:**
   - [free-claude-code GitHub](https://github.com/Alishahryar1/free-claude-code)
   - [Huawei Cloud MaaS Documentation](https://console.huaweicloud.com/ai/maas/)

2. **Crea un issue en GitHub:**
   ```bash
   # Incluye esta información:
   cat /etc/os-release
   python --version
   node --version
   uv --version
   claude --version
   ```

3. **Contacta soporte de Huawei Cloud:**
   - [Huawei Cloud Support](https://www.huaweicloud.com/intl/en-us/product/maas.html)

4. **Únete a la comunidad:**
   - Discord de free-claude-code
   - Foros de Huawei Cloud