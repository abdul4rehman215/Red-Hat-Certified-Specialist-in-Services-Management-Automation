#!/bin/bash
echo "=== MariaDB Backup Performance Test ==="
echo "Starting performance test at $(date)"

BACKUP_DIR="/opt/mariadb-backups/performance-test"
mkdir -p "$BACKUP_DIR"

# Test 1: Individual database backup timing
echo
echo "Test 1: Individual Database Backup Performance"
for db in company_db inventory_db users_db; do
  echo -n "Backing up $db... "
  start_time=$(date +%s.%N)
  mysqldump --single-transaction -u root "$db" | gzip > "$BACKUP_DIR/${db}_perf_test.sql.gz"
  end_time=$(date +%s.%N)
  duration=$(echo "$end_time - $start_time" | bc)
  size=$(du -sh "$BACKUP_DIR/${db}_perf_test.sql.gz" | cut -f1)
  echo "Duration: ${duration}s, Size: $size"
done

# Test 2: Full backup timing
echo
echo "Test 2: Full Database Backup Performance"
echo -n "Creating full backup... "
start_time=$(date +%s.%N)
mysqldump --single-transaction --all-databases -u root | gzip > "$BACKUP_DIR/full_perf_test.sql.gz"
end_time=$(date +%s.%N)
duration=$(echo "$end_time - $start_time" | bc)
size=$(du -sh "$BACKUP_DIR/full_perf_test.sql.gz" | cut -f1)
echo "Duration: ${duration}s, Size: $size"

# Test 3: Backup integrity verification
echo
echo "Test 3: Backup Integrity Verification"
for backup_file in "$BACKUP_DIR"/*.sql.gz; do
  echo -n "Verifying $(basename "$backup_file")... "
  if zcat "$backup_file" | head -1 | grep -q "MySQL dump"; then
    echo "✓ Valid"
  else
    echo "✗ Invalid"
  fi
done

# Cleanup
rm -rf "$BACKUP_DIR"
echo
echo "Performance test completed at $(date)"
