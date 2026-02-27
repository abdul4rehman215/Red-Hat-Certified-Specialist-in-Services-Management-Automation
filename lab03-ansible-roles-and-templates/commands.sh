#!/bin/bash
# Lab 03: Ansible Roles and Templates
# Commands Executed During Lab (Sequential, Clean)

# ------------------------------------------------------------
# Task 1: Understanding Ansible Roles Structure
# ------------------------------------------------------------

cd ~
mkdir ansible-roles-lab
cd ansible-roles-lab
pwd

ansible-galaxy init apache-role

# tree may not be installed on minimal images
tree apache-role
sudo yum install -y tree
tree apache-role

# Explain role structure purpose
echo "=== Role Directory Structure ==="
echo "tasks/ - Main logic and tasks"
echo "handlers/ - Event-driven tasks (like service restarts)"
echo "templates/ - Jinja2 template files"
echo "files/ - Static files to copy"
echo "vars/ - Role-specific variables"
echo "defaults/ - Default variable values"
echo "meta/ - Role metadata and dependencies"

# ------------------------------------------------------------
# Task 2: Creating an Apache HTTP Server Role
# ------------------------------------------------------------

# Defaults
vim apache-role/defaults/main.yml
cat apache-role/defaults/main.yml

# OS-specific vars
mkdir -p apache-role/vars
vim apache-role/vars/RedHat.yml
cat apache-role/vars/RedHat.yml

vim apache-role/vars/Debian.yml
cat apache-role/vars/Debian.yml

# Main tasks
vim apache-role/tasks/main.yml
cat apache-role/tasks/main.yml

# Handlers
vim apache-role/handlers/main.yml
cat apache-role/handlers/main.yml

# ------------------------------------------------------------
# Task 3: Creating Jinja2 Templates
# ------------------------------------------------------------

vim apache-role/templates/apache-custom.conf.j2
sed -n '1,200p' apache-role/templates/apache-custom.conf.j2

vim apache-role/templates/index.html.j2
sed -n '1,220p' apache-role/templates/index.html.j2

# ------------------------------------------------------------
# Task 4: Creating and Executing the Playbook
# ------------------------------------------------------------

# Inventory
vim inventory.ini
cat inventory.ini

# Main role-based deployment playbook
vim deploy-apache.yml
cat deploy-apache.yml

# Site playbook (pre_tasks + post_tasks + health checks)
vim site.yml
cat site.yml

# Test connectivity
ansible -i inventory.ini webservers -m ping

# Dry-run check
ansible-playbook -i inventory.ini deploy-apache.yml --check

# Actual deployment with verbose output
ansible-playbook -i inventory.ini deploy-apache.yml -v

# Run full site deployment
ansible-playbook -i inventory.ini site.yml

# ------------------------------------------------------------
# Subtask 4.5: Verify Deployment
# ------------------------------------------------------------

# Check apache/httpd service status across nodes
ansible -i inventory.ini webservers -m shell -a "systemctl status httpd || systemctl status apache2" --become

# Test HTTP connectivity from control node via uri module
ansible -i inventory.ini webservers -m uri -a "url=http://{{ ansible_default_ipv4.address }} method=GET status_code=200" --delegate-to localhost

# Verify generated index page (example)
curl http://172.31.20.101 | head -n 30

# ------------------------------------------------------------
# Task 5: Advanced Role Features and Best Practices
# ------------------------------------------------------------

# Metadata
vim apache-role/meta/main.yml
cat apache-role/meta/main.yml

# Role tests
vim apache-role/tests/test.yml
cat apache-role/tests/test.yml

# Environment variables
mkdir -p group_vars
vim group_vars/webservers.yml
cat group_vars/webservers.yml

mkdir -p host_vars
vim host_vars/web1.yml
cat host_vars/web1.yml

# ------------------------------------------------------------
# Troubleshooting / Debugging Commands Used
# ------------------------------------------------------------

# Role path / structure checks
pwd
ls -la apache-role/
ansible-galaxy list

# Template variable troubleshooting & syntax checks
ansible-playbook -i inventory.ini deploy-apache.yml -v --extra-vars "debug=true"
ansible-playbook -i inventory.ini deploy-apache.yml --syntax-check

# SSH key permission fix
chmod 600 ~/.ssh/id_rsa

# Verify sudo access
ansible -i inventory.ini webservers -m shell -a "sudo whoami"

# Firewall checks (RedHat firewalld)
ansible -i inventory.ini webservers -m shell -a "firewall-cmd --list-services" --become
ansible -i inventory.ini webservers -m shell -a "firewall-cmd --permanent --add-service=http && firewall-cmd --reload" --become

# Additional validation tests
ansible-playbook -i inventory.ini deploy-apache.yml --extra-vars "apache_port=8080"
ansible-playbook -i inventory.ini deploy-apache.yml
ansible -i inventory.ini webservers -m shell -a "systemctl status httpd apache2 2>/dev/null | grep Active" --become

# Verify web content title across hosts (loop)
for server in web1 web2 web3; do
  echo "Testing $server..."
  ip=$(ansible -i inventory.ini $server -m setup -a "filter=ansible_default_ipv4" 2>/dev/null | grep -m1 '"address"' | awk -F'"' '{print $4}')
  curl -s http://$ip | grep -o "<title>.*</title>"
done
