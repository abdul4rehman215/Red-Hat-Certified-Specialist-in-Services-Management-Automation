#!/bin/bash
LOG_FILE="/var/log/custom-monitor.log"
MONITOR_DIR="/tmp/monitor"
PID_FILE="/tmp/log-monitor.pid"

# Function to log messages
log_message() {
 echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG_FILE"
}

# Function for graceful shutdown
cleanup() {
 log_message "Log monitor service stopping..."
 rm -f "$PID_FILE"
 exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Create monitoring directory
mkdir -p "$MONITOR_DIR"

# Write PID file
echo $$ > "$PID_FILE"

log_message "Log monitor service starting..."
log_message "Monitoring directory: $MONITOR_DIR"
log_message "PID: $$"

# Main monitoring loop
while true; do
 # Count files in monitor directory
 FILE_COUNT=$(find "$MONITOR_DIR" -type f | wc -l)

 # Log current status
 log_message "Files in monitor directory: $FILE_COUNT"

 # Check system load
 LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
 log_message "System load average: $LOAD_AVG"

 # Sleep for 30 seconds
 sleep 30
done
