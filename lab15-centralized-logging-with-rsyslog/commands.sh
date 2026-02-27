#!/bin/bash
# ============================================================
# Lab 15 - Setting Up Centralized Logging with rsyslog
# Environment: Two CentOS/RHEL systems
# Server (Central Log Server): 10.0.2.41 (eth0)
# Client (Log Forwarder):      10.0.2.42 (eth0)
# Prompt format: -bash-4.2$
# ============================================================

# =========================
# SERVER MACHINE (10.0.2.41)
# =========================

# ------------------------------------------------------------
# Task 1.1: Verify rsyslog installation and status
# ------------------------------------------------------------
rpm -qa | grep rsyslog
systemctl status rsyslog

# (If not installed)
# sudo yum install rsyslog -y
# sudo dnf install rsyslog -y

# ------------------------------------------------------------
# Task 1.2: Backup and edit rsyslog configuration
# ------------------------------------------------------------
sudo cp /etc/rsyslog.conf /etc/rsyslog.conf.backup
sudo nano /etc/rsyslog.conf

# ------------------------------------------------------------
# Task 1.2: Create remote log directory and set permissions
# ------------------------------------------------------------
sudo mkdir -p /var/log/remote
sudo chown syslog:adm /var/log/remote

# Fix if group missing
sudo groupadd adm
sudo chown syslog:adm /var/log/remote
sudo chmod 755 /var/log/remote
ls -ld /var/log/remote

# ------------------------------------------------------------
# Task 1.3: Firewall rules for syslog traffic
# ------------------------------------------------------------
sudo firewall-cmd --permanent --add-port=514/udp
sudo firewall-cmd --permanent --add-port=514/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-ports

# ------------------------------------------------------------
# Task 1.3: Restart/enable rsyslog and verify status
# ------------------------------------------------------------
sudo systemctl restart rsyslog
sudo systemctl enable rsyslog
sudo systemctl status rsyslog | head -n 10

# ------------------------------------------------------------
# Task 1.3: Verify rsyslog is listening on port 514
# ------------------------------------------------------------
sudo netstat -tulnp | grep 514

# If netstat missing
sudo dnf install net-tools -y
sudo netstat -tulnp | grep 514

# Alternative using ss
sudo ss -tulnp | grep 514

# =========================
# CLIENT MACHINE (10.0.2.42)
# =========================

# ------------------------------------------------------------
# Task 2.1: Backup and edit client rsyslog.conf for forwarding
# ------------------------------------------------------------
sudo cp /etc/rsyslog.conf /etc/rsyslog.conf.backup
sudo nano /etc/rsyslog.conf
tail -n 5 /etc/rsyslog.conf

# (For documentation, server IP on server)
# ip addr show eth0 | grep inet

# ------------------------------------------------------------
# Task 2.2: Create custom forwarding config
# ------------------------------------------------------------
sudo nano /etc/rsyslog.d/50-remote.conf

# Restart and verify client rsyslog
sudo systemctl restart rsyslog
sudo systemctl status rsyslog | head -n 10

# =========================
# SERVER MACHINE (10.0.2.41)
# =========================

# ------------------------------------------------------------
# Task 3.1: Create logrotate config for remote logs
# ------------------------------------------------------------
sudo nano /etc/logrotate.d/remote-logs
sudo cat /etc/logrotate.d/remote-logs

# ------------------------------------------------------------
# Task 3.2: Create logrotate config for local logs
# (applies to both systems but created here for lab output)
# ------------------------------------------------------------
sudo nano /etc/logrotate.d/custom-logs
sudo cat /etc/logrotate.d/custom-logs

# ------------------------------------------------------------
# Task 3.2: Test logrotate
# ------------------------------------------------------------
sudo logrotate -d /etc/logrotate.d/remote-logs
sudo logrotate -f /etc/logrotate.d/remote-logs

# ------------------------------------------------------------
# Task 3.3: Create log cleanup script and cron schedule
# ------------------------------------------------------------
sudo nano /usr/local/bin/log-cleanup.sh
sudo chmod +x /usr/local/bin/log-cleanup.sh

# Add cron entry (interactive edit)
sudo crontab -e

# Verify crontab
sudo crontab -l

# =========================
# CLIENT MACHINE (10.0.2.42)
# =========================

# ------------------------------------------------------------
# Task 4.1: Generate test logs on client
# ------------------------------------------------------------
sudo logger -p auth.info "Test authentication message from client"
sudo logger -p mail.info "Test mail message from client"
sudo logger -p kern.info "Test kernel message from client"
sudo logger "General test message from client"

sudo logger -p auth.debug "Debug level auth message"
sudo logger -p auth.warning "Warning level auth message"
sudo logger -p auth.err "Error level auth message"
sudo logger -p auth.crit "Critical level auth message"

# =========================
# SERVER MACHINE (10.0.2.41)
# =========================

# ------------------------------------------------------------
# Task 4.2: Verify remote logs on server
# ------------------------------------------------------------
ls -la /var/log/remote/
ls -la /var/log/remote/client01/
tail -n 15 /var/log/remote/client01/logger.log

# Real-time monitoring (interactive)
sudo tail -f /var/log/remote/client01/logger.log
# Ctrl+C

# Validate rsyslog config + check logs
sudo rsyslogd -N1 -f /etc/rsyslog.conf
sudo journalctl -u rsyslog --no-pager -n 10

# =========================
# CLIENT MACHINE (10.0.2.42)
# =========================

# ------------------------------------------------------------
# Task 4.3: Create and run comprehensive logging test script
# ------------------------------------------------------------
nano ~/test-logging.sh
chmod +x ~/test-logging.sh
./test-logging.sh

# =========================
# SERVER MACHINE (10.0.2.41)
# =========================

# ------------------------------------------------------------
# Task 4.3: Verify results and count messages
# ------------------------------------------------------------
sudo touch /tmp/test_start
find /var/log/remote/ -name "*.log" -newer /tmp/test_start 2>/dev/null | head
grep -r "Test message" /var/log/remote/ | wc -l

# =========================
# Troubleshooting: Connectivity checks (CLIENT)
# =========================

# telnet test (install if missing)
telnet 10.0.2.41 514
sudo dnf install telnet -y
telnet 10.0.2.41 514
# ^] then quit

# nmap test (install if missing)
nmap -p 514 10.0.2.41
sudo dnf install nmap -y
nmap -p 514 10.0.2.41

# =========================
# Troubleshooting: Firewall verification (SERVER)
# =========================
sudo firewall-cmd --list-all | head -n 12
# (Optional test)
# sudo systemctl stop firewalld

# =========================
# Troubleshooting: Permissions (SERVER)
# =========================
sudo chown -R syslog:adm /var/log/remote/ && sudo chmod -R 755 /var/log/remote/

# =========================
# Troubleshooting: SELinux (SERVER)
# =========================
sestatus
sudo setsebool -P rsyslog_can_network on

# semanage may be missing
sudo semanage port -a -t syslogd_port_t -p tcp 514
sudo dnf install policycoreutils-python-utils -y
sudo semanage port -a -t syslogd_port_t -p tcp 514
sudo semanage port -a -t syslogd_port_t -p udp 514

# =========================
# Troubleshooting: logrotate status (SERVER)
# =========================
cat /var/lib/logrotate/status | tail -n 5
sudo journalctl | grep logrotate

# =========================
# Optional: TLS encryption (SERVER)
# =========================
sudo dnf install rsyslog-gnutls -y
sudo mkdir -p /etc/rsyslog-certs
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/rsyslog-certs/server-key.pem \
  -out /etc/rsyslog-certs/server-cert.pem
sudo nano /etc/rsyslog.conf

# =========================
# Optional: Performance monitoring script (SERVER)
# =========================
sudo nano /usr/local/bin/rsyslog-monitor.sh
sudo chmod +x /usr/local/bin/rsyslog-monitor.sh
sudo /usr/local/bin/rsyslog-monitor.sh
