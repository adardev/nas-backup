#!/bin/bash
set -euo pipefail

DEST="/srv/mergerfs/adarlpz/gallery/"
mkdir -p "$DEST"

for source in \
  /srv/mergerfs/adarlpz/.temp_adarlpz_photos/ \
  /srv/mergerfs/adarlpz/.temp_adarlpz_screenshots/ \
  /srv/mergerfs/adarlpz/.temp_adarlpz_whatsapp/ \
  /srv/mergerfs/adarlpz/.temp_adarlpz_screenrecordings/ \
  /srv/mergerfs/adarlpz/.temp_adarlpz_lightroom/ \
  /srv/mergerfs/adarlpz/.temp_adarlpz_whatsappvideos/ \
  /srv/mergerfs/adarlpz/.temp_mani_photos/ \
  /srv/mergerfs/adarlpz/.temp_mani_screenshots/ \
  /srv/mergerfs/adarlpz/.temp_mani_whatsapp/ \
  /srv/mergerfs/adarlpz/.temp_mani_screenrecordings/ \
  /srv/mergerfs/adarlpz/.temp_mani_whatsappvideos/; do
  mkdir -p "$source"
  find "$source" -maxdepth 1 -type f -mmin +2 -exec mv -- {} "$DEST" \;
done

chown -R 1000:1000 "$DEST"
chmod -R 775 "$DEST"
