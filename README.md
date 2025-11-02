# TIF - Sistemas Operativos (Bash)

Proyecto final que automatiza tareas comunes de administración en Linux usando **Bash**:

- Backup comprimido con retención automática
- Reporte de CPU, memoria y disco
- Limpieza de temporales y cachés

## Requisitos
- Linux (probado en Ubuntu Server/Desktop)
- `bash` 4+, `tar`, `gzip`, `df`, `free`, `ps`, `awk`
- Permisos `sudo` (solo si activás limpieza de `apt` o `journalctl`)

## Instalación y uso
```bash
git clone <tu-repo> tif-so
cd tif-so
chmod +x menu.sh backup.sh reporte_sistema.sh limpieza.sh
# Editá config.env según tus rutas
nano config.env
# Ejecutá
./menu.sh
```

## Configuración
Editá `config.env` para cambiar directorios, retención y opciones de limpieza.

## Ejemplos
- Backup de `~/pruebas-tif` -> genera `backups/backup_pruebas-tif_YYYYmmdd-HHMMSS.tar.gz`
- Reporte del sistema -> `logs/reporte_YYYYmmdd-HHMMSS.txt`
- Limpieza -> `logs/limpieza_YYYYmmdd-HHMMSS.log`

## Contribuir
Fork + PRs bienvenidos. Abrir issues con dudas o mejoras.

## Licencia
MIT
