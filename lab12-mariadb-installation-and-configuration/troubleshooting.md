
# 🛠️ Troubleshooting Guide — Lab 12: MariaDB Installation and Configuration

> This document lists common problems encountered during MariaDB installation, configuration, access control validation, and service troubleshooting.

---

## Issue 1: MariaDB Service Won’t Start

### ✅ Symptoms
- `systemctl status mariadb` shows `failed`
- MariaDB won’t accept connections
- Service stops immediately after start

### 🔎 Checks
```bash
sudo systemctl status mariadb
sudo journalctl -u mariadb --no-pager -n 50
````

### ✅ Common Causes

* Corrupted DB files / permission issues
* Misconfigured config file
* Port conflict (another service listening on 3306)

### ✅ Fix / Recovery Steps

```bash
sudo systemctl stop mariadb
sudo systemctl start mariadb
sudo journalctl -u mariadb --no-pager -n 10
```

---

## Issue 2: Port Check Fails (`netstat: command not found`)

### ✅ Symptoms

Running:

```bash
sudo netstat -tlnp | grep 3306
```

Returns:

```text
sudo: netstat: command not found
```

### ✅ Cause

Ubuntu 24.04 does not install `net-tools` by default.

### ✅ Fix

```bash
sudo apt install net-tools -y
sudo netstat -tlnp | grep 3306
```

### ✅ Expected Output

```text
tcp   0   0 0.0.0.0:3306   0.0.0.0:*   LISTEN   <PID>/mariadbd
```

---

## Issue 3: “Access denied” When Trying to Use a Database

### ✅ Symptoms

Example:

```sql
USE inventory_db;
```

Returns:

```text
ERROR 1044 (42000): Access denied for user 'webapp_user'@'localhost' to database 'inventory_db'
```

### ✅ Cause

User does not have privileges on that database.

### ✅ Fix

Verify grants:

```sql
SHOW GRANTS FOR 'webapp_user'@'localhost';
```

If permissions are intended, grant explicitly:

```sql
GRANT ALL PRIVILEGES ON inventory_db.* TO 'webapp_user'@'localhost';
FLUSH PRIVILEGES;
```

✅ Note: In this lab, access denial was **expected** as part of RBAC validation.

---

## Issue 4: “INSERT command denied” for Read-Only User

### ✅ Symptoms

Example:

```sql
INSERT INTO products (...) VALUES (...);
```

Returns:

```text
ERROR 1142 (42000): INSERT command denied to user 'report_user'@'localhost'
```

### ✅ Cause

User was intentionally granted only `SELECT`.

### ✅ Fix

This is expected if user is read-only. To allow write access:

```sql
GRANT INSERT, UPDATE, DELETE ON inventory_db.* TO 'report_user'@'localhost';
FLUSH PRIVILEGES;
```

---

## Issue 5: Cannot Connect Remotely (Connection Refused / Timeout)

### ✅ Symptoms

* Remote client cannot connect
* Errors like:

  * “Connection refused”
  * “Can’t connect to MySQL server on … (111)”

### ✅ Causes

* MariaDB is still bound to localhost (`127.0.0.1`)
* Firewall blocks port 3306
* User host is restricted to `localhost`

### 🔎 Checks

1. Confirm MariaDB is listening:

```bash
sudo netstat -tlnp | grep 3306
```

2. Confirm bind-address:

```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

### ✅ Fix Steps

1. Update bind address:

```ini
bind-address = 0.0.0.0
```

2. Restart service:

```bash
sudo systemctl restart mariadb
```

3. Ensure user allows remote host:

```sql
CREATE USER 'remote_user'@'%' IDENTIFIED BY 'RemotePass2024!';
GRANT SELECT ON webapp_db.* TO 'remote_user'@'%';
FLUSH PRIVILEGES;
```

4. Open firewall port (Ubuntu):

```bash
sudo ufw allow 3306/tcp
```

---

## Issue 6: `mysql -u root -p` Prompts But Login Fails

### ✅ Symptoms

* Password prompt appears, but authentication fails

### ✅ Causes

* Wrong password used
* Auth plugin mismatch (unix_socket vs password auth)

### ✅ Fix

Reset password (if you have root access):

```bash
sudo mysql
```

Then inside MariaDB:

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'NewStrongPassword!';
FLUSH PRIVILEGES;
```

---

## Issue 7: Backup Script Fails (Permissions / Authentication)

### ✅ Symptoms

* `mysqldump` fails with access errors
* backup files not created in `/var/backups/mysql`

### ✅ Causes

* backup directory permission issues
* missing grants for `backup_user`
* wrong password in script

### ✅ Checks

Verify grants:

```sql
SHOW GRANTS FOR 'backup_user'@'localhost';
```

Verify directory:

```bash
sudo ls -ld /var/backups/mysql
```

### ✅ Fix

Make sure the backup directory exists and is writable (script uses sudo):

```bash
sudo mkdir -p /var/backups/mysql
sudo chown root:root /var/backups/mysql
sudo chmod 755 /var/backups/mysql
```

Ensure privileges are correct:

```sql
GRANT SELECT, LOCK TABLES, SHOW VIEW ON *.* TO 'backup_user'@'localhost';
FLUSH PRIVILEGES;
```

---

## ✅ Quick Validation Commands (Fast Checklist)


# Service status
sudo systemctl status mariadb

# Listening port
```
sudo netstat -tlnp | grep 3306
```

# Validate grants (example)
```
mysql -u root -p -e "SHOW GRANTS FOR 'webapp_user'@'localhost';"
```

# Confirm users exist
```
mysql -u root -p -e "SELECT User, Host FROM mysql.user;"
```

# Confirm runtime config (example)
```
mysql -u root -p -e "SHOW VARIABLES LIKE 'max_connections';"
```

---
