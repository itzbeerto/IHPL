# HPCC4 TEAM CHECKLIST — all 5 boxes (t = team number)

## Boxes & owners
| Box | IP | OS | Scored | Owner |
|-----|----|----|--------|-------|
| blackbox | .5  | Linux Mint | none (OpenObserve logs) — SAFE, out of RT scope | ___ |
| guidance | .10 | Ubuntu 22 | SSH + PlinkCom web (WordPress/MediaWiki) | ___ |
| ignition | .20 | Fedora 38 | SSH + Open WebUI | Gilberto |
| assembly | .30 | Win 2022 | RDP + Jenkins (rocket-build must pass) | ___ |
| manifest | .40 | Win 2019 | RDP + MariaDB (plinkcom db) | ___ |

Default login everywhere: plinktern / H00ves0nTheM00n (zeroes). plinktern = admin. RT has the packet.

## First 10 minutes — EVERYONE, in this order
1. Change **plinktern** password on your box (strong, team-agreed scheme).
2. Change **jmoney** password in **NEIGH → Users** (NOT on the box). Don't disable jmoney.
3. Allow scored ports, THEN enable firewall. Back up. Hunt persistence.
4. Change the service app's own admin password (OWUI / WordPress / Jenkins / MariaDB).

## The DON'Ts (these lose uptime = points)
- DON'T close/rename a scored port or user. DON'T disable jmoney.
- DON'T set SSH PasswordAuthentication=no (scorer logs in by password).
- DON'T block IP ranges (scorer shares IPs with Red Team).
- DON'T stop the log collector (feeds OpenObserve on blackbox).
- DON'T break the Jenkins rocket-build job while securing it.

## CROSS-BOX TRAP (say it out loud before touching passwords)
PlinkCom (guidance) reads MariaDB (manifest). Changing the DB password means ALL THREE
at once: (1) manifest DB, (2) guidance site config wp-config.php/LocalSettings.php,
(3) NEIGH. Miss one → two boxes go red.

## Per-service quick notes
- **Open WebUI (ignition):** disable signups; audit Functions + Tools (run server Python); back up webui.db.
- **PlinkCom (guidance):** find wp-config.php / LocalSettings.php; disable registration; webshell-scan uploads/plugins.
- **Jenkins (assembly):** secure Script Console (/script), auth on, anonymous off, update risky plugins; keep rocket-build passing.
- **MariaDB (manifest):** rotate pw with 50-mariadb-rotate.sh; update guidance config + NEIGH.

## Recovery
- Service red? NEIGH → **Details** says WHY. Fix that specific thing.
- Locked out? NEIGH → **Console** (works with no network).
- Last resort: **Revert** — 5 free per team, WIPES all your fixes. Ask Black Team first.

## Logs: OpenObserve → http://172.16.t.5  (plinktern@plinko.horse)
Dashboards: Linux Auth (guidance/ignition), Windows Security (assembly/manifest). RT can't touch it.
