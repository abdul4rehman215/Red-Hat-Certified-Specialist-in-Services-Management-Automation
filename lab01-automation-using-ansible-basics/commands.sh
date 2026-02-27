#!/bin/bash
# Lab 01: Automation Using Ansible Basics
# Commands Executed During Lab (Sequential, Clean)

# ------------------------------------------------------------
# Task 1.1: Verify Ansible installation and configuration
# ------------------------------------------------------------

ansible --version

cat /etc/ansible/hosts

ssh node1 "hostname"
ssh node2 "hostname"

# ------------------------------------------------------------
# Task 1.2: Basic ad-hoc commands
# ------------------------------------------------------------

ansible all -m ping

ansible all -m setup -a "filter=ansible_distribution*"

ansible all -m shell -a "df -h"

ansible all -m command -a "uptime"

# ------------------------------------------------------------
# Task 1.3: Target specific inventory groups / hosts
# ------------------------------------------------------------

ansible webservers -m command -a "whoami"

ansible webservers -m shell -a "free -m"

ansible node1 -m shell -a "ps aux | head -10"

# ------------------------------------------------------------
# Task 2.1: Create first playbook (Apache)
# ------------------------------------------------------------

mkdir -p ~/ansible-lab
cd ~/ansible-lab
pwd

nano webserver-setup.yml

ansible-playbook webserver-setup.yml

ansible webservers -m uri -a "url=http://{{ ansible_default_ipv4.address }} method=GET"

# ------------------------------------------------------------
# Task 2.2: Database server playbook (MariaDB on node2)
# ------------------------------------------------------------

nano database-setup.yml

ansible-playbook database-setup.yml

ansible node2 -m shell -a "systemctl status mariadb"

# ------------------------------------------------------------
# Task 2.3: Multi-service playbook + template
# ------------------------------------------------------------

nano complete-setup.yml

mkdir -p templates
nano templates/system-info.j2

ansible-playbook complete-setup.yml

# ------------------------------------------------------------
# Task 3.1: User management playbook
# ------------------------------------------------------------

nano user-management.yml

ansible-playbook user-management.yml

# ------------------------------------------------------------
# Task 3.2: Sudo configuration playbook
# ------------------------------------------------------------

nano sudo-config.yml

ansible-playbook sudo-config.yml

# ------------------------------------------------------------
# Task 3.3: User auditing playbook + template
# ------------------------------------------------------------

nano user-audit.yml

nano templates/user-audit.j2

ansible-playbook user-audit.yml

# ------------------------------------------------------------
# Task 3.4: User cleanup playbook
# ------------------------------------------------------------

nano user-cleanup.yml

ansible-playbook user-cleanup.yml

# ------------------------------------------------------------
# Verification & Testing
# ------------------------------------------------------------

ansible webservers -m uri -a "url=http://{{ ansible_default_ipv4.address }}"

ansible all -m shell -a "id developer1"
ansible all -m shell -a "id operator1"

ansible all -m service_facts

ansible all -m shell -a "sudo -l -U developer1" -b

# ------------------------------------------------------------
# Troubleshooting / Diagnostics Commands Used
# ------------------------------------------------------------

ansible all -m ping -vvv

ansible-playbook webserver-setup.yml --check --diff

ansible all -m shell -a "systemctl status httpd" -b

ansible all -m shell -a "getent passwd | grep developer"
