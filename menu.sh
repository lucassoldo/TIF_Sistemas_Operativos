#!/usr/bin/env bash
# menu.sh - Menú interactivo para ejecutar tareas del TIF de Sistemas Operativos
# Requiere: bash 4+, GNU coreutils, tar, gzip
# Uso: ./menu.sh
# Carga configuración desde config.env si existe

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${ROOT_DIR}/config.env"

# Cargar configuración si existe
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
fi

# Colores
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; CYAN="\e[36m"; RESET="\e[0m"

# Validación de dependencias mínimas
need() {
  command -v "$1" >/dev/null 2>&1 || { echo -e "${RED}Falta dependencia: $1${RESET}"; exit 1; }
}
for bin in tar gzip df uname date; do need "$bin"; done

titulo() {
  echo -e "${BLUE}==============================================${RESET}"
  echo -e "${CYAN}   TIF - Sistemas Operativos (Bash)           ${RESET}"
  echo -e "${BLUE}==============================================${RESET}"
}

pausa() {
  echo -e "\nPresioná ENTER para continuar..."
  read -r _
}

op_backup() {
  "${ROOT_DIR}/backup.sh"
  local rc=$?
  if [[ $rc -eq 0 ]]; then
    echo -e "${GREEN}Backup ejecutado correctamente.${RESET}"
  else
    echo -e "${RED}El backup terminó con código ${rc}.${RESET}"
  fi
  pausa
}

op_reporte() {
  "${ROOT_DIR}/reporte_sistema.sh"
  local rc=$?
  if [[ $rc -eq 0 ]]; then
    echo -e "${GREEN}Reporte generado correctamente.${RESET}"
  else
    echo -e "${RED}El reporte terminó con código ${rc}.${RESET}"
  fi
  pausa
}

op_limpieza() {
  "${ROOT_DIR}/limpieza.sh"
  local rc=$?
  if [[ $rc -eq 0 ]]; then
    echo -e "${GREEN}Limpieza ejecutada correctamente.${RESET}"
  else
    echo -e "${RED}La limpieza terminó con código ${rc}.${RESET}"
  fi
  pausa
}

# Validación de entrada (tarea extra)
es_opcion_valida() {
  [[ "$1" =~ ^[1-4]$ ]]
}

while true; do
  clear
  titulo
  echo -e "${YELLOW}Directorio del proyecto:${RESET} ${ROOT_DIR}"
  echo -e "\nSeleccioná una opción:"
  echo -e "  ${GREEN}1)${RESET} Backup del trabajo TIF"
  echo -e "  ${GREEN}2)${RESET} Generar reporte de CPU, memoria y disco"
  echo -e "  ${GREEN}3)${RESET} Limpieza de temporales y caché"
  echo -e "  ${GREEN}4)${RESET} Salir"
  echo -n "Opción: "
  read -r opcion
  if ! es_opcion_valida "${opcion:-}"; then
    echo -e "${RED}Opción inválida. Elegí 1-4.${RESET}"
    sleep 1.2
    continue
  fi

  case "$opcion" in
    1) op_backup ;;
    2) op_reporte ;;
    3) op_limpieza ;;
    4) echo -e "${CYAN}¡Hasta luego!${RESET}"; exit 0 ;;
  esac
done
