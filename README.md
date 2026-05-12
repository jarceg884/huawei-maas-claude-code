# Huawei Cloud MaaS + Claude Code Integration

Integración completa de Huawei Cloud MaaS con Claude Code usando free-claude-code como proxy.

## 📁 Estructura del proyecto

```
huawei-maas-claude-code/
├── README.md                    # Este archivo
├── INSTALACION.md              # Guía de instalación paso a paso
├── CONFIGURACION.md            # Configuración detallada
├── scripts/
│   ├── install.sh             # Script de instalación automática
│   ├── start-proxy.sh         # Script para iniciar el proxy
│   └── test-connection.sh     # Script para probar conexión
├── config/
│   ├── .env.example           # Archivo de configuración de ejemplo
│   └── systemd/              # Configuraciones de servicio systemd
└── docs/
    ├── troubleshooting.md     # Solución de problemas
    └── cost-comparison.md     # Comparación de costos
```

## 🚀 Instalación rápida

```bash
# 1. Clonar este repositorio
git clone https://github.com/tu-usuario/huawei-maas-claude-code.git
cd huawei-maas-claude-code

# 2. Ejecutar script de instalación
chmod +x scripts/install.sh
./scripts/install.sh

# 3. Configurar Claude Code
npm install -g @anthropic-ai/claude-code
claude config set endpoint http://localhost:8082
claude config set api-key freecc

# 4. Iniciar proxy
./scripts/start-proxy.sh
```

## 🔧 Configuración

### Archivo `.env`
```bash
# Copiar archivo de ejemplo
cp config/.env.example .env

# Editar con tu API key
nano .env
```

Contenido de `.env`:
```bash
# Huawei Cloud MaaS Config
HUAWEI_MAAS_API_KEY="tu_api_key_aqui"

# Model mapping
MODEL_OPUS="huawei_maas/deepseek-v3.2"
MODEL_SONNET="huawei_maas/deepseek-v3.2"
MODEL_HAIKU="huawei_maas/deepseek-v3.2"
MODEL="huawei_maas/deepseek-v3.2"

# Server config
ANTHROPIC_AUTH_TOKEN="freecc"
MESSAGING_PLATFORM="none"
```

## 📊 Modelos disponibles

| Modelo Huawei MaaS | Equivalente Claude | Costo aproximado |
|-------------------|-------------------|------------------|
| deepseek-v3.2     | Claude Opus       | ~$0.02/1M tokens |
| deepseek-v4-flash | Claude Sonnet     | ~$0.015/1M tokens |
| glm-5.1           | Claude Haiku      | ~$0.01/1M tokens |

## 🎯 Uso

### Comando básico
```bash
claude "Tu pregunta aquí"
```

### Con archivos
```bash
claude -f archivo.py "Explica este código"
```

### Con contexto
```bash
claude --context "Estoy trabajando en Python" "Ayúdame con este error"
```

## 🔍 Verificación

```bash
# Probar conexión directa a Huawei MaaS
./scripts/test-connection.sh

# Verificar estado del proxy
curl http://localhost:8082/health

# Probar con Claude Code
claude "Hola, ¿estás funcionando con Huawei Cloud MaaS?"
```

## 🛠️ Solución de problemas

### Error: "HUAWEI_MAAS_API_KEY is not set"
```bash
export HUAWEI_MAAS_API_KEY="tu_api_key_aqui"
```

### Error: "Cannot connect to proxy"
```bash
# Verificar si el servidor está corriendo
ps aux | grep server.py

# Reiniciar servicio
sudo systemctl restart huawei-maas-proxy
```

### Claude Code no responde
```bash
# Verificar configuración
claude config get endpoint
claude config get api-key

# Probar endpoint directamente
curl http://localhost:8082/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: freecc" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model": "claude-3-5-sonnet-20241022", "messages": [{"role": "user", "content": "Hola"}]}'
```

## 📈 Monitoreo

### Logs del servicio
```bash
# Ver logs en tiempo real
sudo journalctl -u huawei-maas-proxy -f

# Ver logs históricos
sudo journalctl -u huawei-maas-proxy --since "1 hour ago"
```

### Uso de recursos
```bash
# Ver uso de CPU/Memoria
top -p $(pgrep -f "python server.py")

# Ver conexiones activas
ss -tlnp | grep :8082
```

## 🔄 Actualización

```bash
cd ~/huawei-maas-claude-code
git pull origin main
./scripts/install.sh --update
sudo systemctl restart huawei-maas-proxy
```

## 📞 Soporte

- **Issues del proyecto**: [GitHub Issues](https://github.com/tu-usuario/huawei-maas-claude-code/issues)
- **Documentación Huawei Cloud MaaS**: [https://console.huaweicloud.com/ai/maas/](https://console.huaweicloud.com/ai/maas/)
- **free-claude-code**: [https://github.com/Alishahryar1/free-claude-code](https://github.com/Alishahryar1/free-claude-code)

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE) para más detalles.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request