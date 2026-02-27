#!/bin/bash
# rsyslog performance monitoring
echo "=== rsyslog Performance Report ==="
echo "Date: $(date)"
echo

# Check service status
echo "Service Status:"
systemctl is-active rsyslog
echo

# Check memory usage
echo "Memory Usage:"
ps aux | grep rsyslog | grep -v grep
echo

# Check log file sizes
echo "Log Directory Sizes:"
du -sh /var/log/remote/* 2>/dev/null | head -10
echo

# Check recent errors
echo "Recent Errors:"
journalctl -u rsyslog --since "1 hour ago" | grep -i error | tail -5
