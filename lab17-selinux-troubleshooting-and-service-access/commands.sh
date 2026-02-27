#!/bin/bash
# Lab 17: SELinux Troubleshooting and Service Access
# Commands Executed During Lab (Sequential, paste-ready)

# -----------------------------
# Task 1.1: Verify SELinux Mode
# -----------------------------
sestatus
getenforce
sudo setenforce 1

# -----------------------------------------
# Task 1.2: Install Apache + Create Content
# -----------------------------------------
sudo dnf install httpd -y

sudo mkdir -p /custom/web/content
sudo nano /custom/web/content/index.html

sudo chown -R apache:apache /custom/web/content
sudo chmod -R 755 /custom/web/content

sudo nano /etc/httpd/conf.d/custom-site.conf

sudo systemctl start httpd
sudo systemctl enable httpd

# --------------------------------
# Task 1.3: Trigger SELinux Denials
# --------------------------------
curl http://localhost:8080

sudo systemctl status httpd

sudo netstat -tlnp | grep :8080
sudo dnf install net-tools -y
sudo netstat -tlnp | grep :8080

# ------------------------------------
# Task 1.4: Investigate SELinux Denials
# ------------------------------------
sudo ausearch -m AVC -ts recent
sudo ausearch -m AVC -ts recent | audit2why

sudo sealert -a /var/log/audit/audit.log

ls -laZ /custom/web/content/
ls -laZ /var/www/html/

# ---------------------------------------------------
# Task 2.1: semanage tooling (if not installed)
# ---------------------------------------------------
sudo semanage fcontext -l | grep "/var/www"
sudo dnf install policycoreutils-python-utils -y
sudo semanage fcontext -l | grep "/var/www"

# ----------------------------------------------------
# Task 2.2: Method 1 - Fix Labeling (Recommended)
# ----------------------------------------------------
sudo semanage fcontext -a -t httpd_sys_content_t "/custom/web/content(/.*)?"
sudo restorecon -Rv /custom/web/content/
ls -laZ /custom/web/content/
curl http://localhost:8080

# ----------------------------------------------------
# Task 2.3: Method 2 - Custom Policy Module (Optional)
# ----------------------------------------------------
sudo semanage fcontext -d "/custom/web/content(/.*)?"
sudo restorecon -Rv /custom/web/content/
curl http://localhost:8080

sudo ausearch -m AVC -ts recent | audit2allow -M custom_httpd_policy
cat custom_httpd_policy.te
sudo semodule -i custom_httpd_policy.pp
sudo semodule -l | grep custom_httpd_policy

# ------------------------------------------------
# Task 2.4: MariaDB Custom Datadir + SELinux Label
# ------------------------------------------------
sudo dnf install mariadb-server -y

sudo mkdir -p /custom/database/data
sudo chown -R mysql:mysql /custom/database/data

sudo nano /etc/my.cnf.d/custom.cnf

sudo semanage fcontext -a -t mysqld_db_t "/custom/database/data(/.*)?"
sudo restorecon -Rv /custom/database/data/

sudo mysql_install_db --user=mysql --datadir=/custom/database/data

sudo systemctl start mariadb
sudo systemctl enable mariadb

# ------------------------------------------
# Task 3.1: Verify Web Service Functionality
# ------------------------------------------
curl -v http://localhost:8080
sudo ausearch -m AVC -ts recent
sudo -u apache cat /custom/web/content/index.html

wget http://localhost:8080 -O test_page.html
cat test_page.html

# --------------------------------------------
# Task 3.2: Verify Database Service Operation
# --------------------------------------------
sudo systemctl status mariadb
sudo mysql -u root -e "SELECT 'Database is working!' as Status;"
sudo mysql -u root -e "SHOW VARIABLES LIKE 'datadir';"
sudo ausearch -m AVC -ts recent | grep mysql

# ---------------------------------------------------------
# Task 3.3: Web-DB Integration (PHP + SELinux Boolean)
# ---------------------------------------------------------
sudo dnf install php php-mysqlnd -y
sudo systemctl restart httpd

sudo nano /custom/web/content/dbtest.php
curl http://localhost:8080/dbtest.php

sudo mysql -u root -e "CREATE USER IF NOT EXISTS 'webapp'@'localhost' IDENTIFIED BY '';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'webapp'@'localhost' WITH GRANT OPTION;"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

getsebool -a | grep httpd | head
sudo setsebool -P httpd_can_network_connect_db on
curl http://localhost:8080/dbtest.php

sudo journalctl -f -u httpd -u mariadb

# -------------------------------------------------------
# Task 3.4: Document SELinux Configuration + Final Checks
# -------------------------------------------------------
sudo semanage fcontext -l | grep custom
sudo semodule -l | grep custom

echo "=== SELinux Configuration Summary ===" > selinux_config_summary.txt
echo "SELinux Status: $(getenforce)" >> selinux_config_summary.txt
echo "Custom File Contexts:" >> selinux_config_summary.txt
sudo semanage fcontext -l | grep custom >> selinux_config_summary.txt
echo "Custom Modules:" >> selinux_config_summary.txt
sudo semodule -l | grep custom >> selinux_config_summary.txt
echo "Services Status:" >> selinux_config_summary.txt
systemctl is-active httpd mariadb >> selinux_config_summary.txt
cat selinux_config_summary.txt

echo "Testing web service..."
curl -s http://localhost:8080 | grep -o "<title>.*</title>"
echo "Testing database service..."
sudo mysql -u root -e "SELECT 'OK' as DatabaseStatus;" 2>/dev/null
echo "Checking for recent SELinux denials..."
sudo ausearch -m AVC -ts recent | wc -l
