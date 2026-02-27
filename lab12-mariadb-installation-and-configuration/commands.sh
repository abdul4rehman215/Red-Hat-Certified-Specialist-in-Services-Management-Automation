#!/bin/bash
# ==========================================
# Lab 12 - MariaDB Installation and Configuration
# Commands Executed During Lab (Sequential)
# Environment: Ubuntu 24.04.1 LTS
# User: toor
# Host: ip-172-31-10-214
# ==========================================

# ------------------------------------------
# Task 1.1: Update System Packages
# ------------------------------------------
sudo apt update && sudo apt upgrade -y

# ------------------------------------------
# Task 1.2: Install MariaDB Server + Client
# ------------------------------------------
sudo apt install mariadb-server mariadb-client -y

# ------------------------------------------
# Task 1.3: Start and Enable MariaDB Service
# ------------------------------------------
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl status mariadb

# ------------------------------------------
# Task 1.4: Secure MariaDB Installation (Interactive)
# ------------------------------------------
sudo mysql_secure_installation

# ------------------------------------------
# Task 1.5: Verify MariaDB Installation
# ------------------------------------------
mysql -u root -p
# Inside MariaDB prompt:
# EXIT;

# ------------------------------------------
# Task 2.1 - 2.4: Create Databases, Users, Grants, Tables, Data (Interactive)
# ------------------------------------------
mysql -u root -p
# Inside MariaDB prompt:

# Create databases
# CREATE DATABASE webapp_db;
# CREATE DATABASE inventory_db;
# CREATE DATABASE users_db;
# SHOW DATABASES;

# Create users
# CREATE USER 'webapp_user'@'localhost' IDENTIFIED BY 'WebApp2024!';
# CREATE USER 'inventory_user'@'localhost' IDENTIFIED BY 'Inventory2024!';
# CREATE USER 'report_user'@'localhost' IDENTIFIED BY 'Report2024!';
# CREATE USER 'backup_user'@'localhost' IDENTIFIED BY 'Backup2024!';
# SELECT User, Host FROM mysql.user;

# Grant privileges
# GRANT ALL PRIVILEGES ON webapp_db.* TO 'webapp_user'@'localhost';
# GRANT ALL PRIVILEGES ON inventory_db.* TO 'inventory_user'@'localhost';
# GRANT SELECT ON webapp_db.* TO 'report_user'@'localhost';
# GRANT SELECT ON inventory_db.* TO 'report_user'@'localhost';
# GRANT SELECT ON users_db.* TO 'report_user'@'localhost';
# GRANT SELECT, LOCK TABLES, SHOW VIEW ON *.* TO 'backup_user'@'localhost';
# FLUSH PRIVILEGES;

# Create sample tables + insert data
# USE webapp_db;
# CREATE TABLE users (
#  id INT AUTO_INCREMENT PRIMARY KEY,
#  username VARCHAR(50) NOT NULL,
#  email VARCHAR(100) NOT NULL,
#  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
# );
# INSERT INTO users (username, email) VALUES
# ('john_doe', 'john@example.com'),
# ('jane_smith', 'jane@example.com'),
# ('admin_user', 'admin@example.com');

# USE inventory_db;
# CREATE TABLE products (
#  id INT AUTO_INCREMENT PRIMARY KEY,
#  product_name VARCHAR(100) NOT NULL,
#  quantity INT NOT NULL,
#  price DECIMAL(10,2) NOT NULL,
#  category VARCHAR(50)
# );
# INSERT INTO products (product_name, quantity, price, category) VALUES
# ('Laptop', 25, 999.99, 'Electronics'),
# ('Mouse', 100, 29.99, 'Electronics'),
# ('Desk Chair', 15, 199.99, 'Furniture');

# EXIT;

# ------------------------------------------
# Task 3.1: Test webapp_user Access Control (Interactive)
# ------------------------------------------
mysql -u webapp_user -p
# Inside MariaDB prompt:

# USE webapp_db;
# SELECT * FROM users;
# INSERT INTO users (username, email) VALUES ('test_user', 'test@example.com');
# UPDATE users SET email = 'newemail@example.com' WHERE username = 'test_user';
# DELETE FROM users WHERE username = 'test_user';

# Access denied expected:
# USE inventory_db;

# EXIT;

# ------------------------------------------
# Task 3.2: Test report_user Read-Only Access (Interactive)
# ------------------------------------------
mysql -u report_user -p
# Inside MariaDB prompt:

# USE webapp_db;
# SELECT * FROM users;

# USE inventory_db;
# SELECT * FROM products;

# Insert denied expected:
# INSERT INTO products (product_name, quantity, price, category)
# VALUES ('Test Product', 1, 1.00, 'Test');

# EXIT;

# ------------------------------------------
# Task 3.3: Test inventory_user Access Control (Interactive)
# ------------------------------------------
mysql -u inventory_user -p
# Inside MariaDB prompt:

# USE inventory_db;
# SELECT * FROM products;
# INSERT INTO products (product_name, quantity, price, category)
# VALUES ('Keyboard', 50, 79.99, 'Electronics');
# UPDATE products SET quantity = 45 WHERE product_name = 'Keyboard';

# Access denied expected:
# USE webapp_db;

# EXIT;

# ------------------------------------------
# Task 3.4: Create and Run Connection Test Script
# ------------------------------------------
nano test_connections.sh
chmod +x test_connections.sh
./test_connections.sh

# ------------------------------------------
# Task 3.5: Monitor Database Activity + Privileges (Interactive)
# ------------------------------------------
mysql -u root -p
# Inside MariaDB prompt:

# SHOW PROCESSLIST;

# SELECT USER, HOST, DB, COMMAND, TIME, STATE
# FROM INFORMATION_SCHEMA.PROCESSLIST
# WHERE USER != 'system user';

# SHOW GRANTS FOR 'webapp_user'@'localhost';
# SHOW GRANTS FOR 'report_user'@'localhost';
# SHOW GRANTS FOR 'inventory_user'@'localhost';

# EXIT;

# ------------------------------------------
# Task 3.6: Configure Remote Access (Optional)
# ------------------------------------------
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mariadb

mysql -u root -p
# Inside MariaDB prompt:

# CREATE USER 'remote_user'@'%' IDENTIFIED BY 'RemotePass2024!';
# GRANT SELECT ON webapp_db.* TO 'remote_user'@'%';
# FLUSH PRIVILEGES;
# EXIT;

# ------------------------------------------
# Task 3.7: Configure Firewall for MariaDB (Optional)
# ------------------------------------------
sudo ufw allow 3306/tcp

# ------------------------------------------
# Troubleshooting: MariaDB Service Logs
# ------------------------------------------
sudo journalctl -u mariadb --no-pager -n 10

# ------------------------------------------
# Troubleshooting: Port Check (netstat not installed initially)
# ------------------------------------------
sudo netstat -tlnp | grep 3306
sudo apt install net-tools -y
sudo netstat -tlnp | grep 3306

# ------------------------------------------
# Troubleshooting: Verify Users
# ------------------------------------------
mysql -u root -p -e "SELECT User, Host FROM mysql.user;"

# ------------------------------------------
# Troubleshooting: Quick Status Check
# ------------------------------------------
sudo systemctl status mariadb | head -n 8

# ------------------------------------------
# Performance Optimization (Lab-level Example)
# ------------------------------------------
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mariadb
mysql -u root -p -e "SHOW VARIABLES LIKE 'max_connections';"

# ------------------------------------------
# Backup and Recovery Script
# ------------------------------------------
nano backup_databases.sh
chmod +x backup_databases.sh
./backup_databases.sh
sudo ls -lh /var/backups/mysql | tail -n 5
