#!/usr/bin/env bash
# reporte_sistema.sh - Versión compatible con Git Bash (Windows)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${ROOT_DIR}/config.env"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

LOG_DIR="${LOG_DIR:-${ROOT_DIR}/logs}"
mkdir -p "$LOG_DIR"

TS="$(date +%Y%m%d-%H%M%S)"
OUT="${LOG_DIR}/reporte_${TS}.txt"

{
  echo "===== REPORTE DEL SISTEMA ($TS) ====="
  echo "Host: $(hostname)"
  echo "Sistema operativo: Windows (Git Bash)"
  echo

 echo "== PROCESOS ACTIVOS (muestra limitada por compatibilidad) =="
ps | head -n 10
echo

  echo "== USO DE DISCO =="
  df -h
  echo

  echo "== ÚLTIMOS 5 LOGS DE BACKUP =="
  ls -1t "${LOG_DIR}"/backup_*.log 2>/dev/null | head -n 5 || echo "(no hay logs de backup)"
} > "$OUT"

echo "Reporte generado en: $OUT"