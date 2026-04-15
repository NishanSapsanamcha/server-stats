# 🖥️ Server Performance Stats

A lightweight Zsh script for monitoring server performance on Fedora Linux.

## Features

- CPU model, core count, load average, and usage %
- Memory and swap usage
- Disk usage (all real filesystems)
- Top 5 processes by CPU and memory
- Network interfaces and listening ports
- Failed systemd services

## Requirements

- Fedora Linux (or any systemd-based distro)
- Zsh shell
- Standard tools: `ps`, `ss`, `ip`, `df`, `free` (all pre-installed on Fedora)

## Usage

```zsh
# Make executable (first time only)
chmod +x server_stats.sh

# Run
./server_stats.sh

# Save output to a log file
./server_stats.sh | tee logs/stats_$(date +%Y%m%d_%H%M%S).log
```

## Auto-run with Cron

```zsh
crontab -e

# Add this line to run every hour
0 * * * * /home/youruser/server-stats/server_stats.sh >> /home/youruser/server-stats/logs/hourly.log 2>&1
```

## Project Structure
