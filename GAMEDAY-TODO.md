# GAME DAY — Sunday Oct 18

## Before you leave home
- [ ] USB has: 00–60 scripts, CHEATSHEET, TEAM-CHECKLIST, this file, pspy64, offline hardening guides
- [ ] NetBird installed, **Horse Plinko** profile, signs in with the CHANGE Discord account
- [ ] SSH works (PowerShell), RDP works (mstsc), laptop charged + charger
- [ ] Badge (picked up Fri, or arrive early for check-in)

## Arrive / check-in
- [ ] At FAIRWINDS Alumni Center, badge in by **9:30 AM** (no-show = spot vacated)
- [ ] Turn on NetBird Horse Plinko profile; confirm Connected
- [ ] Log into NEIGH (scoreboard.plinko.horse). 403? → sso.plinko.horse, log out, retry

## First 10 min on IGNITION (.20)
- [ ] ssh plinktern@172.16.t.20 — change plinktern pw immediately
- [ ] jmoney pw → NEIGH → Users (don't disable him)
- [ ] scp scripts over:  scp 00-harden.sh ... plinktern@172.16.t.20:~
- [ ] sudo bash 00-harden.sh   (backup, firewall ssh+http, sshd, signups)
- [ ] sudo bash 10-recon.sh    (read baseline)
- [ ] sudo bash 20-hunt.sh     (remove stray keys/users/cron/timers/Functions)
- [ ] sudo bash 40-webui-backup.sh backup → scp copy to blackbox (.5)

## Open WebUI web hardening (http://172.16.t.20)
- [ ] Admin Panel → Settings → disable New Sign Ups
- [ ] Users: only plinktern admin, jmoney normal user
- [ ] Functions + Workspace→Tools: delete anything you didn't add

## Keep running all day
- [ ] tmux: pspy64 in one pane, 30-watch.sh in another
- [ ] Watch NEIGH Details for any ignition service going red
- [ ] Check OpenObserve Linux Auth dashboard for odd logins/sudo

## Remember
- [ ] Injects = 30% of score, partial credit, late still 50%. DO THEM. No AI on injects.
- [ ] If RT re-adds a key/user → pspy/watch catches it → remove again, find the persistence
- [ ] Lunch = everything paused, hands off
- [ ] 5:30 PM hands off keyboard

## Team sync points
- [ ] Confirm each teammate changed plinktern + jmoney on their box
- [ ] Agree DB password BEFORE manifest changes it (guidance config must match)
