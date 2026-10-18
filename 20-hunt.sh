#!/bin/bash
# 20-hunt.sh  --  Persistence / IOC sweep. Read every line of output yourself.
# Run as: sudo bash 20-hunt.sh      (flags things; does NOT auto-delete)
set -u
hit(){ echo -e ">>> $*"; }

echo "######## HUNT $(date) ########"

hit "Extra UID 0 accounts (should be ONLY root):"
awk -F: '$3==0 {print "   "$1}' /etc/passwd

hit "Users with a login shell + password set recently (check /etc/shadow dates):"
awk -F: '$7 !~ /nologin|false/ {print "   "$1" "$7}' /etc/passwd

hit "authorized_keys everywhere (any key you did not put = remove it):"
find / -name authorized_keys -exec echo "   {}:" \; -exec sed 's/^/     /' {} \; 2>/dev/null

hit "Cron jobs (per-user + system):"
for u in $(cut -f1 -d: /etc/passwd); do c=$(crontab -l -u "$u" 2>/dev/null); [ -n "$c" ] && echo "   [$u] $c"; done
grep -rvE '^\s*#|^\s*$' /etc/cron* /etc/crontab 2>/dev/null | sed 's/^/   /'

hit "systemd timers (not the stock ones):"
systemctl list-timers --all --no-pager | sed 's/^/   /'

hit "Shell rc files with suspicious payloads (curl|wget|nc|bash -i|base64):"
grep -rEl 'curl|wget|nc |ncat|bash -i|base64 -d|/dev/tcp' /root /home/*/.bashrc /home/*/.bash_profile /etc/profile.d/ 2>/dev/null | sed 's/^/   /'

hit "SUID binaries added by attacker (compare to a stock list -- odd ones like bash/find/python with SUID are BAD):"
find / -perm -4000 -type f 2>/dev/null | grep -vE '/(sudo|su|passwd|chsh|chfn|newgrp|gpasswd|mount|umount|pkexec|ping|crontab|at|fusermount)' | sed 's/^/   /'

hit "Package files modified since install (rpm -Va, lines starting with ..5 = content changed):"
rpm -Va 2>/dev/null | grep -E '^..5|^missing' | head -40 | sed 's/^/   /'

hit "Listening ports NOT ssh(22)/http(80) -- investigate each:"
ss -tlnp | awk 'NR>1 && $4 !~ /:22$|:80$|127.0.0/ {print "   "$4" "$6}'

hit "Open WebUI Functions/Tools run server-side Python -- check them in the web Admin Panel > Functions AND Workspace > Tools. Nothing you did not add."

echo "######## review each >>> block. Remove what you did not create. ########"
