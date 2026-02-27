#!/bin/bash
# Log cleanup script
LOG_DIR="/var/log/remote"
DAYS_TO_KEEP=30

# Find and remove logs older than specified days
find $LOG_DIR -name "*.log" -type f -mtime +$DAYS_TO_KEEP -delete

# Find and remove empty directories
find $LOG_DIR -type d -empty -delete

# Log cleanup activity
echo "$(date): Log cleanup completed" >> /var/log/log-cleanup.log
