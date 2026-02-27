# 🛠️ Troubleshooting Guide — Lab 05: Automating Apache HTTP Server Installation (Ansible)

> This guide captures the most common failure points during automated Apache deployments and the exact commands used to diagnose and fix them in a CentOS/RHEL-based environment.

---

## 1) SSH / Inventory Connectivity Issues

### ✅ Symptoms
- `UNREACHABLE!` errors
- `Permission denied (publickey)`  
- `Failed to connect to the host via ssh`

### 🔍 Checks
```bash
ansible -i inventory/hosts.yml webservers -m ping -vvv
````

### ✅ Fixes

* Ensure inventory has correct values:

  * `ansible_host`, `ansible_user`
  * `ansible_ssh_private_key_file`
* Verify SSH manually:

```bash
ssh -i ~/.ssh/id_rsa centos@10.0.1.10 "hostname"
ssh -i ~/.ssh/id_rsa centos@10.0.1.11 "hostname"
```

* Confirm key permissions:

```bash
chmod 600 ~/.ssh/id_rsa
```

---

## 2) Apache Service Not Starting

### ✅ Symptoms

* `curl` fails (timeout / connection refused)
* `systemctl` shows inactive/failed

### 🔍 Checks (used in lab)

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "systemctl status httpd --no-pager | head -n 12" --become
```

### ✅ Fixes

* Validate configuration syntax:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "httpd -t" --become
```

* Restart service:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "systemctl restart httpd" --become
```

* Check logs:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "tail -n 60 /var/log/httpd/error_log" --become
```

---

## 3) Firewall Blocking HTTP/HTTPS

### ✅ Symptoms

* Apache is running but not reachable from the control node
* `curl` shows timeout or connection refused

### 🔍 Checks (used in lab)

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "firewall-cmd --list-services" --become
```

### ✅ Fixes

* Add services:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "firewall-cmd --permanent --add-service=http" --become
ansible -i inventory/hosts.yml webservers -m shell -a "firewall-cmd --permanent --add-service=https" --become
ansible -i inventory/hosts.yml webservers -m shell -a "firewall-cmd --reload" --become
```

* Verify ports are listening:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "ss -tulpn | egrep ':80|:443' || netstat -tulpn | egrep ':80|:443'" --become
```

---

## 4) Virtual Host Not Routing Correctly

### ✅ Symptoms

* Always sees default site
* Wrong vhost content served

### 🔍 Checks

* Confirm vhost config exists:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "ls -la /etc/httpd/conf.d/" --become
```

* Validate Apache syntax:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "httpd -t" --become
```

### ✅ Fixes

* Ensure vhost template wrote correct `ServerName` and `DocumentRoot`
* Restart Apache:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "systemctl restart httpd" --become
```

### ✅ Validate using Host header (best practice in labs without DNS)

```bash
curl -s -H "Host: example1.local" http://10.0.1.10 | head
curl -s -H "Host: example2.local" http://10.0.1.10 | head
curl -s -H "Host: test.local"     http://10.0.1.10 | head
```

---

## 5) HTTPS Works but Browser Shows Certificate Warning

### ✅ Symptoms

* Browser warning: untrusted certificate
* `curl` fails without `-k`

### 🔍 Explanation

This lab uses **self-signed certificates** generated automatically. They are valid for testing but not trusted by clients.

### ✅ Fix / Workarounds

* Use curl with `-k`:

```bash
curl -I -k https://10.0.1.10
```

* For production:

  * Replace self-signed certs with CA-signed certs (Let’s Encrypt, internal PKI, etc.)
  * Use real DNS names matching certificate CN/SAN.

---

## 6) SSL/TLS Config Breaks Apache Startup

### ✅ Symptoms

* Apache fails after SSL changes
* `httpd -t` returns errors

### 🔍 Checks

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "httpd -t" --become
```

### ✅ Fixes

* Review SSL config:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "cat /etc/httpd/conf.d/ssl-security.conf" --become
```

* Check `mod_ssl` installed:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "rpm -qa | grep -E '^mod_ssl|^httpd'" --become
```

* Restart after fixing:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "systemctl restart httpd" --become
```

---

## 7) Error Pages Not Working (404/500 still default)

### ✅ Symptoms

* Hitting a nonexistent page shows Apache default 404
* Custom pages not served

### 🔍 Checks

* Confirm error pages exist:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "ls -la /var/www/error-pages" --become
```

* Confirm block inserted into config:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "grep -n 'ANSIBLE MANAGED BLOCK - Error Pages' -n /etc/httpd/conf/httpd.conf -n | head" --become
```

### ✅ Fixes

* Restart Apache:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "systemctl restart httpd" --become
```

* Validate:

```bash
curl -i http://10.0.1.10/nonexistent-page | head -n 15
```

---

## 8) `apache2_module` Task Failed (Expected on RHEL)

### ✅ Symptoms

Playbook shows:

* `The module apache2_module was not found in configured module paths`

### ✅ Why It Happened

`apache2_module` is typical for Debian/Ubuntu module management.
On CentOS/RHEL, modules are typically handled via installed packages and config includes.

### ✅ Resolution Used in Lab

The playbook continued using an alternative approach:

* inserted `LoadModule ...` lines via `lineinfile`
* ran `httpd -t` to validate
* restarted Apache

---

## 9) Automated Tests Fail (Ports / HTTP / HTTPS)

### ✅ Symptoms

* `wait_for` fails on 80 or 443
* `uri` fails

### 🔍 Checks

* Confirm ports:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "ss -tulpn | egrep ':80|:443'" --become
```

* Confirm service:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "systemctl is-active httpd && systemctl is-enabled httpd" --become
```

* Confirm firewall:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "firewall-cmd --list-services" --become
```

### ✅ Fixes

* Restart service:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "systemctl restart httpd" --become
```

* Reload firewall:

```bash
ansible -i inventory/hosts.yml webservers -m shell -a "firewall-cmd --reload" --become
```

---

## ✅ Quick “Recovery Checklist” (Fast Path)

# 1) Inventory connectivity
```
ansible -i inventory/hosts.yml webservers -m ping
```

# 2) Service status
```
ansible -i inventory/hosts.yml webservers -m shell -a "systemctl status httpd --no-pager | head -n 12" --become
```

# 3) Config syntax
```
ansible -i inventory/hosts.yml webservers -m shell -a "httpd -t" --become
```

# 4) Firewall services
```
ansible -i inventory/hosts.yml webservers -m shell -a "firewall-cmd --list-services" --become
```

# 5) HTTP/HTTPS check
```
curl -I http://10.0.1.10
curl -I -k https://10.0.1.10
```

---
