# Huawei Cloud MaaS + Claude Code 🚀

**Integración completa de Huawei Cloud MaaS con Claude Code** - Usa DeepSeek V3.2 (20x más económico) en lugar de Claude Opus.

![Multiplataforma](https://img.shields.io/badge/Windows-Linux-macOS-blue)
![Ahorro](https://img.shields.io/badge/Ahorro-95%25-green)
![Licencia](https://img.shields.io/badge/Licencia-MIT-yellow)

## ✨ **Características**

- ✅ **Comandos fáciles**: `claude-maas`, `claude-m`, `ds` y `dsdanger`
- ✅ **Multiplataforma**: Windows (PowerShell), Linux, macOS
- ✅ **95% de ahorro**: DeepSeek V3.2 vs Claude Opus
- ✅ **Instalación automática**: Un comando en cada plataforma
- ✅ **Configuración automática**: Todo se configura solo
- ✅ **Open Source**: MIT License

## 💰 **Comparación de costos**

| Modelo | Precio (1M tokens) | Ahorro vs Claude |
|--------|-------------------|------------------|
| Claude Opus | ~$0.40 | - |
| **DeepSeek V3.2** | **~$0.02** | **95%** |
| Claude Sonnet | ~$0.30 | 85% |
| Claude Haiku | ~$0.10 | 50% |

**Ejemplo**: 10M tokens/mes
- **Claude Opus**: $4.00
- **Huawei MaaS**: $0.20
- **Ahorro mensual**: $3.80
- **Ahorro anual**: $45.60

## 🚀 **Instalación rápida**

### **Windows (PowerShell):**
```powershell
# Ejecutar como Administrador
irm https://raw.githubusercontent.com/jarceg884/huawei-maas-claude-code/main/install.ps1 | iex
```

### **Linux/macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/jarceg884/huawei-maas-claude-code/main/install.sh | bash
```

## 📖 **Uso con comandos (como en Diario Vida)**

### **Comandos estilo Diario Vida (ds/dsdanger):**
```bash
# Como en el artículo original: https://diariovida.com/deepseek-claude-code-instalacion/
ds "Explica este código Python"              # Sesión normal
dsdanger "Refactoriza este archivo"          # Sin confirmaciones

# Para volver a Claude Opus original
claude "Pregunta normal a Claude"
```

### **Comandos mejorados (claude-maas/claude-m):**
```bash
# Usar Huawei MaaS (funciona en todas las plataformas)
claude-maas "Explica este código Python"

# Alias corto (más rápido)
claude-m "¿Cómo optimizar esta función?"

# Alias ultra corto
cm "Hola, ¿cómo estás?"

# Con archivos
claude-maas -f script.py "Analiza este código"

# Con contexto
claude-m --context "Proyecto Docker" "¿Cómo exponer puertos?"
```

### **Gestión del proxy:**
```bash
# Iniciar proxy Huawei MaaS
claude-maas start

# Ver estado del sistema
claude-maas status

# Probar conexión
claude-maas test

# Ver logs
claude-maas logs

# Detener proxy
claude-maas stop

# Configurar Claude Code
claude-maas setup

# Restaurar configuración original
claude-maas restore

# Verificar conexión proxy (nuevo)
check-proxy
```

### **Ayuda:**
```bash
claude-maas help
claude-m --help
cm -h
```

## 🔧 **Configuración**

### **1. Obtén tu API key de Huawei Cloud MaaS:**
1. Ve a [Huawei Cloud Console](https://console.huaweicloud.com/ai/maas/)
2. Crea una cuenta o inicia sesión
3. Genera una API key
4. Copia la key

### **2. Configura tu API key:**
```bash
# Edita el archivo .env
nano ~/free-claude-code/.env  # Linux/macOS
# O
notepad %USERPROFILE%\free-claude-code\.env  # Windows

# Reemplaza:
HUAWEI_MAAS_API_KEY="TU_API_KEY_AQUI"
# Con:
HUAWEI_MAAS_API_KEY="tu-api-key-real-aquí"
```

## 🎯 **Ejemplos prácticos**

### **Desarrollo web:**
```bash
claude-m -f index.html "Mejora el SEO de esta página"
claude-maas --context "React + TypeScript" "Crea un componente de botón"
```

### **DevOps:**
```bash
cm -f Dockerfile "Optimiza para producción"
claude-m "Configura CI/CD con GitHub Actions"
```

### **Análisis de datos:**
```bash
claude-maas -f data.csv "Analiza tendencias en estos datos"
cm "Genera visualización con Python pandas"
```

### **Documentación:**
```bash
claude-m -f README.md "Mejora esta documentación"
claude-maas "Traduce al inglés este texto técnico"
```

## 🏗️ **Arquitectura**

```
Claude Code CLI
        ↓
   Proxy local (free-claude-code)
        ↓
   Huawei Cloud MaaS API
        ↓
   DeepSeek V3.2 (20x más económico)
```

## 📁 **Estructura del proyecto**

```
huawei-maas-claude-code/
├── claude-maas.sh              # Comando principal Linux/macOS
├── claude-m.sh                 # Alias corto Linux/macOS
├── install.sh                  # Instalador Linux/macOS
├── install.ps1                 # Instalador Windows PowerShell
├── README.md                   # Este archivo
├── LICENSE                     # Licencia MIT
├── scripts/
│   ├── windows/                # Scripts específicos Windows
│   │   ├── start-proxy.ps1     # Iniciar proxy Windows
│   │   └── stop-proxy.ps1      # Detener proxy Windows
│   ├── linux/                  # Scripts específicos Linux
│   └── macos/                  # Scripts específicos macOS
├── config/
│   ├── .env.example            # Configuración de ejemplo
│   └── CONFIGURACION.md        # Guía de configuración
├── docs/                       # Documentación
└── examples/                   # Ejemplos de uso
```

## 🛠️ **Requisitos**

### **Windows:**
- PowerShell 5.1+
- Python 3.8+
- Node.js 18+
- Git (recomendado)

### **Linux:**
- Bash
- Python 3.8+
- Node.js 18+
- Git (recomendado)

### **macOS:**
- Zsh/Bash
- Python 3.8+
- Node.js 18+
- Git (recomendado)

## 🔍 **Verificación**

```bash
# Verificar instalación
claude-maas status

# Probar conexión Huawei MaaS
claude-maas test

# Probar con pregunta simple
claude-m "¿Estás usando Huawei Cloud MaaS con DeepSeek?"

# Ver todos los comandos
claude-maas help
```

## 🆘 **Solución de problemas**

### **Comandos no encontrados:**
```bash
# Agregar al PATH manualmente
export PATH="$HOME/.local/bin:$PATH"

# O reiniciar terminal
source ~/.bashrc  # o ~/.zshrc
```

### **Proxy no inicia:**
```bash
# Ver logs
claude-maas logs

# Verificar API key
cat ~/free-claude-code/.env | grep HUAWEI_MAAS_API_KEY

# Reiniciar
claude-maas stop
claude-maas start
```

### **Error de conexión:**
```bash
# Probar conexión directa
claude-maas test

# Verificar servicio
sudo systemctl status huawei-maas-proxy  # Linux
```

## 📚 **Documentación**

- [Guía Windows](docs/WINDOWS_GUIDE.md)
- [Guía Linux](docs/LINUX_GUIDE.md)  
- [Guía macOS](docs/MACOS_GUIDE.md)
- [Solución de problemas](docs/troubleshooting.md)
- [Comparación de costos](docs/cost-comparison.md)

## 🤝 **Contribuir**

¿Encontraste un bug? ¿Tienes una mejora?

1. Haz fork del repositorio
2. Crea una rama: `git checkout -b mi-mejora`
3. Haz commit: `git commit -am 'Agrega mejora'`
4. Haz push: `git push origin mi-mejora`
5. Abre un Pull Request

## 📄 **Licencia**

MIT License - ver [LICENSE](LICENSE)

## 👤 **Autor**

**jarceg884** - [GitHub](https://github.com/jarceg884)

## 🙏 **Agradecimientos**

- [free-claude-code](https://github.com/Alishahryar1/free-claude-code) - Proxy original
- [Huawei Cloud MaaS](https://www.huaweicloud.com/product/maas.html) - API de modelos
- [DeepSeek](https://www.deepseek.com/) - Modelos económicos y potentes
- [Diario Vida](https://diariovida.com/deepseek-claude-code-instalacion/) - Artículo inspirador

## ⭐ **¿Te gusta este proyecto?**

¡Dale una estrella en GitHub! ⭐

## 🔗 **Enlaces**

- [Repositorio](https://github.com/jarceg884/huawei-maas-claude-code)
- [Issues](https://github.com/jarceg884/huawei-maas-claude-code/issues)
- [Huawei Cloud MaaS](https://console.huaweicloud.com/ai/maas/)
- [Claude Code](https://docs.anthropic.com/claude/docs/claude-code)
- [Artículo Diario Vida](https://diariovida.com/deepseek-claude-code-instalacion/)

---

## 🔧 **Compatibilidad con el artículo de Diario Vida**

Este proyecto es **100% compatible** con el método descrito en [Diario Vida](https://diariovida.com/deepseek-claude-code-instalacion/), pero **mejorado**:

### **Lo que ellos hicieron:**
- ✅ Proxy `free-claude-code` ✓
- ✅ Comando `ds` para DeepSeek ✓
- ✅ Comando `dsdanger` sin confirmaciones ✓
- ✅ Variables de entorno `ANTHROPIC_BASE_URL` y `GATEWAY_MODEL_DISCOVERY` ✓

### **Lo que nosotros mejoramos:**
- ✅ **Multiplataforma**: Windows, Linux, macOS
- ✅ **Gestión completa**: `start`, `stop`, `status`, `logs`, `test`
- ✅ **Instalación automática**: Un solo comando
- ✅ **Comandos adicionales**: `claude-maas`, `claude-m`, `cm`
- ✅ **Configuración GUI**: Interfaz interactiva
- ✅ **Servicio systemd**: Inicio automático en Linux
- ✅ **Documentación completa**: README en español
- ✅ **Repositorio público**: Código abierto en GitHub

### **Comandos equivalentes:**

| Diario Vida | Huawei MaaS | Descripción |
|-------------|-------------|-------------|
| `ds` | `ds` | **Mismo comando** (compatibilidad total) |
| `dsdanger` | `dsdanger` | **Mismo comando** (compatibilidad total) |
| `claude` | `claude` | Claude Opus original (sin cambios) |
| - | `claude-maas` | Nuestro comando mejorado |
| - | `claude-m` | Alias corto |
| - | `cm` | Alias ultra corto |
| - | `claude-maas start` | Iniciar proxy |
| - | `claude-maas status` | Ver estado |
| - | `claude-maas test` | Probar conexión |

### **Instalación comparada:**

**Ellos (Diario Vida):**
```bash
# Manual con prompts
1. Clonar free-claude-code
2. Configurar .env manualmente
3. Instalar dependencias manualmente
4. Crear alias ds y dsdanger manualmente
5. Configurar variables de entorno manualmente
```

**Nosotros (Huawei MaaS):**
```bash
# Automático
curl -fsSL https://raw.githubusercontent.com/jarceg884/huawei-maas-claude-code/main/install.sh | bash
# ¡Todo configurado automáticamente!
```

**¡Disfruta de Claude con un 95% de ahorro usando `ds`, `claude-m` o `cm`!** 🎉