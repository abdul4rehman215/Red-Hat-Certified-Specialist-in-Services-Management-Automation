#!/bin/bash
CLEANUP_LOG="/var/log/system-cleanup.log"
TEMP_DIRS=("/tmp/cleanup-test" "/tmp/old-files")

# Function to log messages
log_cleanup() {
 echo "$(date '+%Y-%m-%d %H:%M:%S') - CLEANUP: $1" | sudo tee -a "$CLEANUP_LOG"
}

log_cleanup "Starting system cleanup task..."

# Create test directories and files for cleanup demonstration
for dir in "${TEMP_DIRS[@]}"; do
 mkdir -p "$dir"

 # Create some test files older than 1 hour
 touch -d "2 hours ago" "$dir/old_file_1.tmp"
 touch -d "3 hours ago" "$dir/old_file_2.tmp"
 touch "$dir/new_file.tmp"
done

# Clean up old temporary files (older than 1 hour)
for dir in "${TEMP_DIRS[@]}"; do
 if [ -d "$dir" ]; then
 OLD_FILES=$(find "$dir" -name "*.tmp" -type f -mmin +60 2>/dev/null)
 if [ -n "$OLD_FILES" ]; then
 echo "$OLD_FILES" | while read -r file; do
 rm -f "$file"
 log_cleanup "Removed old file: $file"
 done
 else
 log_cleanup "No old files found in $dir"
 fi
 fi
done

# Clean up empty directories
for dir in "${TEMP_DIRS[@]}"; do
 if [ -d "$dir" ] && [ -z "$(ls -A "$dir")" ]; then
 rmdir "$dir"
 log_cleanup "Removed empty directory: $dir"
 fi
done

# Report disk usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
log_cleanup "Current disk usage: $DISK_USAGE"

# Report memory usage
MEMORY_USAGE=$(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2}')
log_cleanup "Current memory usage: $MEMORY_USAGE"

log_cleanup "System cleanup task completed successfully"
