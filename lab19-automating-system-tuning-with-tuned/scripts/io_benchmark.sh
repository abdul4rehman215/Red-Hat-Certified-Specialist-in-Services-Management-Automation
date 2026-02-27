#!/bin/bash
# Simple I/O Benchmark Script

BENCHMARK_DIR="/tmp/io_benchmarks"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
mkdir -p $BENCHMARK_DIR

TESTFILE="$BENCHMARK_DIR/testfile_${TIMESTAMP}.bin"

echo "=== I/O Benchmark Test ==="
echo "Profile: $(tuned-adm active)"
echo "Start time: $(date)"
echo "Writing 512MB test file with dd..."

dd if=/dev/zero of=$TESTFILE bs=1M count=512 oflag=direct 2> $BENCHMARK_DIR/dd_write_${TIMESTAMP}.txt

echo "Write result:"
cat $BENCHMARK_DIR/dd_write_${TIMESTAMP}.txt

echo "Reading test file with dd..."
dd if=$TESTFILE of=/dev/null bs=1M iflag=direct 2> $BENCHMARK_DIR/dd_read_${TIMESTAMP}.txt

echo "Read result:"
cat $BENCHMARK_DIR/dd_read_${TIMESTAMP}.txt

rm -f $TESTFILE
echo "Cleanup complete."
echo "End time: $(date)"
