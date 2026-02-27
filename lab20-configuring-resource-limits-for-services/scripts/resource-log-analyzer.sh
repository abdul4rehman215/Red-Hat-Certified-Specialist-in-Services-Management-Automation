#!/bin/bash
echo "Resource Limit Log Analysis"
echo "==========================="
echo "Analyzing logs from the last hour..."
echo ""

echo "Memory-related events:"
sudo journalctl --since="1 hour ago" --no-pager | grep -i "memory" | tail -10
echo ""

echo "CPU-related events:"
sudo journalctl --since="1 hour ago" --no-pager | grep -i "cpu" | tail -10
echo ""

echo "Service restart events:"
sudo journalctl --since="1 hour ago" --no-pager | grep -E "(Started|Stopped|Failed)" | grep -E "(resource-test|webserver-sim|database-sim)"
echo ""

echo "Resource limit violations:"
sudo journalctl --since="1 hour ago" --no-pager | grep -i "limit\|quota\|exceeded" | tail -5
