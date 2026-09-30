#!/usr/bin/env bash
# myps.sh — аналог ps ax на данных из /proc
set -u

printf '%7s %7s %-4s %s\n' PID PPID STAT COMMAND

for p in /proc/[0-9]*; do
    pid=${p#/proc/}
    [[ -r $p/stat ]] || continue

    info=$(sed -nE 's/^[0-9]+ \(([^)]*)\) ([A-Z]) ([0-9]+) .*/\1 \3 \2/p' "$p/stat")
    read -r comm ppid state <<<"$info"
    [[ -n $comm ]] || continue

    if [[ -r $p/cmdline ]]; then
        cmd=$(tr '\0' ' ' < "$p/cmdline")
        cmd=${cmd% }
    fi
    [[ -z ${cmd:-} ]] && cmd="[$comm]"

    printf '%7s %7s %-4s %s\n' "$pid" "$ppid" "$state" "$cmd"
done | sort -n
