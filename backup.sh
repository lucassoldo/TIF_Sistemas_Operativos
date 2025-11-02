#!/usr/bin/env bash
# backup.sh - Realiza backup comprimido de un directorio y limpia backups antiguos
# Lee variables desde config.env:
#   BACKUP_SOURCE_DIR  (Directorio a respaldar)  - obligatorio
#   BACKUP_DEST_DIR    (Destino de backups)      - por defecto ./backups
#   BACKUP_RETENTION_DAYS (días a conservar)     - por defecto 7
#   LOG_DIR            (directorio de logs)      - por defecto ./logs

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${ROOT_DIR}/config.env"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

BACKUP_SOURCE_DIR="${BACKUP_SOURCE_DIR:-}"
BACKUP_DEST_DIR="${BACKUP_DEST_DIR:-${ROOT_DIR}/backups}"
LOG_DIR="${LOG_DIR:-${ROOT_DIR}/logs}"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"

mkdir -p "$BACKUP_DEST_DIR" "$LOG_DIR"

TS="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${LOG_DIR}/backup_${TS}.log"

if [[ -z "${BACKUP_SOURCE_DIR}" || ! -d "${BACKUP_SOURCE_DIR}" ]]; then
  echo "[ERROR] BACKUP_SOURCE_DIR no existe o no fue definido" | tee -a "$LOG_FILE"
  exit 2
fi

ARCHIVO="${BACKUP_DEST_DIR}/backup_$(basename "${BACKUP_SOURCE_DIR}")_${TS}.tar.gz"

{
  echo "[INFO] Iniciando backup: $(date -Is)"
  echo "[INFO] Origen: ${BACKUP_SOURCE_DIR}"
  echo "[INFO] Destino: ${ARCHIVO}"
  tar -czf "${ARCHIVO}" -C "$(dirname "${BACKUP_SOURCE_DIR}")" "$(basename "${BACKUP_SOURCE_DIR}")"
  echo "[OK]  Backup creado: ${ARCHIVO}"
  echo "[INFO] Aplicando retención de ${BACKUP_RETENTION_DAYS} días en ${BACKUP_DEST_DIR}"
  find "${BACKUP_DEST_DIR}" -type f -name "backup_*.tar.gz" -mtime +"${BACKUP_RETENTION_DAYS}" -print -delete
  echo "[OK]  Retención aplicada."
  echo "[INFO] Fin: $(date -Is)"
} | tee -a "$LOG_FILE"

exit 0
