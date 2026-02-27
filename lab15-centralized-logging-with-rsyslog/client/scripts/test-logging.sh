#!/bin/bash
# Comprehensive logging test script
echo "Starting logging tests..."

# Test different facilities and priorities
facilities=("auth" "mail" "daemon" "kern" "user" "local0")
priorities=("debug" "info" "notice" "warning" "err" "crit")

for facility in "${facilities[@]}"; do
  for priority in "${priorities[@]}"; do
    logger -p "$facility.$priority" "Test message: $facility.$priority from $(hostname)"
    sleep 1
  done
done

echo "Logging tests completed"
