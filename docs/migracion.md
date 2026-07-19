# Migración

1. Instalar Docker, Docker Compose y mergerfs.
2. Crear `/srv/mergerfs/adarlpz` y montar allí los discos.
3. Crear `/ComposeFiles/configs/filebrowser` y `/ComposeFiles/configs/syncthing`.
4. Restaurar las configuraciones privadas de File Browser y Syncthing por un canal seguro; no usar las claves o bases de datos del repositorio.
5. Copiar `scripts/move_photos.sh` a `/root/move_photos.sh` y darle permisos de ejecución.
6. Instalar la línea de `system/cron.root.txt` en el crontab de root.
7. Ejecutar `docker compose -f docker/compose.yml up -d`.
8. Configurar en Syncthing las carpetas temporales y los dispositivos.

La configuración de Syncthing debe conservarse solo si se desea mantener los
IDs de dispositivos y carpetas actuales. En caso contrario, se puede crear una
configuración nueva desde la interfaz web.
