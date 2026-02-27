#!/bin/bash
# Lab 19: Automating System Tuning with tuned
# Commands Executed During Lab (Sequential, paste-ready)

# ---------------------------------------------
# Task 1.1: Verify tuned installation + service
# ---------------------------------------------
rpm -qa | grep tuned
systemctl status tuned

sudo dnf install tuned tuned-utils -y
sudo systemctl enable tuned
sudo systemctl start tuned

tuned-adm list
tuned-adm active
tuned-adm profile_info

# ---------------------------------------------
# Task 1.2: Explore built-in profiles + locations
# ---------------------------------------------
tuned-adm profile_info balanced
tuned-adm profile_info throughput-performance
tuned-adm profile_info latency-performance

ls -la /usr/lib/tuned/
cat /usr/lib/tuned/balanced/tuned.conf

ls -la /etc/tuned/

# ---------------------------------------------
# Task 1.3: Apply profiles + verify sysctl changes
# ---------------------------------------------
sudo tuned-adm profile throughput-performance
tuned-adm active

sysctl vm.swappiness
sysctl kernel.sched_min_granularity_ns

sudo tuned-adm profile latency-performance
tuned-adm active

sysctl kernel.sched_min_granularity_ns
sysctl kernel.sched_wakeup_granularity_ns

# ---------------------------------------------
# Task 1.3: Baseline measurement script
# ---------------------------------------------
sudo nano /tmp/performance_test.sh
chmod +x /tmp/performance_test.sh

sudo tuned-adm profile balanced
/tmp/performance_test.sh > /tmp/balanced_baseline.txt

sudo tuned-adm profile throughput-performance
/tmp/performance_test.sh > /tmp/throughput_baseline.txt

sudo tuned-adm profile latency-performance
/tmp/performance_test.sh > /tmp/latency_baseline.txt

echo "=== Comparison of Profiles ==="
diff /tmp/balanced_baseline.txt /tmp/throughput_baseline.txt

# ---------------------------------------------
# Task 1.4: Create custom tuned profiles
# ---------------------------------------------
sudo mkdir -p /etc/tuned/web-server-optimized
sudo nano /etc/tuned/web-server-optimized/tuned.conf

sudo tuned-adm profile web-server-optimized
tuned-adm active

echo "=== Custom Profile Settings ==="
sysctl net.core.rmem_max
sysctl net.ipv4.tcp_congestion_control
sysctl vm.swappiness
sysctl fs.file-max

sudo mkdir -p /etc/tuned/database-optimized
sudo nano /etc/tuned/database-optimized/tuned.conf

# ---------------------------------------------
# Task 2.1: Create Ansible project structure
# ---------------------------------------------
mkdir -p ~/ansible-tuned-automation
cd ~/ansible-tuned-automation

mkdir -p {playbooks,roles,inventory,group_vars,host_vars}

nano inventory/hosts

nano group_vars/web_servers.yml
nano group_vars/database_servers.yml

# ---------------------------------------------
# Task 2.2: Create Ansible role structure
# ---------------------------------------------
mkdir -p roles/tuned_management/{tasks,templates,vars,handlers,files}

nano roles/tuned_management/tasks/main.yml

nano roles/tuned_management/templates/web-server-optimized.conf.j2
nano roles/tuned_management/templates/database-optimized.conf.j2

nano roles/tuned_management/handlers/main.yml

# ---------------------------------------------
# Task 2.3: Create playbooks + templates
# ---------------------------------------------
nano playbooks/deploy-tuned-profiles.yml
nano playbooks/tuning_report.j2

nano playbooks/verify-tuned-performance.yml
nano playbooks/rollback-tuned-profile.yml

# ---------------------------------------------
# Task 2.4: Run Ansible playbooks
# ---------------------------------------------
cd ~/ansible-tuned-automation

ansible-playbook -i inventory/hosts playbooks/deploy-tuned-profiles.yml --syntax-check

ansible-playbook -i inventory/hosts playbooks/deploy-tuned-profiles.yml --check

ansible-playbook -i inventory/hosts playbooks/deploy-tuned-profiles.yml -v

ansible-playbook -i inventory/hosts playbooks/verify-tuned-performance.yml

ls -la /tmp/performance_metrics_*
cat /tmp/performance_metrics_localhost_*.txt

# ---------------------------------------------
# Task 2.4: Automated scheduling script
# ---------------------------------------------
nano ~/automated_tuning.sh
chmod +x ~/automated_tuning.sh

sudo touch /var/log/automated_tuning.log
sudo chown centos:centos /var/log/automated_tuning.log

# ---------------------------------------------
# Task 3.1: Performance measurement scripts
# ---------------------------------------------
nano ~/performance_analyzer.sh
chmod +x ~/performance_analyzer.sh

nano ~/compare_performance.sh
chmod +x ~/compare_performance.sh

# ---------------------------------------------
# Task 3.2: Benchmark scripts (CPU + I/O)
# ---------------------------------------------
nano ~/cpu_benchmark.sh
chmod +x ~/cpu_benchmark.sh
~/cpu_benchmark.sh

nano ~/io_benchmark.sh
chmod +x ~/io_benchmark.sh
~/io_benchmark.sh

sudo tuned-adm profile balanced
~/cpu_benchmark.sh

sudo tuned-adm profile throughput-performance
~/cpu_benchmark.sh

~/compare_performance.sh balanced throughput-performance

# ---------------------------------------------
# Final verification: DB profile + rollback
# ---------------------------------------------
sudo tuned-adm profile database-optimized
tuned-adm active

sysctl vm.swappiness vm.dirty_ratio vm.dirty_background_ratio
sysctl kernel.shmmax kernel.shmall

ansible-playbook -i inventory/hosts playbooks/rollback-tuned-profile.yml
