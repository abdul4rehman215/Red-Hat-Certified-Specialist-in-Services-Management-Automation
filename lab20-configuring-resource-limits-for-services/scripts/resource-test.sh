#!/bin/bash
# Simple script that consumes CPU and memory
echo "Starting resource test service..."
while true; do
 # Consume some CPU
 for i in {1..1000}; do
 echo "Processing iteration $i" > /dev/null
 done

 # Allocate some memory (simulate memory usage)
 if [ ! -f /tmp/memory_test ]; then
 dd if=/dev/zero of=/tmp/memory_test bs=1M count=50 2>/dev/null
 fi

 sleep 2
done
