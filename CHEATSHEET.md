# IGNITION cheat sheet — HPCC4 (Fedora 38 · scored: SSH + Open WebUI)

Printed notes are allowed. Print this. t = your team number.

## Box facts
- ignition = 172.16.t.20, Fedora 38. dnf, firewalld, wheel group, SELinux.
- Scored: (1) SSH — jmoney logs in + runs basic cmds. (2) Open WebUI (http://172.16.t.20)
  — jmoney@plinko.horse logs in, sees models, READS HIS OLD CHATS.
- Default login everywhere: plinktern / H00ves0nTheM00n (zeroes). plinktern = admin.
- blackbox (.5) is OUT of scope for Red Team = your safe spot. Copy backups there.

## First 15 minutes (order matters)
1. `sudo bash 00-harden.sh`  — backup, change plinktern+root pw, firewall, sshd, (signups).
2. Change jmoney's password in **NEIGH → Users** (NOT on the box). Don't disable jmoney.
3. `sudo bash 10-recon.sh`   — saves /root/baseline_*.txt. Read it.
4. `sudo bash 20-hunt.sh`    — remove any key/user/cron/timer/Function you didn't create.
5. `sudo bash 40-webui-backup.sh backup` — then scp it to blackbox.
6. `tmux new -s watch 'sudo bash 30-watch.sh'` — leave running. Ctrl-b d to detach.

## DON'T (these fail score checks)
- DON'T set `PasswordAuthentication no` — scorer logs in jmoney by password.
- DON'T disable/delete jmoney.
- DON'T block IP ranges — scorer shares IPs with Red Team.
- DON'T stop/replace the log collector (sends to OpenObserve on blackbox).
- DON'T turn SELinux off. If it's already off, that's suspicious.

## Open WebUI hardening (web Admin Panel)
- Settings → General → **Enable New Sign Ups = OFF**.
- Users: only plinktern admin; jmoney = normal user (not deleted, not pending).
- **Functions** + Workspace → **Tools**: these run Python on the server = #1 backdoor spot. Delete anything unexpected.
- If it uses Ollama (11434): keep it bound to 127.0.0.1, don't expose it.

## Fedora quick ref
```
sudo ss -tlnp                 # listening (match to scored ports only)
sudo firewall-cmd --list-all  # current rules
sudo firewall-cmd --permanent --add-service=ssh --add-service=http && sudo firewall-cmd --reload
getenforce                    # SELinux = Enforcing
docker ps ; docker logs open-webui ; docker restart open-webui
rpm -Va | grep '^..5'         # changed package files
journalctl -u sshd -f         # watch ssh logins live
```

## Service down? Check NEIGH → Details first (it says WHY).
- SSH check fails: jmoney pw wrong in NEIGH? sshd running? firewall 22 open? jmoney shell = /bin/bash not nologin?
- Open WebUI fails: `docker ps` up? port 80 open? signups didn't break login? old chats still there (restore webui.db)?
- Locked out entirely: NEIGH **Console** (works with no network). Last resort = Revert (5 free, wipes all your fixes).

## Logs: OpenObserve on blackbox → http://172.16.t.5  (dashboard "Linux Auth")
Shows SSH logins, sudo use, account/sshd/sudoers changes on ignition. Red Team can't touch it.
