# Migracion NAS

Guia paso a paso para recrear el servidor en hardware nuevo.

## Requisitos previos

- Debian 13 (trixie) o superior
- usuario `root` con acceso SSH
- IP estatica `192.168.0.2/24` en `eno1`
- TimeZone: `America/Mexico_City`

## 1. Paquetes base

```bash
apt update && apt install -y \
  docker.io docker-compose-v2 \
  mergerfs \
  nginx php8.4-fpm \
  openmediavault-keyring \
  smartmontools hdparm
```

## 2. Discos

Identificar discos con `lsblk` y `blkid`. En el servidor actual:

| Disco | UUID | Tamano | Montaje OMV |
|-------|------|--------|-------------|
| sda (3 particiones) | sda2: `bf5f1b50-...` | 15G (root) | `/` |
| | sda3: `05f75cee-...` | 95G | `/srv/dev-disk-by-uuid-05f75cee-...` |
| sdb1 | `43007630-...` | 469G | `/srv/dev-disk-by-uuid-43007630-...` |

Agregar a `/etc/fstab`:

```
/dev/disk/by-uuid/43007630-4746-4f1c-9703-538ae923dcaa  /srv/dev-disk-by-uuid-43007630-4746-4f1c-9703-538ae923dcaa  ext4  defaults,nofail,user_xattr,usrquota,grpquota,acl  0 2
/dev/disk/by-uuid/05f75cee-0c30-4dec-abf6-55a1bae2d47e  /srv/dev-disk-by-uuid-05f75cee-0c30-4dec-abf6-55a1bae2d47e  ext4  defaults,nofail,user_xattr,usrquota,grpquota,acl  0 2
```

## 3. Mergerfs

Agregar la siguiente linea al final de `/etc/fstab`:

```
adarlpz:6aca0c86-abf0-4ba7-b598-3b35e78c2aaf  /srv/mergerfs/adarlpz-nas  fuse.mergerfs  defaults,allow_other,nofail,category.create=epmfs,minfreespace=4G,fsname=adarlpz-nas  0  0
```

```bash
mkdir -p /srv/mergerfs/adarlpz-nas
mount -a
```

> **Nota**: Se usa fstab en vez de systemd mount unit porque systemd 257
> (Debian 13) requiere que el nombre del unit coincida exactamente con la
> ruta, y `fuse.mergerfs` genera conflictos con la validacion de nombres.
> El enfoque con fstab es mas confiable y simple.

Pool: fusiona los dos discos en `/srv/mergerfs/adarlpz-nas`
Politica: `epmfs` (existing path most free space), minfreespace=4G

### Backend OMV para fuse.mergerfs

OMV no incluye un backend para el tipo de filesystem `fuse.mergerfs`. Copiar
el archivo `omv/fusemergerfs.inc` a `/usr/share/php/openmediavault/system/filesystem/backend/`:

```bash
cp omv/fusemergerfs.inc /usr/share/php/openmediavault/system/filesystem/backend/
```

Esto permite que OMV reconozca y gestione pools mergerfs desde la interfaz web.

### Estructura de directorios

```
/srv/mergerfs/adarlpz-nas/
  adarlpz/        -> dueño: adarlpz (uid 1000)
    gallery/      <- destino final de fotos de adarlpz
    .temp_adarlpz_photos/
    .temp_adarlpz_screenshots/
    .temp_adarlpz_whatsapp/
    .temp_adarlpz_whatsappvideos/
    .temp_adarlpz_screenrecordings/
    .temp_adarlpz_lightroom/
    .temp_adarlpz_quickshare/
    comprobantes/
    concepts/
    gob/
    music/
    obsidian/
    recovery/
    ringtones/
    sat/
    scores/
    seguros/
    utils/
  mani/           -> dueño: mani (uid 1000)
    galeria/      <- destino final de fotos de mani
    documentos/
    .temp_mani_photos/
    .temp_mani_screenshots/
    .temp_mani_whatsapp/
    .temp_mani_whatsappvideos/
    .temp_mani_screenrecordings/
    .temp_mani_quickshare/
  adaredu/        -> dueño: adaredu (uid 1000)
    1densora/
    obsidian/
    os-configs/
    recovery/
    utils/
  public/
    adaredu/
    adarlpz/
    icons/
    os-setup/
```

## 4. Docker

```bash
mkdir -p /ComposeFiles/configs/filebrowser
mkdir -p /ComposeFiles/configs/syncthing
cp docker/compose.yml /ComposeFiles/filebrowser/compose.yml
cd /ComposeFiles/filebrowser
docker compose up -d
```

### Contenedores

| Servicio | Puerto | Ruta de config |
|----------|--------|----------------|
| File Browser | 8080 | `/ComposeFiles/configs/filebrowser/filebrowser.db` |
| Syncthing | 8384, 22000, 21027 | `/ComposeFiles/configs/syncthing/` |

### File Browser

- Monta `/srv/mergerfs/adarlpz-nas` como `/srv`
- Usuario: admin (definido en la BD)

### Syncthing

- Monta `/srv/mergerfs` como `/data`
- Usuario web: `adarlpz`
- Dispositivos conectados:
  - `adarlpz-nas` (este servidor)
  - `adarlpz-android` (celular de adarlpz)
  - `mani-android` (celular de mani)
  - `adarlpz-windows` (PC de adarlpz)
  - `adaredu-windows` (PC de adaredu)

**IMPORTANTE**: La configuracion de Syncthing (config.xml, cert.pem, key.pem) NO
se restaura de este repositorio. Se debe restaurar de un backup seguro o
reconfigurar desde la interfaz web en `http://192.168.0.2:8384`.

## 5. Move Photos (servicio systemd)

```bash
cp scripts/move_photos.sh /root/move_photos.sh
chmod +x /root/move_photos.sh
cp systemd/move-photos.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now move-photos.service
```

El servicio ejecuta `move_photos.sh` cada segundo en loop infinito. Mueve
archivos de las carpetas temporales (donde Syncthing recibe del telefono) a
`gallery/` (adarlpz) o `galeria/` (mani). Solo mueve archivos con mas de 5
minutos de antiguedad.

### Carpetas temporales -> Destino

**adarlpz**:
- `.temp_adarlpz_photos/` -> `gallery/`
- `.temp_adarlpz_screenshots/` -> `gallery/`
- `.temp_adarlpz_whatsapp/` -> `gallery/`
- `.temp_adarlpz_whatsappvideos/` -> `gallery/`
- `.temp_adarlpz_screenrecordings/` -> `gallery/`
- `.temp_adarlpz_lightroom/` -> `gallery/`
- `.temp_adarlpz_quickshare/` -> `gallery/`

**mani**:
- `.temp_mani_photos/` -> `galeria/`
- `.temp_mani_screenshots/` -> `galeria/`
- `.temp_mani_whatsapp/` -> `galeria/`
- `.temp_mani_whatsappvideos/` -> `galeria/`
- `.temp_mani_screenrecordings/` -> `galeria/`
- `.temp_mani_quickshare/` -> `galeria/`

## 6. Nginx / OpenMediaVault Web GUI

```bash
cp nginx/openmediavault-webgui /etc/nginx/sites-available/openmediavault-webgui
cp nginx/security.conf /etc/nginx/openmediavault-webgui.d/security.conf
cp omv/fusemergerfs.inc /usr/share/php/openmediavault/system/filesystem/backend/
systemctl enable --now nginx php8.4-fpm
```

## 7. Firewall

El servidor no tiene UFW ni reglas iptables custom. Las reglas activas son
las de Docker (FORWARD chain). Puertos expuestos:

| Puerto | Servicio |
|--------|----------|
| 22 | SSH |
| 80 | Nginx (OMV Web GUI) |
| 8080 | File Browser |
| 8384 | Syncthing GUI |
| 22000/tcp+udp | Syncthing (conexiones directas) |
| 21027/udp | Syncthing (local discovery) |

## 8. Servicios systemd custom

```bash
systemctl enable --now move-photos.service
systemctl enable --now smartctl-hdparm.service
```

## 9. Restaurar datos

1. Montar los discos y mergerfs
2. Restaurar datos desde backup a `/srv/mergerfs/adarlpz-nas/`
3. Los archivos Syncthing (`.stfolder`, `.stignore`, `.ttxfolder`) son
   generados automaticamente por Syncthing

## Cosas que NO estan en el repo

- `/root/login` y `/root/login.1`: JWT tokens de File Browser (sensibles)
- `/root/.ssh/id_rsa`: Clave privada SSH del servidor
- `/ComposeFiles/configs/syncthing/`: Config completa de Syncthing (incluye
  certificados, claves API, y config.xml)
- `/ComposeFiles/configs/filebrowser/filebrowser.db`: Base de datos de File Browser
- `/etc/openmediavault/config.xml`: Config completa de OMV (809 lineas)
- Datos multimedia en `gallery/` y `galeria/`

Estos archivos deben transferirse por canal seguro (USB cifrado, rsync over SSH,
etc).
