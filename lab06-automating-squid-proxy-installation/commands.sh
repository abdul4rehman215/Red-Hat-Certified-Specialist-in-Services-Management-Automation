#!/bin/bash
# Lab 06 - Automating Squid Proxy Server Installation
# Commands Executed During Lab (Sequential)

# -----------------------------
# Task 1.1 - Project Structure
# -----------------------------
mkdir -p ~/squid-proxy-lab
cd ~/squid-proxy-lab
mkdir -p {playbooks,inventory,templates,vars}

nano inventory/hosts.yml

# -----------------------------
# Task 1.2 - Main Install Playbook
# -----------------------------
nano playbooks/install-squid.yml

# -----------------------------
# Task 1.3 - Run Install Playbook
# -----------------------------
cd ~/squid-proxy-lab
ansible-playbook -i inventory/hosts.yml playbooks/install-squid.yml

ansible proxy_servers -i inventory/hosts.yml -m command -a "systemctl status squid"

# -----------------------------
# Task 2.1 - Squid Config Template
# -----------------------------
nano templates/squid.conf.j2

# -----------------------------
# Task 2.2 - Advanced Config Playbook
# -----------------------------
nano playbooks/configure-squid.yml

# -----------------------------
# Task 2.3 - Blocked Domains Template
# -----------------------------
nano templates/blocked_domains.j2

# -----------------------------
# Task 2.4 - Apply Advanced Configuration
# -----------------------------
ansible-playbook -i inventory/hosts.yml playbooks/configure-squid.yml

ansible proxy_servers -i inventory/hosts.yml -m command -a "squid -k parse"

# -----------------------------
# Task 3.1 - Server-Side Testing Playbook
# -----------------------------
nano playbooks/test-squid.yml

# -----------------------------
# Task 3.2 - Client-Side Testing Playbook
# -----------------------------
nano playbooks/client-test.yml

# -----------------------------
# Task 3.3 - Run Tests
# -----------------------------
ansible-playbook -i inventory/hosts.yml playbooks/test-squid.yml

ansible-playbook -i inventory/hosts.yml playbooks/client-test.yml

# Manual client machine validation (client terminal)
curl -x 192.168.1.100:3128 http://www.google.com
curl -x 192.168.1.100:3128 -v http://httpbin.org/ip
curl -x 192.168.1.100:3128 https://httpbin.org/ip

# -----------------------------
# Task 3.4 - Monitoring Playbook
# -----------------------------
nano playbooks/monitor-squid.yml

ansible-playbook -i inventory/hosts.yml playbooks/monitor-squid.yml

# -----------------------------
# Troubleshooting Checks
# -----------------------------
ansible proxy_servers -i inventory/hosts.yml -m command -a "squid -k parse"
ansible proxy_servers -i inventory/hosts.yml -m command -a "journalctl -u squid -n 50"
ansible proxy_servers -i inventory/hosts.yml -m command -a "ls -la /var/spool/squid"
ansible proxy_servers -i inventory/hosts.yml -m command -a "firewall-cmd --list-ports"
ansible proxy_servers -i inventory/hosts.yml -m command -a "netstat -tlnp | grep 3128"
