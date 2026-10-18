#!/bin/bash
# 30-watch.sh  --  Watchdog. Catches Red Team re-adding keys/users/ports after you clean.
# Run INSIDE tmux so it survives disconnects:  tmux new -s watch 'sudo bash 30-watch.sh'
# Detach with Ctrl-b then d. Reattach: tmux attach -t watch
set -u
INT="${1:-30}"   # seconds between checks
snap(){
  { awk -F: '$3==0||$3>=1000{print $1}' /etc/passwd | sort
    echo "---keys---"; find / -name authorized_keys -exec cat {} \; 2>/dev/null | sort
    echo "---ports---"; ss -tlnH | awk '{print $4}' | sort
  }
}
prev="$(snap)"
echo "watching every ${INT}s -- Ctrl-c to stop. Baseline captured."
while sleep "$INT"; do
  cur="$(snap)"
  d="$(diff <(echo "$prev") <(echo "$cur"))"
  if [ -n "$d" ]; then
    echo -e "\n!!!! CHANGE at $(date) !!!!"
    echo "$d"
    echo "(lines with >  = NEW/added ; <  = removed)"
    prev="$cur"
  fi
done
