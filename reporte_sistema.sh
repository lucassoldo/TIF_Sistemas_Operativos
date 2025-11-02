#!/usr/bin/env bash
# reporte_sistema.sh - Genera un informe de uso de CPU, memoria y disco
# Guarda el informe en logs/reporte_YYYYmmdd-HHMMSS.txt

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
  echo "Host: $(hostname) - SO: $(uname -srmo)"
  echo
  echo "== UPTIME =="
  uptime
  echo
  echo "== CPU (top 5 procesos por CPU) =="
  # top no-interactivo, ordenar por %CPU, mostrar 5 primeros procesos
  ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6
  echo
  echo "== MEMORIA =="
  free -h
  echo
  echo "== DISCO (montajes principales) =="
  df -hT | awk 'NR==1 || $2!="tmpfs" {print}'
  echo
  echo "== Uso de inodos =="
  df -i | head -n 10
  echo
  echo "== Últimos 5 logs de backup (si existen) =="
  ls -1t "${LOG_DIR}"/backup_*.log 2>/dev/null | head -n 5 || echo "(no hay logs de backup)"
} > "$OUT"

echo "Reporte generado en: $OUT"
