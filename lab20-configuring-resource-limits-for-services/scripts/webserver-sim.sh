#!/bin/bash
echo "Starting web server simulation..."
while true; do
 # Simulate web server activity
 echo "$(date): Processing web request" >> /tmp/webserver.log

 # Simulate some processing
 sleep 1

 # Rotate log if it gets too large
 if [ $(wc -l < /tmp/webserver.log) -gt 1000 ]; then
 tail -500 /tmp/webserver.log > /tmp/webserver.log.tmp
 mv /tmp/webserver.log.tmp /tmp/webserver.log
 fi
done
