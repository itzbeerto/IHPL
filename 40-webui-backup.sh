#!/bin/bash
# 40-webui-backup.sh  --  Back up / restore Open WebUI's database (the SCORED data:
# jmoney's account + his previous chats). The score check reads his old chats, so if
# Red Team wipes them you fail even with the site up. Keep a copy off the box too.
#
# Usage:  sudo bash 40-webui-backup.sh backup
#         sudo bash 40-webui-backup.sh restore /root/webui-backups/webui_YYYYmmdd_HHMMSS.db
set -u
C=open-webui                      # container name
DB=/app/backend/data/webui.db     # path inside the container
DEST=/root/webui-backups
mkdir -p "$DEST"

case "${1:-}" in
  backup)
    f="$DEST/webui_$(date +%Y%m%d_%H%M%S).db"
    docker cp "$C:$DB" "$f" && echo "backed up -> $f"
    echo "Copy it OFF the box too:  scp $f fedora@<blackbox-or-your-laptop>:~"
    ;;
  restore)
    src="${2:?give a backup file path}"
    [ -f "$src" ] || { echo "no such file: $src"; exit 1; }
    docker cp "$src" "$C:$DB" && docker restart "$C" && echo "restored $src and restarted $C"
    ;;
  *)
    echo "usage: $0 backup | restore <file>"
    ;;
esac
