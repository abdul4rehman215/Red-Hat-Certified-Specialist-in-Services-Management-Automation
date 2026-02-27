#!/bin/bash
# CPU Performance Benchmark Script
# Tests CPU performance under different tuned profiles

BENCHMARK_DIR="/tmp/cpu_benchmarks"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
mkdir -p $BENCHMARK_DIR

echo "=== CPU Benchmark Test ==="
echo "Profile: $(tuned-adm active)"
echo "Start time: $(date)"

echo "Running CPU calculation benchmark..."
CALC_START=$(date +%s.%N)

python3 -c "
import time
start = time.time()
def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0:
            return False
    return True

primes = [n for n in range(2, 10000) if is_prime(n)]
end = time.time()
print(f'Found {len(primes)} primes in {end - start:.4f} seconds')
" > $BENCHMARK_DIR/cpu_calc_${TIMESTAMP}.txt

CALC_END=$(date +%s.%N)

echo "Result:"
cat $BENCHMARK_DIR/cpu_calc_${TIMESTAMP}.txt

echo "Benchmark file saved to: $BENCHMARK_DIR/cpu_calc_${TIMESTAMP}.txt"
echo "End time: $(date)"
