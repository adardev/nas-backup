# NAS Backup - Configuracion reproducible

Repositorio de respaldo de la configuracion del NAS adarlpz-nas
(Debian 13, ThinkCentre M73).

## Estructura

```
docker/compose.yml              # File Browser + Syncthing
scripts/move_photos.sh           # Archivado automatico de multimedia
systemd/
  move-photos.service            # Servicio que ejecuta move_photos.sh
  smartctl-hdparm.service        # Tuneado de discos (OMV)
nginx/
  openmediavault-webgui          # Config del reverse proxy nginx
  security.conf                  # Headers de seguridad
omv/
  fusemergerfs.inc               # Backend OMV para fuse.mergerfs
syncthing/
  .stignore.root                 # Patrones ignore raiz del NAS
  .stignore.adaredu              # Patrones ignore carpeta adaredu
system/
  cron.root.txt                  # Cron obsoleto (ya no se usa)
  resolv.conf                    # DNS stub resolver
docs/
  migracion.md                   # Guia completa de migracion
```

## Servidor actual

- **Hardware**: Lenovo ThinkCentre M73 (2014)
- **OS**: Debian 13 (trixie), kernel 6.19.10
- **IP**: 192.168.0.2/24
- **Discos**: sda (15G root + 95G data) + sdb (469G data)
- **Storage**: mergerfs pool `adarlpz-nas` (563G total, politica epmfs)

### Servicios

| Servicio | Puerto | Descripcion |
|----------|--------|-------------|
| SSH | 22 | Acceso remoto |
| Nginx | 80 | OpenMediaVault Web GUI |
| File Browser | 8080 | Navegador de archivos web |
| Syncthing | 8384 | Sincronizacion de archivos |
| Docker | - | Contenedores File Browser y Syncthing |

### Dispositivos Syncthing

- `adarlpz-nas` (servidor)
- `adarlpz-android` (celular adarlpz)
- `mani-android` (celular mani)
- `adarlpz-windows` (PC adarlpz)
- `adaredu-windows` (PC adaredu)

## No incluido deliberadamente

Este repositorio NO contiene por seguridad:

- Claves SSH privadas
- Certificados TLS/SSL
- Config de Syncthing (config.xml, API keys)
- Base de datos de File Browser
- Config completa de OpenMediaVault
- JWT tokens
- Datos multimedia

Para restaurar estos archivos, usar un backup cifrado externo.

## Migracion

Ver [docs/migracion.md](docs/migracion.md) para la guia completa.
