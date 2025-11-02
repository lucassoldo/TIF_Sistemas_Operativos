#!/usr/bin/env bash
# limpieza.sh - Elimina archivos temporales y caché para liberar espacio
# Lee variables opcionales desde config.env:
#   CLEAN_USER_CACHE=true|false (default true)
#   CLEAN_APT_CACHE=true|false  (default false) -> requiere sudo en Debian/Ubuntu
#   CLEAN_JOURNAL=false|true    (default false) -> requiere sudo y systemd
#   LOG_DIR

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${ROOT_DIR}/config.env"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

LOG_DIR="${LOG_DIR:-${ROOT_DIR}/logs}"
CLEAN_USER_CACHE="${CLEAN_USER_CACHE:-true}"
CLEAN_APT_CACHE="${CLEAN_APT_CACHE:-false}"
CLEAN_JOURNAL="${CLEAN_JOURNAL:-false}"

mkdir -p "$LOG_DIR"
TS="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${LOG_DIR}/limpieza_${TS}.log"

log(){ echo "[$(date -Is)] $*" | tee -a "$LOG_FILE"; }

log "Inicio de limpieza"

# 1) /tmp y /var/tmp (archivos >7 días)
for d in /tmp /var/tmp; do
  if [[ -d "$d" ]]; then
    log "Limpiando archivos antiguos en $d"
    find "$d" -type f -mtime +7 -print -delete 2>>"$LOG_FILE" || true
  fi
done

# 2) Caché de usuario (~/.cache)
if [[ "$CLEAN_USER_CACHE" == "true" ]]; then
  if [[ -d "$HOME/.cache" ]]; then
    log "Limpiando caché de usuario en $HOME/.cache"
    find "$HOME/.cache" -type f -mtime +7 -print -delete 2>>"$LOG_FILE" || true
  else
    log "No existe $HOME/.cache"
  fi
else
  log "CLEAN_USER_CACHE=false -> saltando"
fi

# 3) Caché de apt (solo Debian/Ubuntu)
if [[ "$CLEAN_APT_CACHE" == "true" ]]; then
  if command -v apt-get >/dev/null 2>&1; then
    log "Limpiando caché de apt (requiere sudo)"
    if sudo -n true 2>/dev/null; then
      sudo apt-get clean >>"$LOG_FILE" 2>&1 || true
    else
      log "No hay sudo sin contraseña. Ejecutar manualmente: sudo apt-get clean"
    fi
  else
    log "Sistema no Debian/Ubuntu. Saltando apt-get clean."
  fi
else
  log "CLEAN_APT_CACHE=false -> saltando"
fi

# 4) Registros de journalctl (opcional)
if [[ "$CLEAN_JOURNAL" == "true" ]]; then
  if command -v journalctl >/dev/null 2>&1; then
    log "Compactando logs de journalctl a 100M (requiere sudo)"
    if sudo -n true 2>/dev/null; then
      sudo journalctl --vacuum-size=100M >>"$LOG_FILE" 2>&1 || true
    else
      log "No hay sudo sin contraseña. Ejecutar manualmente: sudo journalctl --vacuum-size=100M"
    fi
  else
    log "journalctl no disponible."
  fi
else
  log "CLEAN_JOURNAL=false -> saltando"
fi

log "Limpieza finalizada"
echo "Limpieza registrada en: $LOG_FILE"
