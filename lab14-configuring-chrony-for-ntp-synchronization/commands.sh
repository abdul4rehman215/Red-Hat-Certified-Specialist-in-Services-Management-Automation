#!/bin/bash
# ============================================================
# Lab 14 - Configuring Chrony for NTP Synchronization
# Commands Executed During Lab (Sequential)
# Environment: CentOS Linux 9
# User: root
# Prompt format: -bash-4.2$
# ============================================================

# ------------------------------------------------------------
# Task 1.1: Update system packages
# ------------------------------------------------------------
sudo dnf update -y

# ------------------------------------------------------------
# Task 1.1: Install Chrony
# ------------------------------------------------------------
sudo dnf install chrony -y

# ------------------------------------------------------------
# Task 1.1: Verify installation and version
# ------------------------------------------------------------
rpm -qa | grep chrony
chronyd --version

# ------------------------------------------------------------
# Task 1.2: Review Chrony config (default)
# ------------------------------------------------------------
sudo cat /etc/chrony.conf

# ------------------------------------------------------------
# Task 1.2: Backup original configuration
# ------------------------------------------------------------
sudo cp /etc/chrony.conf /etc/chrony.conf.backup

# ------------------------------------------------------------
# Task 1.2: Check chronyd service status (installed but not running yet)
# ------------------------------------------------------------
sudo systemctl status chronyd

# ------------------------------------------------------------
# Task 1.3: Edit Chrony configuration (add servers, allow lists, logging, etc.)
# ------------------------------------------------------------
sudo nano /etc/chrony.conf

# Verify key configuration lines exist
sudo grep -E "^(server|allow|local stratum|keyfile|leapsectz|logdir|log )" /etc/chrony.conf

# ------------------------------------------------------------
# Task 2.1: Add additional sources and polling/tuning options
# ------------------------------------------------------------
sudo nano /etc/chrony.conf
sudo grep -E "time.nist.gov|time.google.com|time.cloudflare.com|minpoll|maxpoll|maxdistance|makestep" /etc/chrony.conf

# ------------------------------------------------------------
# Task 2.2: Ensure client settings are present (drift, rtcsync, logging)
# ------------------------------------------------------------
sudo nano /etc/chrony.conf
sudo grep -E "^(rtcsync|driftfile|logchange|dumponexit|dumpdir|maxupdateskew|hwtimestamp)" /etc/chrony.conf

# ------------------------------------------------------------
# Task 2.3: Start and enable Chrony service
# ------------------------------------------------------------
sudo systemctl start chronyd
sudo systemctl enable chronyd
sudo systemctl status chronyd
sudo systemctl is-enabled chronyd

# ------------------------------------------------------------
# Task 3.1: Monitor NTP synchronization status
# ------------------------------------------------------------
chrony sources -v
chrony sourcestats -v
chrony tracking
chrony activity

# ------------------------------------------------------------
# Task 3.2: Force immediate synchronization (if needed)
# ------------------------------------------------------------
sudo chrony makestep

# Check system time and hardware clock
date
sudo hwclock --show
sudo hwclock --systohc

# ------------------------------------------------------------
# Task 3.3: Real-time monitoring examples (interactive)
# ------------------------------------------------------------
watch -n 5 'chrony sources'
# Press Ctrl+C to exit

sudo journalctl -u chronyd -f
# Press Ctrl+C to exit

chrony tracking
chrony sources | grep "^\*\|^+"

# ------------------------------------------------------------
# Task 3.4: Configure firewall for NTP (firewalld)
# ------------------------------------------------------------
sudo firewall-cmd --state
sudo firewall-cmd --permanent --add-service=ntp
sudo firewall-cmd --reload
sudo firewall-cmd --list-services | grep ntp

# ------------------------------------------------------------
# Task 3.5: Create Chrony monitoring script
# ------------------------------------------------------------
sudo nano /usr/local/bin/chrony-monitor.sh
sudo chmod +x /usr/local/bin/chrony-monitor.sh
sudo /usr/local/bin/chrony-monitor.sh

# ------------------------------------------------------------
# Task 3.6: Configure Chrony as NTP server (client + server)
# ------------------------------------------------------------
sudo nano /etc/chrony.conf
sudo systemctl restart chronyd

# Verify server is listening on UDP 123
sudo netstat -ulnp | grep :123

# If netstat missing, install net-tools
sudo dnf install net-tools -y
sudo netstat -ulnp | grep :123

# ------------------------------------------------------------
# Troubleshooting: Not synchronizing checks
# ------------------------------------------------------------
ping -c 3 pool.ntp.org
sudo firewall-cmd --list-all
timedatectl status
sudo chrony makestep

# ------------------------------------------------------------
# Troubleshooting: Service fails / config issues
# ------------------------------------------------------------
sudo chronyd -n -d
sudo journalctl -u chronyd --no-pager
ls -la /etc/chrony.conf
sudo cp /etc/chrony.conf.backup /etc/chrony.conf

# ------------------------------------------------------------
# Troubleshooting: Large time jumps
# ------------------------------------------------------------
echo "makestep 0.1 3" | sudo tee -a /etc/chrony.conf
sudo journalctl -u chronyd --no-pager | grep -i step | tail -n 5
sudo hwclock --compare

# ------------------------------------------------------------
# Final verification block
# ------------------------------------------------------------
echo "=== Final Chrony Verification ==="
echo "Service Status:" && sudo systemctl status chronyd --no-pager | head -n 10
echo -e "\nTime Sources:" && chrony sources | head
echo -e "\nTracking Status:" && chrony tracking | head -n 8
echo -e "\nSystem Time:" && date
echo -e "\nTime Zone:" && timedatectl status | tail -n 6

# Compare with external time source
curl -s http://worldtimeapi.org/api/timezone/UTC | grep -o '"datetime":"[^"]*"'

# Reboot persistence test (interactive)
sudo systemctl reboot
# After reconnect:
sudo systemctl status chronyd
