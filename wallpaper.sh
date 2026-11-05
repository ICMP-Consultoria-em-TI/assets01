#!/bin/bash
URL="https://raw.githubusercontent.com/ICMP-Consultoria-em-TI/assets01/main/wallpaper.jpg"
DIR="/Library/Application Support/ICMP"
IMG="$DIR/wallpaper_pg.jpg"
LOG="/Library/Logs/ICMP_wallpaper.log"

log() { echo "$(date '+%Y-%m-%dT%H:%M:%S') | $1" >> "$LOG"; }

log "iniciou | whoami=$(whoami)"
mkdir -p "$DIR"

if ! curl -fsSL -o "$IMG" "$URL"; then
  log "ERRO: falha ao baixar a imagem"
  exit 1
fi
chmod 644 "$IMG"
log "imagem baixada"

USER_NAME=$(stat -f%Su /dev/console)
if [ -z "$USER_NAME" ] || [ "$USER_NAME" = "root" ] || [ "$USER_NAME" = "_mbsetupuser" ]; then
  log "nenhum usuario logado; nada aplicado"
  exit 0
fi
USER_ID=$(id -u "$USER_NAME")
log "usuario=$USER_NAME uid=$USER_ID"

SCRIPT="tell application \"System Events\" to tell every desktop to set picture to POSIX file \"$IMG\""

if [ "$(id -u)" -eq 0 ]; then
  OUT=$(launchctl asuser "$USER_ID" sudo -u "$USER_NAME" /usr/bin/osascript -e "$SCRIPT" 2>&1)
else
  OUT=$(/usr/bin/osascript -e "$SCRIPT" 2>&1)
fi
RC=$?

if [ $RC -eq 0 ]; then
  log "papel de parede aplicado"
else
  log "ERRO ao aplicar (rc=$RC): $OUT"
fi
log "concluido"