#!/bin/bash
# claude-m - Alias corto para claude-maas (Huawei Cloud MaaS + Claude Code)
# Uso: claude-m "tu pregunta" [opciones]

# Ruta al script principal
CLAUDE_MAAS_SCRIPT="$(dirname "$0")/claude-maas.sh"

# Si claude-maas.sh existe en el mismo directorio, usarlo
if [ -f "$CLAUDE_MAAS_SCRIPT" ]; then
    exec "$CLAUDE_MAAS_SCRIPT" "$@"
fi

# Si no, buscar en PATH
if command -v claude-maas >/dev/null 2>&1; then
    exec claude-maas "$@"
fi

# Si no se encuentra, mostrar error
echo "❌ Error: comando 'claude-maas' no encontrado" >&2
echo "Instala primero con:" >&2
echo "  curl -fsSL https://raw.githubusercontent.com/jarceg884/huawei-maas-claude-code/main/install.sh | bash" >&2
exit 1