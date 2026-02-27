#!/bin/bash
# Comprehensive System Performance Analyzer
# Usage: ./performance_analyzer.sh [profile_name]

PROFILE_NAME=${1:-"current"}
OUTPUT_DIR="/tmp/performance_analysis"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
REPORT_FILE="$OUTPUT_DIR/performance_report_${PROFILE_NAME}_${TIMESTAMP}.txt"

mkdir -p $OUTPUT_DIR

echo "=== System Performance Analysis Report ===" > $REPORT_FILE
echo "Profile: $PROFILE_NAME" >> $REPORT_FILE
echo "Timestamp: $(date)" >> $REPORT_FILE
echo "Hostname: $(hostname)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "=== Active tuned Profile ===" >> $REPORT_FILE
tuned-adm active >> $REPORT_FILE 2>&1
echo "" >> $REPORT_FILE

echo "=== System Information ===" >> $REPORT_FILE
uname -a >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "=== CPU Information ===" >> $REPORT_FILE
lscpu | grep -E "CPU\(s\)|Thread|Core|Socket|Model name|CPU MHz" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "=== Memory Information ===" >> $REPORT_FILE
free -h >> $REPORT_FILE
echo "" >> $REPORT_FILE
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "=== Critical Kernel Parameters ===" >> $REPORT_FILE
echo "Memory Management:" >> $REPORT_FILE
sysctl vm.swappiness vm.dirty_ratio vm.dirty_background_ratio vm.dirty_expire_centisecs vm.dirty_writeback_centisecs >> $REPORT_FILE 2>&1
echo "" >> $REPORT_FILE

echo "Network Parameters:" >> $REPORT_FILE
sysctl net.core.rmem_max net.core.wmem_max net.core.netdev_max_backlog >> $REPORT_FILE 2>&1
sysctl net.ipv4.tcp_rmem net.ipv4.tcp_wmem net.ipv4.tcp_congestion_control >> $REPORT_FILE 2>&1
echo "" >> $REPORT_FILE

echo "File System Parameters:" >> $REPORT_FILE
sysctl fs.file-max fs.nr_open >> $REPORT_FILE 2>&1
echo "" >> $REPORT_FILE

echo "Scheduler Parameters:" >> $REPORT_FILE
sysctl kernel.sched_min_granularity_ns kernel.sched_wakeup_granularity_ns >> $REPORT_FILE 2>&1
echo "" >> $REPORT_FILE

echo "=== CPU Governor and Frequency ===" >> $REPORT_FILE
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
 echo "CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)" >> $REPORT_FILE
 echo "Current CPU Frequency: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo 'N/A')" >> $REPORT_FILE
 echo "Available Governors: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null || echo 'N/A')" >> $REPORT_FILE
else
 echo "CPU frequency scaling information not available" >> $REPORT_FILE
fi
echo "" >> $REPORT_FILE

echo "=== Disk Scheduler Information ===" >> $REPORT_FILE
for disk in $(lsblk -d -n -o NAME | grep -E '^(sd|nvme|vd)'); do
 if [ -f /sys/block/$disk/queue/scheduler ]; then
 echo "$disk scheduler: $(cat /sys/block/$disk/queue/scheduler)" >> $REPORT_FILE
 fi
done
echo "" >> $REPORT_FILE

echo "=== Network Interface Information ===" >> $REPORT_FILE
ip link show | grep -E "^[0-9]+:" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "=== System Load ===" >> $REPORT_FILE
uptime >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "=== Top Processes by CPU ===" >> $REPORT_FILE
ps aux --sort=-%cpu | head -10 >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "=== Top Processes by Memory ===" >> $REPORT_FILE
ps aux --sort=-%mem | head -10 >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "=== I/O Statistics ===" >> $REPORT_FILE
if command -v iostat >/dev/null 2>&1; then
 iostat -x 1 3 >> $REPORT_FILE 2>&1
else
 echo "iostat not available - install sysstat package for detailed I/O statistics" >> $REPORT_FILE
fi
echo "" >> $REPORT_FILE

echo "Performance analysis completed. Report saved to: $REPORT_FILE"
echo "Report location: $REPORT_FILE"
