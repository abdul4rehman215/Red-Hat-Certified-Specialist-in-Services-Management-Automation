# 🛠️ Troubleshooting Guide — Lab 13: Automating MariaDB Backup and Restore (Ansible)

> This document covers the most common issues encountered during MariaDB backup/restore automation using Ansible, plus how they were resolved during the lab.

---

## Issue 1: Restore Playbook Fails — `community.mysql.mysql_query` Not Found

### ✅ Symptoms
During `ansible-playbook ... mariadb-restore.yml`, the playbook fails with:
```text
The module community.mysql.mysql_query was not found in configured module paths.
````

### ✅ Cause

The **community.mysql** Ansible collection is not installed by default on many systems.

### ✅ Fix

Install the collection:

```bash
ansible-galaxy collection install community.mysql
```

Re-run the restore playbook:

```bash
ansible-playbook -i inventory/hosts playbooks/mariadb-restore.yml -e "force_restore=true" -v
```

---

## Issue 2: Backups Generate, But Verification Fails (Empty / Missing Files)

### ✅ Symptoms

* `.sql.gz` files do not exist under `/opt/mariadb-backups/<DATE>/`
* or backup files exist but are size `0`

### ✅ Causes

* mysqldump failed due to permissions/auth
* backup dir permissions incorrect
* MariaDB service not running

### ✅ Checks

```bash
sudo systemctl status mariadb
sudo ls -la /opt/mariadb-backups/
sudo ls -la /opt/mariadb-backups/$(date +%Y-%m-%d)/
```

Validate dump header quickly:

```bash
zcat /opt/mariadb-backups/$(date +%Y-%m-%d)/company_db_*.sql.gz | head -20
```

### ✅ Fix

* Ensure MariaDB is started:

```bash
sudo systemctl start mariadb
```

* Ensure directory exists and permissions are correct (playbook already does this):

```bash
sudo mkdir -p /opt/mariadb-backups
sudo chown root:root /opt/mariadb-backups
sudo chmod 755 /opt/mariadb-backups
```

---

## Issue 3: MariaDB Service Not Running (Backup Playbook Stops)

### ✅ Symptoms

Backup playbook can fail or a fail task triggers when MariaDB is stopped.

### ✅ Cause

Service isn’t started or failed on boot.

### ✅ Fix

```bash
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl status mariadb
```

If it’s failing, check logs:

```bash
sudo journalctl -u mariadb --no-pager -n 50
```

---

## Issue 4: Restore Succeeds but Data Looks Wrong

### ✅ Symptoms

* Expected rows are missing or unexpected rows appear after restore

### ✅ Common Causes

* Restoring the wrong date directory
* Restoring wrong file (full backup vs per-db backup)
* Data was changed after backup was taken

### ✅ Checks

List backup files:

```bash
ls -lh /opt/mariadb-backups/$(date +%Y-%m-%d)/
```

Verify the restore actually reset data:

```bash
sudo mysql -u root -e "USE company_db; SELECT * FROM employees;"
```

### ✅ Fix

* Restore from the correct date:

```bash
ansible-playbook -i inventory/hosts playbooks/mariadb-restore.yml -e "force_restore=true" -e "restore_target_date=YYYY-MM-DD" -v
```

* Restore from full backup explicitly:

```bash
ansible-playbook -i inventory/hosts playbooks/mariadb-restore.yml -e "force_restore=true" -e "restore_type=full" -v
```

---

## Issue 5: Cron Jobs Created but Backups Don’t Run

### ✅ Symptoms

* `sudo crontab -l` shows entries
* but no new backups appear after scheduled time

### ✅ Causes

* wrong script path
* script not executable
* cron environment differences (PATH, permissions)
* service not running at scheduled time

### ✅ Checks

Verify cron:

```bash
sudo crontab -l
```

Verify scripts exist and are executable:

```bash
sudo ls -lh /usr/local/bin/mariadb-backup.sh /usr/local/bin/backup-status.sh
```

Run script manually:

```bash
sudo /usr/local/bin/mariadb-backup.sh
```

Check logs (script logs to backup.log):

```bash
sudo tail -n 50 /opt/mariadb-backups/backup.log
```

### ✅ Fix

Ensure executable bit:

```bash
sudo chmod 755 /usr/local/bin/mariadb-backup.sh
sudo chmod 755 /usr/local/bin/backup-status.sh
```

---

## Issue 6: Performance Script Fails — `bc: command not found`

### ✅ Symptoms

Running:

```bash
sudo ./scripts/backup-performance-test.sh
```

Shows:

```text
bc: command not found
```

### ✅ Cause

The script uses `bc` for floating-point math and it wasn’t installed.

### ✅ Fix

```bash
sudo apt install bc -y
```

Re-run:

```bash
sudo ./scripts/backup-performance-test.sh
```

---

## Issue 7: Retention Cleanup Doesn’t Remove Old Backup Directories

### ✅ Symptoms

Old dated directories remain even though retention days is set.

### ✅ Causes

* directories are not old enough
* directory names don’t match expected pattern
* mtime doesn’t reflect the older date

### ✅ Checks

List directories and timestamps:

```bash
sudo ls -l /opt/mariadb-backups
```

If testing retention, force mtime older:

```bash
sudo touch -d "15 days ago" /opt/mariadb-backups/2026-02-10 /opt/mariadb-backups/2026-02-12
```

Re-run backup playbook to trigger cleanup:

```bash
ansible-playbook -i inventory/hosts playbooks/mariadb-backup.yml -v
```

---

## ✅ Quick Validation Checklist (Fast)

# 1) Service
```
sudo systemctl status mariadb
```

# 2) Backups exist
```
sudo ls -lh /opt/mariadb-backups/$(date +%Y-%m-%d)/
```

# 3) Backup looks valid
```
zcat /opt/mariadb-backups/$(date +%Y-%m-%d)/company_db_*.sql.gz | head -5
```

# 4) Restore verification
```
sudo mysql -u root -e "USE company_db; SELECT * FROM employees;"
```

# 5) Cron verification
```
sudo crontab -l
```

# 6) Logs
```
sudo tail -n 20 /opt/mariadb-backups/backup.log
sudo tail -n 20 /opt/mariadb-backups/restore.log
```

---
