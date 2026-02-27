# 🧪 Lab 13: Automating MariaDB Backup and Restore (Ansible)

> **Track:** Red Hat Certified Specialist in Services Management & Automation (Exam Labs)  
> **Environment:** Ubuntu 24.04.1 LTS (Cloud lab environment)  
> **User:** `toor`  
> **Prompt Format:** `toor@ip-172-31-10-193:~$`

---

## 🎯 Objective

This lab focuses on building a **production-style backup + restore automation workflow for MariaDB** using **Ansible** and Linux scheduling tools.

By the end of this lab, I implemented and validated:

- Automated **database backups** with Ansible playbooks
- Automated **restore procedures** (individual + full restore workflows)
- Backup **verification** (non-empty dumps + header validation)
- Backup **retention policy** (cleanup old backups)
- Automated scheduling via **cron**
- Monitoring and reporting scripts for daily operational checks
- Troubleshooting real-world dependencies (e.g., missing `community.mysql` Ansible collection, missing `bc` utility)

---

## ✅ Prerequisites

- Linux CLI basics (directories, permissions, services)
- MariaDB/MySQL fundamentals (databases, tables, dump/restore concepts)
- Ansible basics (inventory, playbooks, YAML, modules, variables)
- Scheduling concepts (cron jobs)
- Understanding of file structure and backup storage best practices

---

## 🧰 Lab Environment

- **OS:** Ubuntu 24.04.1 LTS  
- **Host:** `ip-172-31-10-193`  
- **MariaDB:** 10.11.6  
- **Ansible:** Installed and configured  
- **Backups Directory (standardized):** `/opt/mariadb-backups`  
- **Inventory target:** localhost using local connection (`ansible_connection=local`)

---

## 🗂️ Repository Structure (Lab Format)

```text
lab13-automating-mariadb-backup-and-restore/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── mariadb-automation/
    ├── inventory/
    │   └── hosts
    ├── playbooks/
    │   ├── backup-config.yml
    │   ├── mariadb-backup.yml
    │   ├── mariadb-restore.yml
    │   ├── mariadb-selective-restore.yml
    │   ├── schedule-backups.yml
    │   └── test-backup-restore.yml
    └── scripts/
        └── backup-performance-test.sh
````

> Notes:
>
> * `mariadb-automation/` mirrors the actual project folder created during the lab.
> * `commands.sh` stores **only commands executed** (exact sequence).
> * `output.txt` stores **all outputs** including Ansible output and verification commands.

---

## ✅ What Was Done (High-Level Task Overview)

### ✅ Task 1: Prepare Environment + Ansible Project Layout

* Verified MariaDB service is active and enabled
* Created a structured project directory for Ansible automation:

  * `playbooks/`, `inventory/`, `scripts/`, `backups/`, etc.
* Built Ansible inventory targeting localhost (local connection)

### ✅ Task 1.2: Create Sample Databases and Data

To make backup/restore testing realistic, created and populated:

* `company_db` (employees)
* `inventory_db` (products)
* `users_db` (user_accounts)

Verified existence via SQL query.

### ✅ Task 1.3: Build Backup Playbook (Ansible)

Created `playbooks/mariadb-backup.yml` to automate:

* Creating backup directories (root-owned, correct permissions)
* Ensuring required packages exist
* Validating MariaDB service state
* Per-database compressed backups (`mysqldump | gzip`)
* Full backup (`--all-databases`)
* Verifying backups exist and are non-empty
* Writing backup log entries
* Enforcing retention policy (delete old backup directories)
* Printing a backup summary

✅ Output confirmed: playbook ran successfully and created `.sql.gz` files.

### ✅ Task 1.4: Create Backup Configuration File

Created `playbooks/backup-config.yml` to represent backup settings:

* backup directory
* retention days
* compression
* verification toggle
* backup user placeholders
* logging placeholders

> 🔐 **Security relevance:** This config contains password fields. In real repos, secrets should be stored using **Ansible Vault** or environment variables (not committed as plaintext).

### ✅ Task 1.5: Validate Backup Outputs

Verified backup existence and integrity using:

* directory listing checks
* file size checks
* SQL dump header verification using `zcat ... | head`

✅ Output confirmed valid MariaDB dump header.

---

## ✅ Task 2: Automate Database Restore

### ✅ Restore Playbook (`mariadb-restore.yml`)

Implemented restore automation to:

* Confirm backup directory exists for the restore date
* List available backups
* Restore individual database backups (skipping full backup unless requested)
* Optionally restore using the full backup file
* Log restore start and completion
* Validate restore results via database listing query

✅ Real-world issue handled:

* `community.mysql.mysql_query` module missing initially → installed with:

  * `ansible-galaxy collection install community.mysql`
* Restore playbook succeeded after installing required collection.

### ✅ Selective Restore (`mariadb-selective-restore.yml`)

Built a selective restore mechanism:

* Finds matching backups for requested DBs
* Optionally drops databases prior to restore
* Restores only selected targets
* Verifies table counts after restoration

---

## ✅ Task 3: Comprehensive Testing + Scheduling

### ✅ Task 3.1: Backup/Restore Test Playbook

Created `test-backup-restore.yml` which:

* Creates a dedicated test database
* Inserts sample data
* Backs it up
* Modifies and deletes data
* Drops the database (simulate data loss)
* Restores it from backup
* Confirms record counts match original
* Prints pass/fail summary
* Cleans up backup artifact

✅ Output verified: integrity test PASSED.

### ✅ Task 3.2: Automated Backup Scheduling (cron)

Created `schedule-backups.yml` to:

* Install a production-style backup script: `/usr/local/bin/mariadb-backup.sh`
* Install a monitoring/reporting script: `/usr/local/bin/backup-status.sh`
* Create cron jobs:

  * Daily at 2:00 AM
  * Weekly Sunday at 1:00 AM

✅ Output verified:

* cron entries exist via `sudo crontab -l`
* manual script run generated backups and logs

### ✅ Task 3.4: Performance + Integrity Testing Script

Created `scripts/backup-performance-test.sh` to:

* measure per-db backup time + size
* measure full backup time + size
* validate dumps by checking header via `zcat ... | head -1`
* clean up test artifacts

✅ Real-world issue handled:

* `bc` not installed → installed via `apt install bc -y`
* performance timings worked correctly after fix

---

## ✅ Additional Operational Validation (Retention + Logs)

### ✅ Retention Policy Simulation

* Created dummy backup directories with older timestamps
* Re-ran backup playbook
* Verified old directories were detected and removed

### ✅ Log Review

* Reviewed `backup.log` and `restore.log` to validate operational history and visibility.

---

## ✅ Verification Summary

Confirmed end-to-end:

* ✅ Backups created (per-db + full) in `/opt/mariadb-backups/<DATE>/`
* ✅ Backup files non-empty and valid (verified via `zcat` headers)
* ✅ Restore works (original data restored successfully)
* ✅ Ansible dependency issues resolved (`community.mysql`)
* ✅ Cron scheduling created correctly
* ✅ Monitoring script reports backup status + disk usage
* ✅ Retention cleanup works (old backup directories removed)
* ✅ Logs updated for backup/restore events

---

## 🧠 What I Learned

* How to design a reproducible backup/restore workflow using Ansible
* Structuring automation like a real project (inventory + playbooks + scripts)
* Building safe restore logic (confirmation, directory checks, file discovery)
* Validating backups by both file integrity and restore verification
* Handling real-world dependency issues in automation environments
* Scheduling and operational monitoring using cron and log-based visibility
* Implementing retention policy to prevent unbounded disk growth

---

## 🔥 Why This Matters (Real-World Relevance)

Backup and restore automation is a core production requirement for:

* disaster recovery readiness
* compliance requirements
* business continuity
* incident response recovery procedures

This lab reflects real operational tasks performed by:

* Linux system administrators
* DevOps / SRE engineers
* service automation engineers
* infrastructure teams managing database backends

---

## ✅ Result

✅ Full Ansible-powered backup + restore workflow implemented
✅ Integrity validated through both dump checks and restore verification
✅ Scheduling and monitoring added for operational reliability
✅ Retention policy verified
✅ Troubleshooting handled using real fix steps

---

## 📌 Files Created in This Lab

**Project structure**

* `inventory/hosts`

**Playbooks**

* `playbooks/mariadb-backup.yml`
* `playbooks/backup-config.yml`
* `playbooks/mariadb-restore.yml`
* `playbooks/mariadb-selective-restore.yml`
* `playbooks/test-backup-restore.yml`
* `playbooks/schedule-backups.yml`

**Scripts**

* `scripts/backup-performance-test.sh`

---

## 🔐 Security Note (Relevant for this Lab)

This lab includes password placeholders (e.g., `backup_password`) and demonstrates automation patterns that often include secrets.

✅ Best practice for real environments:

* use **Ansible Vault** for credentials
* or use environment variables / external secret stores
* avoid committing plaintext secrets to GitHub
---
