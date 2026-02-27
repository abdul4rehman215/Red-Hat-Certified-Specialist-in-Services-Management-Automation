#!/bin/bash
echo "=== Mail Queue Status ==="
postqueue -p
echo ""
echo "=== Recent Mail Log Entries ==="
tail -20 /var/log/postfix.log
