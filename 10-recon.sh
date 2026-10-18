#!/bin/bash
# 10-recon.sh  --  Snapshot the box's state to a baseline file you can diff later.
# Run as: sudo bash 10-recon.sh     (run it once early; re-run and diff later)
set -u
out="/root/baseline_$(date +%Y%m%d_%H%M%S).txt"
exec > >(tee "$out") 2>&1

echo "######## RECON $(date) $(hostname) ########"

echo -e "\n==== USERS (UID 0 or >=1000) ===="
awk -F: '$3>=1000 || $3==0 {print $1" uid="$3" shell="$7}' /etc/passwd

echo -e "\n==== SUDO / WHEEL ===="
getent group wheel
echo "--- /etc/sudoers.d ---"; ls -la /etc/sudoers.d/ 2>/dev/null
grep -rvE '^\s*#|^\s*$' /etc/sudoers /etc/sudoers.d/ 2>/dev/null

echo -e "\n==== LISTENING PORTS ===="
ss -tlnp; echo "--- udp ---"; ss -ulnp

echo -e "\n==== CRON ===="
for u in $(cut -f1 -d: /etc/passwd); do c=$(crontab -l -u "$u" 2>/dev/null); [ -n "$c" ] && echo "# $u:" && echo "$c"; done
ls -la /etc/cron* /var/spool/cron/ 2>/dev/null

echo -e "\n==== SYSTEMD TIMERS ===="
systemctl list-timers --all --no-pager

echo -e "\n==== SSH AUTHORIZED KEYS ===="
find / -name authorized_keys -exec echo "--- {} ---" \; -exec cat {} \; 2>/dev/null

echo -e "\n==== SUID BINARIES ===="
find / -perm -4000 -type f 2>/dev/null

echo -e "\n==== PROCESS TREE ===="
ps -efww --forest

echo -e "\n==== DOCKER ===="
docker ps -a 2>/dev/null; docker images 2>/dev/null

echo -e "\n==== LOGGED-IN / RECENT LOGINS ===="
who; echo "--- last -10 ---"; last -10

echo -e "\n######## baseline saved to $out ########"
