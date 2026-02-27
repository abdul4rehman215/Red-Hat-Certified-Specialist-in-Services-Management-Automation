# 🎤 Interview Q&A — Lab 12: MariaDB Installation and Configuration

## 1) What is MariaDB and how is it related to MySQL?
MariaDB is an open-source relational database management system (RDBMS) that is **MySQL-compatible**. It’s a community-developed fork of MySQL and is widely used in Linux server environments.

---

## 2) Why should you run `apt update && apt upgrade` before installing MariaDB?
It ensures:
- package lists are current (latest repository metadata)
- security updates are applied
- dependency resolution is smoother during installation

---

## 3) What does `systemctl enable mariadb` do?
It configures MariaDB to **start automatically on boot** by creating a systemd symlink under the correct target (e.g., `multi-user.target.wants/`).

---

## 4) What is the purpose of `mysql_secure_installation`?
It applies common baseline hardening:
- sets root password (if needed)
- removes anonymous users
- disallows remote root login
- removes test database
- reloads privilege tables

---

## 5) What is the difference between authentication via password vs unix_socket?
- **Password auth:** user logs in using `-p` with credentials
- **unix_socket auth:** allows login based on local Linux user identity via socket (often used for root on some distros)

---

## 6) Why create separate database users for different apps?
To enforce **least privilege**:
- apps only get access to what they need
- limits blast radius if credentials are compromised
- makes auditing and access control easier

---

## 7) What does `GRANT ALL PRIVILEGES ON webapp_db.*` mean?
It grants full permissions (CRUD + schema changes) on:
- all tables (`*`) inside that database (`webapp_db`)

It does **not** grant permissions outside that database.

---

## 8) Why did `webapp_user` get “Access denied” when running `USE inventory_db;`?
Because privileges were only granted for `webapp_db.*`, not for `inventory_db.*`.  
MariaDB enforces database-level and table-level privilege boundaries.

---

## 9) How do you verify what privileges a user has?
Use:
```sql
SHOW GRANTS FOR 'username'@'host';
````

---

## 10) What is `FLUSH PRIVILEGES` used for?

It reloads privilege tables so privilege changes are applied immediately (especially useful after direct edits or when validating access changes).

---

## 11) What is the purpose of `SHOW PROCESSLIST;`?

It displays currently running queries and connections, helping with:

* troubleshooting slow queries
* detecting stuck sessions/locks
* identifying active users and workload

---

## 12) What is the role of `bind-address` in MariaDB configuration?

It defines which network interface MariaDB listens on:

* `127.0.0.1` → local-only connections
* `0.0.0.0` → all interfaces (allows remote access if firewall and permissions allow)

---

## 13) Why is opening port `3306/tcp` a security decision?

Because it exposes the database service over the network. It must be controlled using:

* firewall rules (allow only trusted sources)
* least-privilege user grants
* strong passwords / TLS where possible
* disabling remote root login

---

## 14) Why create a `backup_user` with limited privileges instead of using root for backups?

Using root increases risk. A backup user can be scoped to:

* read data (`SELECT`)
* lock tables for consistent dumps (`LOCK TABLES`)
* show views (`SHOW VIEW`)
  This reduces impact if backup credentials are leaked.

---

## 15) What does `mysqldump --all-databases` produce?

A full logical backup (SQL dump) containing:

* schema + data for all databases
* can be restored later using `mysql < dump.sql`
