#!/bin/bash
# 60-webshell-scan.sh  --  GUIDANCE (Ubuntu, PlinkCom = WordPress or MediaWiki).
# Finds common webshells + lets you diff the webroot against your backup.
#   sudo bash 60-webshell-scan.sh [webroot]   (default /var/www/html)
set -u
W="${1:-/var/www/html}"
echo "== webroot: $W =="

echo -e "\n== PHP files with webshell signatures =="
grep -rEl 'eval\(|base64_decode\(|system\(|shell_exec\(|passthru\(|assert\(|\$_(GET|POST|REQUEST)\[' \
  "$W" --include='*.php' 2>/dev/null

echo -e "\n== recently modified files (last 3 days) -- Red Team drops =="
find "$W" -type f -mtime -3 2>/dev/null

echo -e "\n== suspicious names in uploads =="
find "$W" -path '*upload*' -name '*.php' 2>/dev/null

echo -e "\n== find the DB password (so you can match MariaDB) =="
grep -riE "DB_PASSWORD|wgDBpassword" "$W" 2>/dev/null

echo -e "\n== diff against backup if you have one =="
echo "   diff -r /root/.backup/www $W   # adjust path to where you backed up the webroot"

echo -e "\n>> Remove any shell you find. Then re-check NEIGH that PlinkCom is green."
