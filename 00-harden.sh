#!/bin/bash
# 00-harden.sh  --  First 5 minutes on IGNITION (Fedora 38, scored: SSH + Open WebUI)
# Run as: sudo bash 00-harden.sh
# Does the irreversible-if-you-wait stuff: passwords, backup, firewall, sshd, signups.
# It does NOT touch jmoney's password (change that in NEIGH, not here) and does NOT
# delete users (you review hunt.sh output first).
set -u
log(){ echo -e "\n=== $* ==="; }

if [ "$(id -u)" -ne 0 ]; then echo "run with sudo"; exit 1; fi

# ---------------------------------------------------------------------------
# 1. BACKUP FIRST (before you change anything, so you have a clean-ish source)
# ---------------------------------------------------------------------------
log "Backup /etc /home /root /opt /var/www"
mkdir -p /root/.backup
cp -rp /etc /home /root /opt /var/www /root/.backup/ 2>/dev/null
# webui.db if Open WebUI is a docker volume (copied by webui_backup.sh too)
chattr -R +i /root/.backup 2>/dev/null && echo "backup made immutable (chattr +i)"

# ---------------------------------------------------------------------------
# 2. PASSWORDS -- change plinktern + root. Prompts you for each.
#    jmoney is handled in NEIGH, so it is intentionally skipped here.
# ---------------------------------------------------------------------------
log "Change passwords (skip jmoney -- do that in NEIGH)"
for u in plinktern root; do
  if id "$u" &>/dev/null; then
    echo "--> set new password for $u"
    passwd "$u"
  fi
done

# ---------------------------------------------------------------------------
# 3. FIREWALL -- allow ONLY scored services: ssh + http. (Open WebUI = port 80)
# ---------------------------------------------------------------------------
log "firewalld: allow ssh + http only"
systemctl enable --now firewalld
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=http
# If Open WebUI is on 8080 instead of 80, uncomment:
# firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload
firewall-cmd --list-all

# ---------------------------------------------------------------------------
# 4. SSHD -- lock down without breaking the jmoney password login the scorer uses
#    (so we KEEP PasswordAuthentication on, just disable root + limit tries)
# ---------------------------------------------------------------------------
log "Harden sshd (keep password auth -- scorer needs it)"
d=/etc/ssh/sshd_config.d
mkdir -p "$d"
cat > "$d/00-plinko.conf" <<'EOF'
PermitRootLogin no
MaxAuthTries 3
PermitEmptyPasswords no
X11Forwarding no
# PasswordAuthentication stays YES -- jmoney score check logs in by password
EOF
sshd -t && systemctl restart sshd && echo "sshd restarted OK" || echo "!! sshd config test FAILED, not restarted"

# ---------------------------------------------------------------------------
# 5. OPEN WEBUI -- turn off new signups so Red Team can't register
# ---------------------------------------------------------------------------
log "Open WebUI: disable signups (if running in docker)"
if command -v docker &>/dev/null && docker ps --format '{{.Names}}' | grep -q open-webui; then
  docker exec open-webui sh -c 'echo "disable signups in Admin Panel > Settings > General manually too"' 2>/dev/null
  echo ">> ALSO do it in the web Admin Panel: Settings > General > Enable New Sign Ups = OFF"
else
  echo "open-webui container not found by that name -- check: docker ps"
fi

log "DONE. Now run: sudo bash 10-recon.sh  then  sudo bash 20-hunt.sh"
