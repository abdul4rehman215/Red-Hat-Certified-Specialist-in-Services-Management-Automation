#!/bin/bash
# Lab 07 - Configuring DNS with BIND
# Commands Executed During Lab (Sequential / Paste-Ready)

# -----------------------------
# Task 1.1 - Install BIND Packages
# -----------------------------
sudo dnf update -y
sudo dnf install -y bind bind-utils

# Verify installation
rpm -qa | grep bind

# -----------------------------
# Task 1.2 - Review Configuration Structure
# -----------------------------
ls -la /etc/named.conf
ls -la /var/named/

# -----------------------------
# Task 1.3 - Configure Basic Caching DNS Server
# -----------------------------
sudo cp /etc/named.conf /etc/named.conf.backup
sudo nano /etc/named.conf

# -----------------------------
# Task 1.4 - Start and Enable BIND
# -----------------------------
sudo systemctl start named
sudo systemctl enable named
sudo systemctl status named

# Verify named is listening on port 53
sudo netstat -tulnp | grep :53

# -----------------------------
# Task 1.5 - Configure Firewall
# -----------------------------
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --reload
sudo firewall-cmd --list-services

# -----------------------------
# Task 1.6 - Test Basic Caching Functionality
# -----------------------------
dig @localhost google.com
nslookup google.com localhost

# Test caching (run twice; second should be faster)
time dig @localhost google.com
time dig @localhost google.com

# -----------------------------
# Task 2.1 - Configure Forwarders
# -----------------------------
sudo nano /etc/named.conf

# -----------------------------
# Task 2.2 - Configure Conditional Forwarding
# -----------------------------
sudo nano /etc/named.conf

# -----------------------------
# Task 2.3 - Validate and Restart
# -----------------------------
sudo named-checkconf
sudo systemctl restart named
sudo systemctl status named

# Test forwarding
dig @localhost example.com
dig @localhost microsoft.com

# Watch logs for query activity
sudo tail -f /var/log/messages | grep named

# -----------------------------
# Task 3.1 - Create Forward Zone File
# -----------------------------
sudo nano /var/named/lab.local.zone

# -----------------------------
# Task 3.2 - Create Reverse Zone File
# -----------------------------
sudo nano /var/named/192.168.1.rev

# -----------------------------
# Task 3.3 - Add Zone Declarations
# -----------------------------
sudo nano /etc/named.conf

# -----------------------------
# Task 3.4 - Set Proper File Permissions
# -----------------------------
sudo chown named:named /var/named/lab.local.zone
sudo chown named:named /var/named/192.168.1.rev
sudo chmod 640 /var/named/lab.local.zone
sudo chmod 640 /var/named/192.168.1.rev

ls -la /var/named/lab.local.zone
ls -la /var/named/192.168.1.rev

# -----------------------------
# Task 3.5 - Validate Config and Zone Files
# -----------------------------
sudo named-checkconf
sudo named-checkzone lab.local /var/named/lab.local.zone
sudo named-checkzone 1.168.192.in-addr.arpa /var/named/192.168.1.rev

sudo systemctl restart named
sudo systemctl status named

# -----------------------------
# Task 3.6 - Test DNS Records
# -----------------------------
# A records
dig @localhost web.lab.local
dig @localhost ns1.lab.local
dig @localhost server1.lab.local

# CNAME records
dig @localhost www.lab.local
dig @localhost webserver.lab.local
dig @localhost database.lab.local

# PTR records (reverse)
dig @localhost -x 192.168.1.20
dig @localhost -x 192.168.1.30
dig @localhost -x 192.168.1.100

# NS records
dig @localhost lab.local NS

# MX records
dig @localhost lab.local MX

# SOA record
dig @localhost lab.local SOA

# -----------------------------
# Task 3.7 - Advanced Record Management
# -----------------------------
sudo nano /var/named/lab.local.zone

# Reload without full restart
sudo rndc reload

# Test new records
dig @localhost lab.local TXT
dig @localhost _http._tcp.lab.local SRV
dig @localhost intranet.lab.local

# -----------------------------
# Troubleshooting / Diagnostics
# -----------------------------
sudo named-checkconf
sudo journalctl -u named -f

# Port checks
sudo netstat -tulnp | grep :53
sudo netstat -tulnp | grep named

# Local resolution test
dig @127.0.0.1 google.com

# Firewall verification
sudo firewall-cmd --list-services

# Zone validation & SELinux context check
sudo named-checkzone lab.local /var/named/lab.local.zone
ls -la /var/named/
ls -Z /var/named/ | head

# Forwarder reachability
dig @8.8.8.8 google.com | head
sudo tail -f /var/log/messages | grep named
dig @localhost google.com +trace

# -----------------------------
# Performance Monitoring & Cache Visibility
# -----------------------------
sudo rndc stats
cat /var/named/data/named_stats.txt | head -20

sudo rndc querylog on
sudo tail -f /var/log/messages | grep named

sudo rndc dumpdb -cache
cat /var/named/data/cache_dump.db | head -20

# -----------------------------
# Optimization / Security Configuration Edits
# -----------------------------
sudo nano /etc/named.conf

# Final validation + restart after major changes
sudo named-checkconf
sudo systemctl restart named
sudo systemctl status named | head -15
