#!/bin/bash
# Lab 20: Configuring Resource Limits for Services
# Commands Executed During Lab (Sequential, paste-ready)

# ---------------------------------------------
# Task 1.2: Create resource test service script
# ---------------------------------------------
sudo mkdir -p /opt/testservice
sudo nano /opt/testservice/resource-test.sh
sudo chmod +x /opt/testservice/resource-test.sh

# ---------------------------------------------
# Task 1.3: Create systemd unit with limits
# ---------------------------------------------
sudo nano /etc/systemd/system/resource-test.service

sudo systemctl daemon-reload
sudo systemctl enable resource-test.service

# ---------------------------------------------
# Task 1.4: Create web server simulation service
# ---------------------------------------------
sudo nano /opt/testservice/webserver-sim.sh
sudo chmod +x /opt/testservice/webserver-sim.sh

lsblk -d -o NAME,SIZE,TYPE

sudo nano /etc/systemd/system/webserver-sim.service

sudo systemctl daemon-reload
sudo systemctl enable webserver-sim.service

# ---------------------------------------------
# Task 2.1: Create Ansible inventory (local)
# ---------------------------------------------
mkdir -p ~/ansible-resource-limits
cd ~/ansible-resource-limits
nano inventory.ini

# ---------------------------------------------
# Task 2.2: Create Ansible playbook + install nginx
# ---------------------------------------------
nano resource-limits-playbook.yml

sudo dnf install nginx -y

mkdir -p templates
nano templates/service-template.j2

# ---------------------------------------------
# Task 2.3: Advanced resource management playbook
# ---------------------------------------------
nano advanced-resource-management.yml
nano templates/resource-override.j2

# ---------------------------------------------
# Task 2.4: Execute Ansible playbooks
# ---------------------------------------------
ansible-playbook -i inventory.ini resource-limits-playbook.yml -v
ansible-playbook -i inventory.ini advanced-resource-management.yml -v

sudo systemctl daemon-reload
sudo systemctl list-unit-files | grep -E "(resource-test|webserver-sim|database-sim|nginx-limited)"

# ---------------------------------------------
# Task 3.1: Start services + status check
# ---------------------------------------------
sudo systemctl start resource-test.service
sudo systemctl start webserver-sim.service
sudo systemctl start database-sim.service

sudo systemctl status resource-test.service webserver-sim.service database-sim.service

# ---------------------------------------------
# Task 3.2: Monitor resource usage with systemctl
# ---------------------------------------------
sudo systemctl show resource-test.service --property=CPUUsageNSec,MemoryCurrent,TasksCurrent,IOReadBytes,IOWriteBytes
sudo systemctl show resource-test.service | grep -E "(CPU|Memory|Tasks|IO)"

# ---------------------------------------------
# Task 3.2: Detailed monitoring script
# ---------------------------------------------
sudo nano /usr/local/bin/detailed-resource-monitor.sh
sudo chmod +x /usr/local/bin/detailed-resource-monitor.sh
sudo /usr/local/bin/detailed-resource-monitor.sh

# ---------------------------------------------
# Task 3.3: Monitor logs with journalctl
# ---------------------------------------------
sudo journalctl -u resource-test.service -f --lines=20
sudo journalctl -u resource-test.service -u webserver-sim.service -u database-sim.service --since="10 minutes ago"
sudo journalctl --since="1 hour ago" | grep -i "memory\|cpu\|resource\|limit"

# ---------------------------------------------
# Task 3.3: Log analyzer script
# ---------------------------------------------
sudo nano /usr/local/bin/resource-log-analyzer.sh
sudo chmod +x /usr/local/bin/resource-log-analyzer.sh
sudo /usr/local/bin/resource-log-analyzer.sh

# ---------------------------------------------
# Task 3.4: Threshold monitor + cron job
# ---------------------------------------------
sudo nano /usr/local/bin/resource-threshold-monitor.sh
sudo chmod +x /usr/local/bin/resource-threshold-monitor.sh

(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/resource-threshold-monitor.sh") | crontab -

sudo /usr/local/bin/resource-threshold-monitor.sh

# ---------------------------------------------
# Task 3.5: Resource dashboard script
# ---------------------------------------------
sudo nano /usr/local/bin/resource-dashboard.sh
sudo chmod +x /usr/local/bin/resource-dashboard.sh
sudo /usr/local/bin/resource-dashboard.sh
