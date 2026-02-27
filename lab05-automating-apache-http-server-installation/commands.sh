#!/bin/bash
# Lab 05: Automating Apache HTTP Server Installation
# Environment: CentOS/RHEL 8 (Cloud Lab Environment)
# Control Node User: centos
# Terminal: -bash-4.2$
# Target Nodes: web1, web2 (CentOS/RHEL 8)
#
# Commands executed during the lab (sequential, clean)

# ------------------------------------------------------------
# Task 1: Setting Up Ansible Environment and Initial Playbook
# ------------------------------------------------------------

ansible --version

mkdir -p ~/apache-automation/{playbooks,inventory,templates,files,vars}
cd ~/apache-automation
pwd
ls -la

# Inventory file (lab uses cat <<EOF; created with nano, content identical)
nano inventory/hosts.yml
cat inventory/hosts.yml

# Test connectivity
ansible -i inventory/hosts.yml webservers -m ping

# Create Apache installation playbook
nano playbooks/apache-install.yml
cat playbooks/apache-install.yml

# Execute installation
ansible-playbook -i inventory/hosts.yml playbooks/apache-install.yml

# Verify HTTP access from control node
curl -I http://10.0.1.10
curl -I http://10.0.1.11

# ------------------------------------------------------------
# Task 2: Configuring Virtual Hosts
# ------------------------------------------------------------

# VirtualHost template
nano templates/vhost.conf.j2
sed -n '1,220p' templates/vhost.conf.j2

# VirtualHost variables
nano vars/vhosts.yml
cat vars/vhosts.yml

# VHost configuration playbook
nano playbooks/configure-vhosts.yml
cat playbooks/configure-vhosts.yml

# Execute vhost deployment
ansible-playbook -i inventory/hosts.yml playbooks/configure-vhosts.yml

# ------------------------------------------------------------
# Task 3: SSL/TLS Security + Custom Error Pages
# ------------------------------------------------------------

# SSL security configuration template
nano templates/ssl-security.conf.j2
cat templates/ssl-security.conf.j2

# Error pages directory + templates
mkdir -p templates/error-pages
nano templates/error-pages/404.html.j2
nano templates/error-pages/500.html.j2
ls -la templates/error-pages

# SSL + error pages playbook
nano playbooks/ssl-and-errors.yml
cat playbooks/ssl-and-errors.yml

# Execute SSL + error pages configuration
ansible-playbook -i inventory/hosts.yml playbooks/ssl-and-errors.yml

# ------------------------------------------------------------
# Task 4: Deploy and Test Apache Installation and Configuration
# ------------------------------------------------------------

# Testing playbook
nano playbooks/test-apache.yml
cat playbooks/test-apache.yml

# Test report template (lab text incomplete; template completed logically)
nano templates/test-report.html.j2
cat templates/test-report.html.j2

# Execute test playbook
ansible-playbook -i inventory/hosts.yml playbooks/test-apache.yml

# Quick manual verification from control node
curl -s http://10.0.1.10/test-report.html | head -n 15
curl -I -k https://10.0.1.10

# ------------------------------------------------------------
# Task 5: Troubleshooting Common Apache Issues (Operational Checks)
# ------------------------------------------------------------

# Check service status (short output)
ansible -i inventory/hosts.yml webservers -m shell -a "systemctl status httpd --no-pager | head -n 12" --become

# Validate apache config syntax
ansible -i inventory/hosts.yml webservers -m shell -a "httpd -t" --become

# Confirm firewall rules
ansible -i inventory/hosts.yml webservers -m shell -a "firewall-cmd --list-services" --become
