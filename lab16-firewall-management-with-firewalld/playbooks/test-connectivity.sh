#!/bin/bash
# Network connectivity testing script
echo "=== Firewall Configuration Testing ==="
echo "Date: $(date)"
echo "======================================="

# Test web server connectivity
echo "Testing Web Server Connectivity..."
echo "-----------------------------------"

# Test HTTP access
echo -n "HTTP (port 80): "
if timeout 5 bash -c "</dev/tcp/192.168.1.10/80" 2>/dev/null; then
  echo "ACCESSIBLE"
else
  echo "BLOCKED/UNAVAILABLE"
fi

# Test HTTPS access
echo -n "HTTPS (port 443): "
if timeout 5 bash -c "</dev/tcp/192.168.1.10/443" 2>/dev/null; then
  echo "ACCESSIBLE"
else
  echo "BLOCKED/UNAVAILABLE"
fi

# Test custom web port
echo -n "Custom Web Port (8080): "
if timeout 5 bash -c "</dev/tcp/192.168.1.10/8080" 2>/dev/null; then
  echo "ACCESSIBLE"
else
  echo "BLOCKED/UNAVAILABLE"
fi

# Test SSH access
echo -n "SSH (port 22): "
if timeout 5 bash -c "</dev/tcp/192.168.1.10/22" 2>/dev/null; then
  echo "ACCESSIBLE"
else
  echo "BLOCKED/UNAVAILABLE"
fi

echo ""
echo "Testing Database Server Connectivity..."
echo "--------------------------------------"

# Test MySQL access
echo -n "MySQL (port 3306): "
if timeout 5 bash -c "</dev/tcp/192.168.1.11/3306" 2>/dev/null; then
  echo "ACCESSIBLE"
else
  echo "BLOCKED/UNAVAILABLE"
fi

# Test SSH access to database
echo -n "SSH to Database (port 22): "
if timeout 5 bash -c "</dev/tcp/192.168.1.11/22" 2>/dev/null; then
  echo "ACCESSIBLE"
else
  echo "BLOCKED/UNAVAILABLE"
fi

echo ""
echo "Testing Blocked Connections..."
echo "-----------------------------"

# Test blocked port (should fail)
echo -n "Blocked Port (9999): "
if timeout 5 bash -c "</dev/tcp/192.168.1.10/9999" 2>/dev/null; then
  echo "ACCESSIBLE (UNEXPECTED!)"
else
  echo "BLOCKED (EXPECTED)"
fi

echo ""
echo "=== Testing Complete ==="
