# 🛠️ Troubleshooting Guide — Lab 17: SELinux Troubleshooting and Service Access

> This file documents common issues encountered during SELinux troubleshooting for services like Apache (`httpd`) and MariaDB (`mariadb`) when using **non-standard paths**.

---

## ✅ Issue 1: Apache shows **403 Forbidden** from a custom DocumentRoot

### **Symptoms**
- `curl http://localhost:8080` returns:
  - `403 Forbidden`
- Apache service is running, but content cannot be read.

### **Likely Cause**
SELinux blocked `httpd_t` from reading files labeled `default_t`:
- `tcontext=...:default_t:s0`

### **How to Confirm**
```bash
sudo ausearch -m AVC -ts recent
sudo ausearch -m AVC -ts recent | audit2why
ls -laZ /custom/web/content
````

### **Fix (Recommended) — Correct file labels**

```bash
sudo semanage fcontext -a -t httpd_sys_content_t "/custom/web/content(/.*)?"
sudo restorecon -Rv /custom/web/content
```

### **Re-test**

```bash
curl http://localhost:8080
```

---

## ✅ Issue 2: `semanage: command not found`

### **Symptoms**

* Running `semanage fcontext ...` returns:

  * `sudo: semanage: command not found`

### **Likely Cause**

Minimal RHEL/CentOS images may not include SELinux management utilities by default.

### **Fix**

```bash
sudo dnf install policycoreutils-python-utils -y
```

### **Verify**

```bash
sudo semanage fcontext -l | head
```

---

## ✅ Issue 3: `netstat: command not found`

### **Symptoms**

* `sudo netstat -tlnp` returns:

  * `command not found`

### **Likely Cause**

`netstat` is part of `net-tools` (often missing on newer minimal builds).

### **Fix**

```bash
sudo dnf install net-tools -y
```

### **Verify**

```bash
sudo netstat -tlnp | grep :8080
```

---

## ✅ Issue 4: SELinux still blocks access after applying contexts

### **Symptoms**

* You already ran `semanage fcontext` + `restorecon`
* Service still fails, or AVC denials still appear

### **Likely Causes**

* Context mapping didn’t apply correctly
* Path pattern mismatch
* Another layer: SELinux boolean is required
* Service needs restart after changes

### **Confirm**

```bash
ls -laZ /custom/web/content
sudo semanage fcontext -l | grep "/custom/web/content"
sudo ausearch -m AVC -ts recent
```

### **Fix Steps**

1. Re-apply labels recursively:

```bash
sudo restorecon -Rv /custom
```

2. Restart service:

```bash
sudo systemctl restart httpd
```

3. Check required booleans:

```bash
getsebool -a | grep httpd
```

---

## ✅ Issue 5: Custom SELinux policy module doesn’t fix the issue

### **Symptoms**

* You generated `.pp` using `audit2allow`
* Installed module, but service still fails

### **Likely Causes**

* Policy was generated from old denials
* Denials changed after you modified configuration
* Another denial is occurring (different object/class)

### **Fix**

1. Remove problematic module:

```bash
sudo semodule -r custom_httpd_policy
```

2. Generate policy again using *fresh* AVC entries:

```bash
sudo ausearch -m AVC -ts recent | audit2allow -M new_custom_policy
sudo semodule -i new_custom_policy.pp
```

3. Verify installation:

```bash
sudo semodule -l | grep new_custom_policy
```

---

## ✅ Issue 6: MariaDB fails to start after moving datadir

### **Symptoms**

* `systemctl start mariadb` fails
* Logs show permission or access errors

### **Likely Causes**

* Wrong ownership on datadir
* SELinux label not applied (`mysqld_db_t` missing)
* Socket path mismatch between server and client

### **Confirm**

```bash
sudo systemctl status mariadb
ls -laZ /custom/database/data
sudo ausearch -m AVC -ts recent | grep -i mysql
```

### **Fix**

1. Ownership:

```bash
sudo chown -R mysql:mysql /custom/database/data
```

2. SELinux context:

```bash
sudo semanage fcontext -a -t mysqld_db_t "/custom/database/data(/.*)?"
sudo restorecon -Rv /custom/database/data
```

3. Re-test:

```bash
sudo systemctl restart mariadb
sudo systemctl status mariadb
```

---

## ✅ Issue 7: PHP page fails with DB auth error

### **Symptoms**

* `curl http://localhost:8080/dbtest.php` returns:

  * `Access denied for user 'root'@'localhost'`

### **Likely Cause**

Web applications should not rely on `root` database authentication. In lab environments, root may be restricted.

### **Fix (Lab-safe approach)**

Create a dedicated local user (example shown in lab run):

```bash
sudo mysql -u root -e "CREATE USER IF NOT EXISTS 'webapp'@'localhost' IDENTIFIED BY '';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'webapp'@'localhost' WITH GRANT OPTION;"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
```

---

## ✅ Issue 8: Web-to-DB connection blocked by SELinux

### **Symptoms**

* Web page cannot connect to DB even after credentials are correct
* AVC denials show `httpd_t` denied network/db connection

### **Likely Cause**

SELinux boolean required for DB connectivity.

### **Fix**

Enable DB connectivity boolean:

```bash
sudo setsebool -P httpd_can_network_connect_db on
```

### **Verify**

```bash
getsebool httpd_can_network_connect_db
```

---

## ✅ Final Validation Checklist

Run these to confirm the system is healthy:

```bash
getenforce
curl -s http://localhost:8080 | head
sudo systemctl is-active httpd mariadb
sudo mysql -u root -e "SHOW VARIABLES LIKE 'datadir';"
sudo ausearch -m AVC -ts recent
```

Expected:

* SELinux: `Enforcing`
* Apache: `200 OK`
* MariaDB: `active`
* datadir: `/custom/database/data/`
* AVC: no matches / count 0
---
