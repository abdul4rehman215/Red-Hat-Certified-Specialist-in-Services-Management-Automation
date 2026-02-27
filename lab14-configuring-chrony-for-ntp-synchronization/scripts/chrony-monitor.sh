#!/bin/bash
# Chrony Monitoring Script
echo "=== Chrony Status Report ==="
echo "Date: $(date)"
echo ""
echo "=== Time Sources ==="
chrony sources -v
echo ""
echo "=== Tracking Information ==="
chrony tracking
echo ""
echo "=== Source Statistics ==="
chrony sourcestats
echo ""
echo "=== System Time vs Hardware Clock ==="
echo "System Time: $(date)"
echo "Hardware Clock: $(sudo hwclock --show)"
echo ""
echo "=== Service Status ==="
systemctl status chronyd --no-pager -l
