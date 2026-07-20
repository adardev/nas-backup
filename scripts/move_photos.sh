#!/bin/bash
set -euo pipefail

ADARLPZ="/srv/mergerfs/adarlpz-nas/adarlpz"
MANI="/srv/mergerfs/adarlpz-nas/mani"
DEST_ADARLPZ="$ADARLPZ/gallery"
DEST_MANI="$MANI/galeria"

mkdir -p "$DEST_ADARLPZ" "$DEST_MANI"

for dir in \
  "$ADARLPZ/.temp_adarlpz_photos" \
  "$ADARLPZ/.temp_adarlpz_screenshots" \
  "$ADARLPZ/.temp_adarlpz_whatsapp" \
  "$ADARLPZ/.temp_adarlpz_screenrecordings" \
  "$ADARLPZ/.temp_adarlpz_lightroom" \
  "$ADARLPZ/.temp_adarlpz_whatsappvideos" \
  "$ADARLPZ/.temp_adarlpz_quickshare"; do
  find "$dir" -maxdepth 1 -type f -mmin +0.08 -exec mv -- {} "$DEST_ADARLPZ" \;
done

for dir in \
  "$MANI/.temp_mani_photos" \
  "$MANI/.temp_mani_screenshots" \
  "$MANI/.temp_mani_whatsapp" \
  "$MANI/.temp_mani_screenrecordings" \
  "$MANI/.temp_mani_whatsappvideos" \
  "$MANI/.temp_mani_quickshare"; do
  find "$dir" -maxdepth 1 -type f -mmin +0.08 -exec mv -- {} "$DEST_MANI" \;
done

chown -R 1000:1000 "$DEST_ADARLPZ" "$DEST_MANI"
chmod -R 775 "$DEST_ADARLPZ" "$DEST_MANI"
