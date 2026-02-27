#!/bin/bash
echo "=== Firewall Performance Testing ==="
echo "Date: $(date)"
echo "===================================="

# Test firewall rule processing time
echo "Testing firewall rule processing performance..."

# Measure time for rule listing
echo -n "Time to list all rules: "
time firewall-cmd --list-all-zones > /dev/null

# Test connection establishment time
echo "Testing connection establishment times..."

# HTTP connection time
echo -n "HTTP connection time: "
time curl -s -o /dev/null -w "%{time_total}" http://192.168.1.10/ 2>/dev/null
echo " seconds"

# SSH connection time
echo -n "SSH connection time: "
time ssh -o ConnectTimeout=5 -o BatchMode=yes 192.168.1.10 exit 2>/dev/null
echo " seconds"

# Test rule reload time
echo -n "Firewall reload time: "
time firewall-cmd --reload > /dev/null 2>&1
echo ""
echo "=== Performance Testing Complete ==="
