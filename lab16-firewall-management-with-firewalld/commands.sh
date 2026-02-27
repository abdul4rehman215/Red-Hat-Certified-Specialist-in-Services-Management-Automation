#!/bin/bash
# ============================================================
# Lab 16 - Firewall Management with firewalld (Ansible)
# Environment: Control Node + 2 Managed Nodes
# Control: 192.168.1.5 (student)
# Web:     192.168.1.10 (web1)
# DB:      192.168.1.11 (db1)
# Interface: eth0
# Prompt format: -bash-4.2$
# ============================================================

# =========================
# CONTROL NODE (192.168.1.5)
# =========================

# ------------------------------------------------------------
# Task 1.1: Verify Ansible installation
# ------------------------------------------------------------
ansible --version

# ------------------------------------------------------------
# Create lab directory structure
# ------------------------------------------------------------
mkdir -p ~/firewall-lab
cd ~/firewall-lab
mkdir -p playbooks roles group_vars host_vars
pwd

# ------------------------------------------------------------
# Create inventory file (created using nano per lab run)
# ------------------------------------------------------------
nano inventory
cat inventory

# ------------------------------------------------------------
# Ensure SSH key referenced in inventory exists
# ------------------------------------------------------------
ls -la ~/.ssh/lab_key
ssh-keygen -t ed25519 -f ~/.ssh/lab_key -N ""

# ------------------------------------------------------------
# Verify connectivity to managed nodes
# ------------------------------------------------------------
ansible all -m ping -i inventory

# ------------------------------------------------------------
# Create playbooks (created using nano per lab run)
# ------------------------------------------------------------
nano playbooks/firewall-config.yml
nano playbooks/advanced-firewall-rules.yml

# ------------------------------------------------------------
# Execute firewall configuration playbook
# ------------------------------------------------------------
ansible-playbook -i inventory playbooks/firewall-config.yml -v

# Verify playbook status message block
echo "Checking playbook execution status..."
if [ $? -eq 0 ]; then
  echo "Firewall configuration completed successfully!"
else
  echo "There were issues with the configuration. Check the output above."
fi

# ------------------------------------------------------------
# Apply advanced firewall rules
# ------------------------------------------------------------
ansible-playbook -i inventory playbooks/advanced-firewall-rules.yml -v

# ------------------------------------------------------------
# Task 2.1: Create security rules playbooks
# ------------------------------------------------------------
nano playbooks/web-security-rules.yml
nano playbooks/database-security-rules.yml

# ------------------------------------------------------------
# Task 2.2: Create firewall logging/monitoring playbook
# ------------------------------------------------------------
nano playbooks/firewall-logging.yml

# ------------------------------------------------------------
# Execute security and logging configurations
# ------------------------------------------------------------
ansible-playbook -i inventory playbooks/web-security-rules.yml -v
ansible-playbook -i inventory playbooks/database-security-rules.yml -v
ansible-playbook -i inventory playbooks/firewall-logging.yml -v

# ------------------------------------------------------------
# Task 3.1: Create firewall testing playbook
# ------------------------------------------------------------
nano playbooks/firewall-testing.yml

# ------------------------------------------------------------
# Create connectivity testing script
# ------------------------------------------------------------
mkdir -p scripts
nano scripts/test-connectivity.sh
chmod +x scripts/test-connectivity.sh

# ------------------------------------------------------------
# Task 3.2: Execute firewall testing playbook
# ------------------------------------------------------------
ansible-playbook -i inventory playbooks/firewall-testing.yml -v

# ------------------------------------------------------------
# Manual connectivity tests (from control node)
# ------------------------------------------------------------
./scripts/test-connectivity.sh

echo "Testing SSH connectivity to all managed nodes..."
ansible all -i inventory -m ping

echo "Testing web services..."
ansible webservers -i inventory -m shell -a "curl -I http://localhost:80" --become

echo "Testing database services..."
ansible dbservers -i inventory -m shell -a "systemctl status mysqld" --become

# Realistic fix: MariaDB service name
ansible dbservers -i inventory -m shell -a "systemctl status mariadb" --become

# ------------------------------------------------------------
# Task 3.3: Advanced testing playbook + reports
# ------------------------------------------------------------
nano playbooks/advanced-firewall-tests.yml

mkdir -p reports
ansible-playbook -i inventory playbooks/advanced-firewall-tests.yml -v

echo "Generated firewall reports:"
ls -la reports/

# ------------------------------------------------------------
# Task 3.4: Performance testing script
# ------------------------------------------------------------
nano scripts/firewall-performance-test.sh
chmod +x scripts/firewall-performance-test.sh

./scripts/firewall-performance-test.sh

echo "Checking recent firewall logs..."
ansible all -i inventory -m shell -a "tail -20 /var/log/messages | grep -i firewall" --become

# ------------------------------------------------------------
# Troubleshooting: firewalld checks
# ------------------------------------------------------------
ansible webservers -i inventory -m shell -a "firewall-cmd --check-config" --become
ansible dbservers -i inventory -m shell -a "firewall-cmd --get-zone-of-interface=eth0" --become

# Test temporary rich rule (timeout-based)
ansible webservers -i inventory -m shell -a "firewall-cmd --add-rich-rule='rule family=\"ipv4\" source address=\"192.168.1.0/24\" accept' --timeout=10" --become

# Service listening verification (web)
ansible webservers -i inventory -m shell -a "ss -tlnp | grep :80 || true" --become
