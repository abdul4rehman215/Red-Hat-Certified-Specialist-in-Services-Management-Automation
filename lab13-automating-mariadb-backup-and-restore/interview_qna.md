# 🎤 Interview Q&A — Lab 13: Automating MariaDB Backup and Restore (Ansible)

## 1) Why automate database backups instead of doing them manually?
Automation improves reliability and consistency, reduces human error, enables scheduling, and ensures backups are created even when admins are unavailable—critical for disaster recovery and compliance.

---

## 2) What is the purpose of `mysqldump`?
`mysqldump` creates a logical backup (SQL statements) of databases/tables that can be restored using the `mysql` client.

---

## 3) Why is `--single-transaction` used in backups?
It provides a consistent snapshot for transactional tables (InnoDB) without locking tables for a long time, reducing impact on production workloads.

---

## 4) Why compress backups (`gzip`)?
Compression saves disk space, speeds up transfers, and makes retention/storage more manageable.

---

## 5) What is the difference between an “individual database backup” and a “full backup”?
- **Individual backup:** contains one database (easier targeted restore)
- **Full backup:** contains everything (`--all-databases`) (useful for full server restore)

---

## 6) Why does the playbook create a per-day directory like `/opt/mariadb-backups/2026-02-27/`?
It organizes backups by date, simplifies retention policies, and makes audits easier (you can see what backups exist per day).

---

## 7) What is a retention policy and why is it important?
A retention policy deletes backups older than a defined period (e.g., 7 days). It prevents disk from filling up and supports predictable storage management.

---

## 8) How did you verify backup integrity in this lab?
Two ways:
- verified files exist and are non-empty (`stat`, `du`)
- verified dump header using `zcat ... | head` to confirm a valid SQL dump format

---

## 9) What are the risks of automating restores?
A restore can overwrite data or destroy recent changes. That’s why safe restore automation includes confirmation prompts, date validation, and logging.

---

## 10) What caused the error: `community.mysql.mysql_query was not found`?
The required Ansible collection wasn’t installed on the host. The fix was:
```bash
ansible-galaxy collection install community.mysql
````

---

## 11) What’s the benefit of using `community.mysql` modules vs shell commands?

Modules provide:

* idempotency (consistent desired state)
* structured output (better automation logic)
* fewer parsing issues than raw shell output
  However, shell commands can still be useful for quick restore pipelines (`zcat | mysql`).

---

## 12) Why schedule backups with cron even if you already have an Ansible playbook?

Cron ensures backups run automatically at specific times. The playbook is used to deploy/configure the scheduled job and scripts consistently.

---

## 13) What does `sudo crontab -l` verify in this lab?

It verifies that the cron jobs were created for root and confirms the schedule and command paths are correct.

---

## 14) Why did the performance test script fail initially?

Because the `bc` command was missing. `bc` is required to calculate decimal time differences.

---

## 15) What security improvement would you apply to this lab in a real environment?

Avoid plaintext passwords in playbooks/configs:

* store DB credentials in **Ansible Vault**
* restrict backup directory permissions (`0700` if needed)
* encrypt backup archives (GPG/OpenSSL)
* restrict access to `/opt/mariadb-backups`

---
