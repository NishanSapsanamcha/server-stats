#!/usr/bin/env zsh
# server_stats.sh — Server Performance Stats
# Fedora/Linux compatible, Zsh native

set -euo pipefail

# ── Colors ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Helpers ───────────────────────────────────────────────
section() { print -P "\n${BOLD}${CYAN}▶ $1${RESET}" }
divider() { print "─────────────────────────────────────" }

# ── Timestamp ─────────────────────────────────────────────
section "Report Generated"
date '+%A, %d %B %Y  %H:%M:%S %Z'
divider

# ── Hostname & OS ─────────────────────────────────────────
section "System Info"
echo "Hostname : $(hostname -f)"
echo "OS       : $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
echo "Kernel   : $(uname -r)"
echo "Uptime   : $(uptime -p)"

# ── CPU ───────────────────────────────────────────────────
section "CPU"
cpu_cores=$(nproc)
cpu_model=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
load=$(cut -d' ' -f1-3 /proc/loadavg)
echo "Model    : $cpu_model"
echo "Cores    : $cpu_cores"
echo "Load Avg : $load  (1 / 5 / 15 min)"

# CPU usage via /proc/stat (portable, no mpstat needed)
cpu_usage() {
  local line1 line2
  line1=($(grep '^cpu ' /proc/stat))
  sleep 1
  line2=($(grep '^cpu ' /proc/stat))
  local idle1=$line1[5] total1=0 idle2=$line2[5] total2=0
  for v in $line1[2,-1]; do (( total1 += v )); done
  for v in $line2[2,-1]; do (( total2 += v )); done
  echo $(( 100 * (total2 - total1 - (idle2 - idle1)) / (total2 - total1) ))
}
echo "CPU Use  : $(cpu_usage)%"

# ── Memory ────────────────────────────────────────────────
section "Memory"
free -h | awk '
  /^Mem:/ {
    printf "Total    : %s\nUsed     : %s\nFree     : %s\nAvail    : %s\n", $2,$3,$4,$7
  }
  /^Swap:/ {
    printf "Swap     : %s used of %s\n", $3,$2
  }'

# ── Disk ──────────────────────────────────────────────────
section "Disk Usage"
df -hT --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs \
  | awk 'NR==1{print; next} {print}' \
  | column -t

# ── Top 5 CPU-hungry Processes ────────────────────────────
section "Top 5 Processes (CPU)"
ps aux --sort=-%cpu | awk 'NR==1{print} NR>1 && NR<=6{print}' | column -t

# ── Top 5 Memory-hungry Processes ─────────────────────────
section "Top 5 Processes (Memory)"
ps aux --sort=-%mem | awk 'NR==1{print} NR>1 && NR<=6{print}' | column -t

# ── Network Interfaces ────────────────────────────────────
section "Network"
ip -brief addr show | awk '{printf "%-12s %-10s %s\n", $1, $2, $3}'

# ── Listening Ports ───────────────────────────────────────
section "Listening Ports (TCP)"
ss -tlnp | awk 'NR==1{print} NR>1{print}' | column -t

# ── Systemd Failed Units ──────────────────────────────────
section "Failed Systemd Services"
systemctl --failed --no-legend --no-pager 2>/dev/null \
  | grep -v '^$' || echo "✓ None"

divider
echo "Done."
