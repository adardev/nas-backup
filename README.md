# Respaldo de migración NAS

Este repositorio contiene la configuración reproducible y sanitizada del NAS.

## Incluido

- `docker/compose.yml`: contenedores File Browser y Syncthing.
- `scripts/move_photos.sh`: archivado automático de multimedia.
- `systemd/srv-mergerfs-adarlpz.mount.example`: plantilla del montaje.
- `system/cron.root.txt`: tareas programadas.
- `docs/migracion.md`: pasos para restaurar en otro servidor.

## No incluido deliberadamente

No subir credenciales, archivos `.env`, bases de datos, índices de Syncthing,
claves privadas, certificados, tokens ni datos multimedia. Esos elementos deben
transferirse por un canal seguro y fuera de Git.
