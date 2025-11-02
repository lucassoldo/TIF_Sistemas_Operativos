# Memoria técnica - TIF Sistemas Operativos

## 1. Introducción
Este proyecto implementa tres tareas automatizadas con **Bash**: (a) backup comprimido con retención, (b) reporte de CPU/memoria/disco y (c) limpieza de temporales y caché. Se entrega con menú interactivo y archivo de configuración para modificar parámetros sin tocar el código.

## 2. Requisitos técnicos
- SO: Cualquier distribución Linux (probado en Ubuntu 22.04/24.04)
- Paquetes: bash 4+, coreutils, tar, gzip, psutils (ps), awk
- (Opcional) `sudo`, `apt-get`, `journalctl` para funciones extendidas de limpieza

## 3. Estructura del proyecto
```
.
├── menu.sh
├── backup.sh
├── reporte_sistema.sh
├── limpieza.sh
├── config.env
├── backups/         # resultados de backup
├── logs/            # reportes y logs
└── docs/
    └── memoria_tecnica.md
```

## 4. Desarrollo y explicación del código
### 4.1 Menú (`menu.sh`)
- Provee interfaz con colores, validación de opciones (1-4) y llamadas a cada script.
- Carga `config.env` si existe para compartir variables (LOG_DIR, etc.).
- Maneja códigos de salida y muestra mensajes de estado.

### 4.2 Backup (`backup.sh`)
- Variables: `BACKUP_SOURCE_DIR`, `BACKUP_DEST_DIR`, `BACKUP_RETENTION_DAYS`.
- Comando central: `tar -czf` para comprimir el directorio origen.
- Limpieza: `find ... -mtime +RETENCION -delete` para eliminar backups antiguos.
- Log: escribe en `logs/backup_*.log` cada ejecución.

### 4.3 Reporte del sistema (`reporte_sistema.sh`)
- Obtiene uptime, top 5 procesos por CPU (con `ps`), estado de memoria (`free -h`), uso de disco (`df -hT`).
- Incluye uso de inodos (`df -i`) y listado de últimos logs de backup para correlacionar eventos.

### 4.4 Limpieza (`limpieza.sh`)
- Elimina archivos viejos de `/tmp` y `/var/tmp` (> 7 días).
- Limpia caché de usuario `~/.cache` si `CLEAN_USER_CACHE=true`.
- Opcional: `apt-get clean` y `journalctl --vacuum-size` si se activan y existe `sudo`.

## 5. Pruebas y validación
1. **Backup**: crear directorio de prueba (`mkdir -p ~/pruebas-tif && echo hola > ~/pruebas-tif/a.txt`), ejecutar `./backup.sh`. Verificar `.tar.gz` y log.
2. **Reporte**: ejecutar `./reporte_sistema.sh` y abrir `logs/reporte_*.txt`.
3. **Limpieza**: crear archivos viejos en `/tmp` y correr `./limpieza.sh`. Revisar `logs/limpieza_*.log`.
4. Menú: `./menu.sh` y probar opciones 1-3 y salida 4.
5. Retención: crear backups artificiales y chequear borrado con `find -mtime`.

> Capturas sugeridas: terminal mostrando menú, creación de backup, contenido de `logs/` y un fragmento del reporte.

## 6. Dificultades y mejoras
- **Diferencias entre distros**: comandos como `apt-get`/`journalctl` pueden no estar o requerir permisos.
- **Permisos**: limpieza de sistema puede requerir `sudo`. Se maneja de forma opcional.
- **Mejoras futuras**: agregar gestión de usuarios, actualizaciones del sistema, y sincronización `rsync` como módulos adicionales, además de tests automáticos (bats).

## 7. Conclusiones
Se cumplió con el objetivo integrando tareas de administración en un menú en Bash, con buenas prácticas: `set -euo pipefail`, logs, validación, colores y archivo de configuración editable.
