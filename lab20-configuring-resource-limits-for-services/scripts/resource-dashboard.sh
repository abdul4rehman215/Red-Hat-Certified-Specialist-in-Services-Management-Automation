#!/bin/bash
clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                     Service Resource Dashboard                       ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

echo "System Information:"
echo " Hostname: $(hostname)"
echo " Uptime: $(uptime -p)"
echo " Load: $(uptime | awk -F'load average:' '{print $2}' | xargs)"
echo " Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
echo ""

echo "Service Status Overview:"
echo "┌─────────────────────┬─────────┬──────────┬─────────────┬──────────────┐"
echo "│ Service             │ Status  │ Memory   │ CPU (sec)    │ Tasks        │"
echo "├─────────────────────┼─────────┼──────────┼─────────────┼──────────────┤"

services=("resource-test" "webserver-sim" "database-sim")

for service in "${services[@]}"; do
  if systemctl is-active --quiet "$service.service"; then
    status="ACTIVE"
    memory_current=$(systemctl show "$service.service" --property=MemoryCurrent --value)
    cpu_usage=$(systemctl show "$service.service" --property=CPUUsageNSec --value)
    tasks_current=$(systemctl show "$service.service" --property=TasksCurrent --value)

    if [ "$memory_current" != "[not set]" ] && [ "$memory_current" -gt 0 ]; then
      memory_mb=$((memory_current / 1024 / 1024))
      memory_display="${memory_mb}MB"
    else
      memory_display="N/A"
    fi

    if [ "$cpu_usage" != "[not set]" ] && [ "$cpu_usage" -gt 0 ]; then
      cpu_seconds=$((cpu_usage / 1000000000))
      cpu_display="${cpu_seconds}s"
    else
      cpu_display="N/A"
    fi

    tasks_display="${tasks_current:-N/A}"
  else
    status="INACTIVE"
    memory_display="N/A"
    cpu_display="N/A"
    tasks_display="N/A"
  fi

  printf "│ %-19s │ %-7s │ %-8s │ %-11s │ %-12s │\n" \
    "$service" "$status" "$memory_display" "$cpu_display" "$tasks_display"
done

echo "└─────────────────────┴─────────┴──────────┴─────────────┴──────────────┘"
echo ""

echo "Configured Resource Limits:"
for service in "${services[@]}"; do
  if systemctl is-enabled --quiet "$service.service" 2>/dev/null; then
    echo " $service.service:"
    cpu_quota=$(systemctl show "$service.service" --property=CPUQuotaPerSecUSec --value)
    memory_max=$(systemctl show "$service.service" --property=MemoryMax --value)
    tasks_max=$(systemctl show "$service.service" --property=TasksMax --value)

    if [ "$cpu_quota" != "[not set]" ] && [ "$cpu_quota" != "infinity" ]; then
      cpu_percent=$((cpu_quota / 10000))
      echo "  CPU Quota: ${cpu_percent}%"
    fi

    if [ "$memory_max" != "[not set]" ] && [ "$memory_max" != "infinity" ]; then
      memory_max_mb=$((memory_max / 1024 / 1024))
      echo "  Memory Limit: ${memory_max_mb}MB"
    fi

    if [ "$tasks_max" != "[not set]" ] && [ "$tasks_max" != "infinity" ]; then
      echo "  Tasks Limit: $tasks_max"
    fi
    echo ""
  fi
done

echo "Recent Service Events (last 5):"
sudo journalctl -u resource-test.service -u webserver-sim.service -u database-sim.service \
  --since="30 minutes ago" --no-pager -n 5 | tail -5

echo ""
echo "Dashboard updated: $(date)"
echo "Run 'sudo /usr/local/bin/resource-dashboard.sh' to refresh"
