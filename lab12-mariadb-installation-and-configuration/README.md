# 🧪 Lab 12: MariaDB Installation and Configuration

> **Track:** Red Hat Certified Specialist in Services Management & Automation (Exam Labs)  
> **Environment:** Ubuntu 24.04.1 LTS (Cloud lab environment)  
> **User:** `toor`  
> **Prompt Format:** `toor@ip-172-31-10-214:~$`

---

## 🎯 Objective

This lab focuses on deploying and securing a **MariaDB database server** on Linux and validating **role-based access control (RBAC)** using real SQL operations and automation scripts.

By completing this lab, I was able to:

- Install and configure MariaDB server using `apt`
- Secure MariaDB using best practices (`mysql_secure_installation`)
- Create and manage databases and tables
- Create database users and enforce least-privilege permissions
- Test access controls using multiple users (CRUD vs Read-only)
- Automate connection testing via a shell script
- Monitor database activity using process and privilege inspection
- Configure optional remote access and firewall rules
- Create a backup automation script using `mysqldump`
- Troubleshoot common issues (service startup, missing tools, access denied)

---

## ✅ Prerequisites

- Linux command-line fundamentals
- Basic SQL (CREATE, SELECT, INSERT, UPDATE, DELETE)
- Package management familiarity (`apt`)
- Basic networking knowledge (localhost, ports, firewall rules)
- Comfort with a text editor (`nano`/`vim`)

---

## 🧰 Lab Environment

- **OS:** Ubuntu 24.04.1 LTS  
- **Host:** `ip-172-31-10-214`  
- **User:** `toor`  
- **Privileges:** sudo/root access  
- **MariaDB Version:** `10.11.6-MariaDB`  
- **Network / Firewall Tooling:** `ufw` (opened port `3306/tcp`)

---

## 🗂️ Repository Structure (Lab Format)

```text
lab12-mariadb-installation-and-configuration/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── test_connections.sh
    └── backup_databases.sh
````

> Notes:
>
> * `commands.sh` contains **only commands executed**, in exact sequence.
> * `output.txt` contains **all terminal outputs**, including SQL outputs.
> * Scripts are stored under `scripts/` and kept exactly as created.

---

## ✅ Tasks Performed (High-Level Overview)

### ✅ Task 1: Install and Configure MariaDB

* Updated system packages (`apt update && apt upgrade`)
* Installed MariaDB server & client packages
* Started and enabled the MariaDB service via `systemctl`
* Verified service health and runtime status

### 🔐 Task 1.4: Secure MariaDB Installation

* Used `mysql_secure_installation` to:

  * Set root password
  * Remove anonymous users
  * Disable remote root login
  * Remove test database
  * Reload privilege tables

### ✅ Task 2: Create Databases and Role-Based Users

Created databases:

* `webapp_db`
* `inventory_db`
* `users_db`

Created users with distinct roles:

* `webapp_user` → full access to `webapp_db`
* `inventory_user` → full access to `inventory_db`
* `report_user` → read-only access to all application databases
* `backup_user` → global backup-oriented privileges
* (optional) `remote_user` → remote SELECT access to `webapp_db`

### ✅ Task 2.4: Populate Sample Tables for Permission Testing

* Created sample tables:

  * `webapp_db.users`
  * `inventory_db.products`
* Inserted realistic test records for validation

### ✅ Task 3: Test Database Connections and Access Control

Validated that:

* `webapp_user` can CRUD inside `webapp_db` but gets denied on `inventory_db`
* `report_user` can SELECT but INSERT fails (permission denied)
* `inventory_user` can operate on `inventory_db` but gets denied on `webapp_db`

### 🧪 Task 3.4: Automated Connection Testing Script

Created `test_connections.sh` to quickly validate:

* root connection
* app user connectivity and expected row counts
* read-only access behavior
* inventory user access behavior

### 📊 Task 3.5: Monitoring & Visibility

Performed process and privilege visibility checks using:

* `SHOW PROCESSLIST`
* `INFORMATION_SCHEMA.PROCESSLIST`
* `SHOW GRANTS FOR ...`

### 🌐 Task 3.6 (Optional): Remote Access + Firewall

* Updated bind address to allow remote access
* Created a remote user with limited SELECT privilege
* Allowed port `3306/tcp` using `ufw`

### 🚀 Performance Tuning (Basic)

Added baseline tuning directives (lab-level example):

* buffer pool sizing
* query cache settings
* connection limits (`max_connections=200`)
  Validated via `SHOW VARIABLES`.

### 💾 Backup and Recovery Setup

Created `backup_databases.sh` to generate:

* full backup (`--all-databases`)
* per-database backups for `webapp_db` and `inventory_db`
  Validated backup outputs under `/var/backups/mysql`.

---

## ✅ Verification & Validation

This lab verified:

* MariaDB service is running and enabled at boot
* All databases created successfully and visible
* Users exist and are scoped to correct hosts
* GRANT rules reflect least privilege
* Permission boundaries work (expected “Access denied” behavior)
* MariaDB is listening on port `3306`
* Firewall rule applied (`ufw allow 3306/tcp`)
* Backup files exist and are generated successfully
* Basic tuning was applied and confirmed with runtime variable check

---

## 🧠 What I Learned

* How to securely deploy MariaDB on Linux for production-like environments
* How to build user roles with permissions aligned to real application needs
* How to test and validate access controls using SQL and automation
* How to create operational scripts for repeated admin tasks
* How to verify service health, port listening state, and firewall controls
* How to handle common troubleshooting issues like missing tools (`netstat`)

---

## 🔥 Why This Matters

Database services are high-value targets and core infrastructure components.
This lab builds foundational DBA + security practices that apply directly to:

* Service deployment and automation workflows
* Least privilege + access control enforcement
* Incident investigation (user grants + process visibility)
* Secure baseline hardening for database systems
* Backup and recovery readiness

---

## 🌍 Real-World Applications

* Deploying MariaDB as a backend for web apps and internal services
* Creating scoped users for apps (write), analysts (read), and backups
* Hardening a DB server (remove test defaults, restrict root, firewall control)
* Implementing operational automation (health checks + backup routines)
* Troubleshooting and validating database availability across environments

---

## ✅ Result

✅ MariaDB installed, secured, and validated successfully
✅ Multiple databases created
✅ RBAC implemented and tested with real access-denied scenarios
✅ Automation scripts created and executed successfully
✅ Optional remote access + firewall configuration applied
✅ Backups generated and verified

---

## ✅ Conclusion

This lab simulated real database administration tasks, combining **installation**, **hardening**, **RBAC**, **testing**, **monitoring**, and **backup automation**. The end result is a working MariaDB deployment with validated permissions and repeatable admin scripts—skills directly applicable to production Linux environments and service management workflows.

---
