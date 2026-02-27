#!/bin/bash
# Detailed Resource Monitoring Script
echo "=========================================="
echo "Service Resource Utilization Report"
echo "Generated: $(date)"
echo "=========================================="

services=("resource-test" "webserver-sim" "database-sim")

for service in "${services[@]}"; do
 if systemctl is-active --quiet "$service.service"; then
   echo ""
   echo "Service: $service.service [ACTIVE]"
   echo "----------------------------------------"

   cpu_usage=$(systemctl show "$service.service" --property=CPUUsageNSec --value)
   memory_current=$(systemctl show "$service.service" --property=MemoryCurrent --value)
   memory_max=$(systemctl show "$service.service" --property=MemoryMax --value)
   tasks_current=$(systemctl show "$service.service" --property=TasksCurrent --value)
   tasks_max=$(systemctl show "$service.service" --property=TasksMax --value)

   if [ "$cpu_usage" != "[not set]" ] && [ "$cpu_usage" -gt 0 ]; then
     cpu_seconds=$((cpu_usage / 1000000000))
     echo "CPU Usage: ${cpu_seconds} seconds total"
   fi

   if [ "$memory_current" != "[not set]" ] && [ "$memory_current" -gt 0 ]; then
     memory_mb=$((memory_current / 1024 / 1024))
     echo "Memory Current: ${memory_mb}MB"
   fi

   if [ "$memory_max" != "[not set]" ] && [ "$memory_max" != "infinity" ]; then
     memory_max_mb=$((memory_max / 1024 / 1024))
     echo "Memory Limit: ${memory_max_mb}MB"
   fi

   if [ "$tasks_current" != "[not set]" ]; then
     echo "Tasks Current: $tasks_current"
   fi

   if [ "$tasks_max" != "[not set]" ]; then
     echo "Tasks Limit: $tasks_max"
   fi

   cgroup_path="/sys/fs/cgroup/system.slice/$service.service"
   if [ -d "$cgroup_path" ]; then
     echo "CGroup Path: $cgroup_path"
     if [ -f "$cgroup_path/memory.current" ]; then
       current_mem=$(cat "$cgroup_path/memory.current")
       current_mem_mb=$((current_mem / 1024 / 1024))
       echo "CGroup Memory: ${current_mem_mb}MB"
     fi
   fi
 else
   echo ""
   echo "Service: $service.service [INACTIVE]"
 fi
done

echo ""
echo "=========================================="
echo "System Overview"
echo "=========================================="
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo "Memory Usage: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
echo "Disk Usage: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 ")"}')"
