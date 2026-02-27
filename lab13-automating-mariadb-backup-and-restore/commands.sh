#!/bin/bash
# ============================================================
# Lab 13 - Automating MariaDB Backup and Restore (Ansible)
# Commands Executed During Lab (Sequential)
# Environment: Ubuntu 24.04.1 LTS
# User: toor
# Host: ip-172-31-10-193
# ============================================================

# ------------------------------------------------------------
# Task 1.1: Verify MariaDB service status / start / enable
# ------------------------------------------------------------
sudo systemctl status mariadb
sudo systemctl start mariadb
sudo systemctl enable mariadb

# ------------------------------------------------------------
# Task 1.1: Create Ansible project directory structure
# ------------------------------------------------------------
mkdir -p ~/mariadb-automation/{playbooks,roles,inventory,backups,scripts}
cd ~/mariadb-automation
pwd

# ------------------------------------------------------------
# Task 1.1: Create and verify inventory file
# ------------------------------------------------------------
nano inventory/hosts
cat inventory/hosts

# ------------------------------------------------------------
# Task 1.2: Create sample databases and seed data (here-doc)
# ------------------------------------------------------------
sudo mysql -u root << 'EOF'
CREATE DATABASE IF NOT EXISTS company_db;
CREATE DATABASE IF NOT EXISTS inventory_db;
CREATE DATABASE IF NOT EXISTS users_db;

USE company_db;
CREATE TABLE employees (
 id INT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100),
 department VARCHAR(50),
 salary DECIMAL(10,2)
);
INSERT INTO employees (name, department, salary) VALUES
('John Doe', 'IT', 75000.00),
('Jane Smith', 'HR', 65000.00),
('Mike Johnson', 'Finance', 80000.00);

USE inventory_db;
CREATE TABLE products (
 id INT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100),
 quantity INT,
 price DECIMAL(8,2)
);
INSERT INTO products (name, quantity, price) VALUES
('Laptop', 50, 999.99),
('Mouse', 200, 25.50),
('Keyboard', 150, 75.00);

USE users_db;
CREATE TABLE user_accounts (
 id INT AUTO_INCREMENT PRIMARY KEY,
 username VARCHAR(50),
 email VARCHAR(100),
 created_date DATE
);
INSERT INTO user_accounts (username, email, created_date) VALUES
('admin', 'admin@company.com', '2024-01-01'),
('user1', 'user1@company.com', '2024-01-15'),
('user2', 'user2@company.com', '2024-02-01');

FLUSH PRIVILEGES;
EOF

# Quick verification
sudo mysql -u root -e "SHOW DATABASES LIKE 'company_db';"

# ------------------------------------------------------------
# Task 1.3: Create backup playbook
# ------------------------------------------------------------
nano playbooks/mariadb-backup.yml

# ------------------------------------------------------------
# Task 1.4: Create backup configuration file
# ------------------------------------------------------------
nano playbooks/backup-config.yml

# ------------------------------------------------------------
# Task 1.5: Run backup playbook (verbose)
# ------------------------------------------------------------
cd ~/mariadb-automation
ansible-playbook -i inventory/hosts playbooks/mariadb-backup.yml -v

# Verify backup directories / files
ls -la /opt/mariadb-backups/
ls -la /opt/mariadb-backups/$(date +%Y-%m-%d)/

# Check backup sizes and dump header
du -sh /opt/mariadb-backups/$(date +%Y-%m-%d)/*
zcat /opt/mariadb-backups/$(date +%Y-%m-%d)/company_db_*.sql.gz | head -20

# ------------------------------------------------------------
# Task 2.1: Create restore playbook
# ------------------------------------------------------------
nano playbooks/mariadb-restore.yml

# ------------------------------------------------------------
# Task 2.2: Create selective restore playbook
# ------------------------------------------------------------
nano playbooks/mariadb-selective-restore.yml

# ------------------------------------------------------------
# Task 2.3: Modify data to validate restore
# ------------------------------------------------------------
sudo mysql -u root << 'EOF'
USE company_db;
DELETE FROM employees WHERE name = 'John Doe';
INSERT INTO employees (name, department, salary) VALUES ('Test User', 'Testing', 50000.00);
SELECT * FROM employees;
EOF

# Run restore playbook (force restore to skip interactive pause)
ansible-playbook -i inventory/hosts playbooks/mariadb-restore.yml -e "force_restore=true" -v

# Troubleshooting: install missing collection if module not found
ansible-galaxy collection install community.mysql

# Re-run restore playbook after installing collection
ansible-playbook -i inventory/hosts playbooks/mariadb-restore.yml -e "force_restore=true" -v

# Verify restored data (John Doe back, Test User removed)
sudo mysql -u root -e "USE company_db; SELECT * FROM employees;"

# ------------------------------------------------------------
# Task 3.1: Create comprehensive backup/restore test playbook
# ------------------------------------------------------------
nano playbooks/test-backup-restore.yml

# Run the comprehensive test
ansible-playbook -i inventory/hosts playbooks/test-backup-restore.yml -v

# ------------------------------------------------------------
# Task 3.2: Create scheduling playbook (cron + scripts)
# ------------------------------------------------------------
nano playbooks/schedule-backups.yml

# Run scheduling playbook
ansible-playbook -i inventory/hosts playbooks/schedule-backups.yml -v

# Test backup script manually (logs to backup.log)
sudo /usr/local/bin/mariadb-backup.sh

# Verify new backup files
sudo ls -lh /opt/mariadb-backups/$(date +%Y-%m-%d) | head

# Check backup status report
sudo /usr/local/bin/backup-status.sh

# Verify cron jobs were created
sudo crontab -l

# ------------------------------------------------------------
# Task 3.4: Create and run performance test script
# ------------------------------------------------------------
nano scripts/backup-performance-test.sh
chmod +x scripts/backup-performance-test.sh

# First run (bc missing)
sudo ./scripts/backup-performance-test.sh

# Fix dependency
sudo apt install bc -y

# Re-run after installing bc
sudo ./scripts/backup-performance-test.sh

# ------------------------------------------------------------
# Task 4: Validate retention behavior (simulate old directories)
# ------------------------------------------------------------
sudo mkdir -p /opt/mariadb-backups/2026-02-10 /opt/mariadb-backups/2026-02-12
sudo touch -d "15 days ago" /opt/mariadb-backups/2026-02-10 /opt/mariadb-backups/2026-02-12

# Re-run backup playbook to trigger retention cleanup
ansible-playbook -i inventory/hosts playbooks/mariadb-backup.yml -v

# Verify old directories removed
sudo ls -1 /opt/mariadb-backups | head

# ------------------------------------------------------------
# Task 5: Review operational logs
# ------------------------------------------------------------
sudo tail -n 15 /opt/mariadb-backups/backup.log
sudo tail -n 10 /opt/mariadb-backups/restore.log
