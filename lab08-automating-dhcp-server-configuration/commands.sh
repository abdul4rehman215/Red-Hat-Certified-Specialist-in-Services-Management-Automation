#!/bin/bash
# Lab 08 - Automating DHCP Server Configuration
# Commands Executed During Lab (Sequential / Paste-Ready)

# -----------------------------
# Task 1.1 - Prepare the Ansible Environment
# -----------------------------
mkdir -p ~/dhcp-automation
cd ~/dhcp-automation

nano inventory.ini

# Test connectivity to target nodes
ansible all -i inventory.ini -m ping

# -----------------------------
# Task 1.2 - Create the DHCP Server Installation Playbook
# -----------------------------
nano dhcp-server-setup.yml

# -----------------------------
# Task 1.3 - Create DHCP Configuration Template
# -----------------------------
mkdir templates
nano templates/dhcpd.conf.j2

# -----------------------------
# Task 1.4 - Execute DHCP Server Installation
# -----------------------------
ansible-playbook -i inventory.ini dhcp-server-setup.yml

# Verify installation
ansible dhcp_servers -i inventory.ini -m shell -a "systemctl status dhcpd"
ansible dhcp_servers -i inventory.ini -m shell -a "cat /etc/dhcp/dhcpd.conf"

# -----------------------------
# Task 2.1 - Create Advanced DHCP Configuration Playbook
# -----------------------------
nano dhcp-advanced-config.yml

# -----------------------------
# Task 2.2 - Create Advanced DHCP Template
# -----------------------------
nano templates/dhcpd-advanced.conf.j2

# -----------------------------
# Task 2.3 - Deploy Advanced Configuration
# -----------------------------
ansible-playbook -i inventory.ini dhcp-advanced-config.yml

# Verify configuration syntax and service status
ansible dhcp_servers -i inventory.ini -m shell -a "dhcpd -t -cf /etc/dhcp/dhcpd.conf"
ansible dhcp_servers -i inventory.ini -m shell -a "systemctl status dhcpd --no-pager"

# -----------------------------
# Task 2.4 - Create DHCP Monitoring Playbook
# -----------------------------
nano dhcp-monitoring.yml

# -----------------------------
# Task 3.1 - Create DHCP Client Testing Playbook
# -----------------------------
nano dhcp-client-test.yml

# -----------------------------
# Task 3.2 - Execute Client Testing
# -----------------------------
ansible-playbook -i inventory.ini dhcp-client-test.yml

# Monitor server during client testing
ansible-playbook -i inventory.ini dhcp-monitoring.yml

# -----------------------------
# Task 3.3 - Create Comprehensive Testing Playbook
# -----------------------------
nano dhcp-comprehensive-test.yml

# Create missing include_tasks files referenced in the playbook
nano test-dhcp-server.yml
nano test-client-assignment.yml

# Run comprehensive tests
ansible-playbook -i inventory.ini dhcp-comprehensive-test.yml

# -----------------------------
# Task 3.4 - Performance and Load Testing
# -----------------------------
nano dhcp-load-test.yml
ansible-playbook -i inventory.ini dhcp-load-test.yml

# -----------------------------
# Debugging Commands Used
# -----------------------------
systemctl status dhcpd | head -12
journalctl -u dhcpd --no-pager -n 10
dhcpd -t -cf /etc/dhcp/dhcpd.conf
sudo tcpdump -i any port 67 or port 68 -c 3
sudo tail -n 20 /var/lib/dhcpd/dhcpd.leases
