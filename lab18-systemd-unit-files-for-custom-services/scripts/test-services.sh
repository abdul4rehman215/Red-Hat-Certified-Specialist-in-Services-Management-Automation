#!/bin/bash
echo "=== Custom Services Test Report ==="
echo "Generated on: $(date)"
echo

# Test web server
echo "1. Testing Custom Web Server:"
if systemctl is-active --quiet custom-webserver.service; then
 echo " ✓ Service is active"
 if curl -s http://localhost:8080/status > /dev/null; then
 echo " ✓ Web server is responding"
 else
 echo " ✗ Web server is not responding"
 fi
else
 echo " ✗ Service is not active"
fi

# Test log monitor
echo
echo "2. Testing Log Monitor:"
if systemctl is-active --quiet log-monitor.service; then
 echo " ✓ Service is active"
 if [ -f /var/log/custom-monitor.log ]; then
 LAST_LOG=$(sudo tail -1 /var/log/custom-monitor.log)
 echo " ✓ Log file exists"
 echo " Last log entry: $LAST_LOG"
 else
 echo " ✗ Log file not found"
 fi
else
 echo " ✗ Service is not active"
fi

# Test cleanup timer
echo
echo "3. Testing Cleanup Timer:"
if systemctl is-active --quiet system-cleanup.timer; then
 echo " ✓ Timer is active"
 NEXT_RUN=$(systemctl list-timers system-cleanup.timer --no-pager | grep system-cleanup.timer | awk '{print $1, $2}')
 echo " Next run: $NEXT_RUN"
else
 echo " ✗ Timer is not active"
fi

# Check enabled status
echo
echo "4. Boot Startup Status:"
echo " Web Server: $(systemctl is-enabled custom-webserver.service)"
echo " Log Monitor: $(systemctl is-enabled log-monitor.service)"
echo " Cleanup Timer: $(systemctl is-enabled system-cleanup.timer)"
echo
echo "=== Test Complete ==="
