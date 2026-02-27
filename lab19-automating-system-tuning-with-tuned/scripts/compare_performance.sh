#!/bin/bash
# Performance Comparison Script
# Usage: ./compare_performance.sh profile1 profile2

if [ $# -ne 2 ]; then
 echo "Usage: $0 <profile1> <profile2>"
 echo "Example: $0 balanced throughput-performance"
 exit 1
fi

PROFILE1=$1
PROFILE2=$2
COMPARISON_DIR="/tmp/performance_comparison"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
mkdir -p $COMPARISON_DIR

echo "=== Performance Comparison: $PROFILE1 vs $PROFILE2 ==="
echo "Starting comparison at $(date)"

echo "Testing profile: $PROFILE1"
sudo tuned-adm profile $PROFILE1
sleep 5
~/performance_analyzer.sh $PROFILE1

echo "Testing profile: $PROFILE2"
sudo tuned-adm profile $PROFILE2
sleep 5
~/performance_analyzer.sh $PROFILE2

REPORT1=$(ls -t /tmp/performance_analysis/performance_report_${PROFILE1}_*.txt | head -1)
REPORT2=$(ls -t /tmp/performance_analysis/performance_report_${PROFILE2}_*.txt | head -1)

COMPARISON_REPORT="$COMPARISON_DIR/comparison_${PROFILE1}_vs_${PROFILE2}_${TIMESTAMP}.txt"

echo "=== Performance Comparison Report ===" > $COMPARISON_REPORT
echo "Profile 1: $PROFILE1" >> $COMPARISON_REPORT
echo "Profile 2: $PROFILE2" >> $COMPARISON_REPORT
echo "Generated: $(date)" >> $COMPARISON_REPORT
echo "" >> $COMPARISON_REPORT

echo "=== Key Differences ===" >> $COMPARISON_REPORT
echo "Comparing critical parameters between profiles:" >> $COMPARISON_REPORT
echo "" >> $COMPARISON_REPORT

echo "Memory Management Parameters:" >> $COMPARISON_REPORT
echo "Parameter | $PROFILE1 | $PROFILE2" >> $COMPARISON_REPORT
echo "----------|----------|----------" >> $COMPARISON_REPORT
for param in vm.swappiness vm.dirty_ratio vm.dirty_background_ratio; do
 val1=$(grep "$param" "$REPORT1" | awk '{print $3}')
 val2=$(grep "$param" "$REPORT2" | awk '{print $3}')
 printf "%-20s | %-8s | %-8s\n" "$param" "$val1" "$val2" >> $COMPARISON_REPORT
done
echo "" >> $COMPARISON_REPORT

echo "Network Parameters:" >> $COMPARISON_REPORT
echo "Parameter | $PROFILE1 | $PROFILE2" >> $COMPARISON_REPORT
echo "----------|----------|----------" >> $COMPARISON_REPORT
for param in net.core.rmem_max net.core.wmem_max; do
 val1=$(grep "$param" "$REPORT1" | awk '{print $3}')
 val2=$(grep "$param" "$REPORT2" | awk '{print $3}')
 printf "%-20s | %-8s | %-8s\n" "$param" "$val1" "$val2" >> $COMPARISON_REPORT
done
echo "" >> $COMPARISON_REPORT

echo "CPU Governor:" >> $COMPARISON_REPORT
gov1=$(grep "CPU Governor:" "$REPORT1" | awk '{print $3}')
gov2=$(grep "CPU Governor:" "$REPORT2" | awk '{print $3}')
echo "$PROFILE1: $gov1" >> $COMPARISON_REPORT
echo "$PROFILE2: $gov2" >> $COMPARISON_REPORT
echo "" >> $COMPARISON_REPORT

echo "Full reports available at:" >> $COMPARISON_REPORT
echo "Profile 1 ($PROFILE1): $REPORT1" >> $COMPARISON_REPORT
echo "Profile 2 ($PROFILE2): $REPORT2" >> $COMPARISON_REPORT

echo "Comparison completed. Report saved to: $COMPARISON_REPORT"
cat $COMPARISON_REPORT
