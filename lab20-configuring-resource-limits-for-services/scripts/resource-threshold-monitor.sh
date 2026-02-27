#!/bin/bash
# Resource Threshold Monitoring Script

ALERT_LOG="/var/log/resource-alerts.log"
MEMORY_THRESHOLD=80 # Alert if memory usage > 80% of limit
CPU_THRESHOLD=300   # Alert if CPU time > 300 seconds

services=("resource-test" "webserver-sim" "database-sim")

for service in "${services[@]}"; do
  if systemctl is-active --quiet "$service.service"; then

    memory_current=$(systemctl show "$service.service" --property=MemoryCurrent --value)
    memory_max=$(systemctl show "$service.service" --property=MemoryMax --value)

    if [ "$memory_current" != "[not set]" ] && [ "$memory_max" != "[not set]" ] && [ "$memory_max" != "infinity" ]; then
      memory_percent=$((memory_current * 100 / memory_max))
      if [ $memory_percent -gt $MEMORY_THRESHOLD ]; then
        echo "$(date): ALERT - $service.service memory usage at ${memory_percent}%" >> $ALERT_LOG
        echo "MEMORY ALERT: $service.service using ${memory_percent}% of allocated memory"
      fi
    fi

    cpu_usage=$(systemctl show "$service.service" --property=CPUUsageNSec --value)
    if [ "$cpu_usage" != "[not set]" ] && [ "$cpu_usage" -gt 0 ]; then
      cpu_seconds=$((cpu_usage / 1000000000))
      if [ $cpu_seconds -gt $CPU_THRESHOLD ]; then
        echo "$(date): ALERT - $service.service CPU usage at ${cpu_seconds} seconds" >> $ALERT_LOG
        echo "CPU ALERT: $service.service has used ${cpu_seconds} seconds of CPU time"
      fi
    fi
  fi
done

if [ -f $ALERT_LOG ]; then
  echo ""
  echo "Recent alerts (last 10):"
  tail -10 $ALERT_LOG
fi
