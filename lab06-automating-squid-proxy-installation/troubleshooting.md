# 🛠️ Lab 06 — Troubleshooting Guide (Squid Proxy Automation with Ansible)

> This document captures common issues encountered when automating Squid installation and configuration using Ansible, along with practical fixes and verification steps.

---

## Issue 1: Squid service fails to start

### ✅ Symptoms
- `systemctl status squid` shows **failed** or service stops immediately after start
- Squid does not listen on port `3128`
- Client requests fail with connection errors

### 🔎 Possible Causes
- Invalid `/etc/squid/squid.conf` syntax
- Wrong permissions on cache directory (`/var/spool/squid`)
- Corrupt or uninitialized cache directory
- Service restart attempted with a broken config

### ✅ Fix Steps

#### 1) Validate configuration syntax
```bash
ansible proxy_servers -i inventory/hosts.yml -m command -a "squid -k parse"
````

**Expected Output (Example from lab):**

```text
squid-server | CHANGED | rc=0 >>
2026/02/27 11:29:31| Processing Configuration File: /etc/squid/squid.conf (depth 0)
2026/02/27 11:29:31| Parsed configuration file successfully.
```

#### 2) Check Squid logs via systemd journal

```bash
ansible proxy_servers -i inventory/hosts.yml -m command -a "journalctl -u squid -n 50"
```

**Expected Output (Example from lab):**

```text
-- Logs begin at Tue 2026-02-27 10:58:01 UTC, end at Tue 2026-02-27 11:29:55 UTC. --
Feb 27 11:25:17 squid-server systemd[1]: Started Squid caching proxy.
Feb 27 11:25:17 squid-server squid[1762]: Squid Parent: will start 1 kids
Feb 27 11:25:17 squid-server squid[1762]: Squid Parent: (squid-1) process 1764 started
Feb 27 11:25:18 squid-server squid[1764]: Accepting HTTP Socket connections at 0.0.0.0:3128, FD 12.
```

#### 3) Verify cache directory permissions and structure

```bash
ansible proxy_servers -i inventory/hosts.yml -m command -a "ls -la /var/spool/squid"
```

**Expected Output (Example from lab):**

```text
total 16
drwxr-xr-x  4 squid squid 4096 Feb 27 11:18 .
drwxr-xr-x 20 root  root  4096 Feb 27 11:17 ..
drwxr-xr-x  2 squid squid 4096 Feb 27 11:18 00
drwxr-xr-x  2 squid squid 4096 Feb 27 11:18 01
```

### ✅ Verification

* `systemctl status squid` shows `active (running)`
* `netstat -tlnp | grep 3128` shows Squid listening
* `squid -k parse` returns success

---

## Issue 2: Proxy connection refused (client cannot connect)

### ✅ Symptoms

* Client errors like:

  * `Connection refused`
  * `Failed to connect to proxy`
* No traffic in `/var/log/squid/access.log`

### 🔎 Possible Causes

* Firewall port not open (`3128/tcp`)
* Squid not listening on 0.0.0.0 (binding issue)
* Service not running
* Wrong proxy IP/port on client test command

### ✅ Fix Steps

#### 1) Confirm firewall allows Squid port

```bash
ansible proxy_servers -i inventory/hosts.yml -m command -a "firewall-cmd --list-ports"
```

**Expected Output (Example from lab):**

```text
3128/tcp
```

#### 2) Verify Squid is listening on port 3128

```bash
ansible proxy_servers -i inventory/hosts.yml -m command -a "netstat -tlnp | grep 3128"
```

**Expected Output (Example from lab):**

```text
tcp        0      0 0.0.0.0:3128            0.0.0.0:*               LISTEN      1764/(squid-1)
```

#### 3) Confirm service is running

```bash
ansible proxy_servers -i inventory/hosts.yml -m command -a "systemctl status squid"
```

### ✅ Verification

* Client can run:

  * `curl -x <proxy-ip>:3128 http://www.google.com`
  * `curl -x <proxy-ip>:3128 -v http://httpbin.org/ip`
* Squid access log contains entries for those requests

---

## Issue 3: Access denied errors (HTTP 403 Forbidden)

### ✅ Symptoms

* Requests return `403 Forbidden`
* Squid denies access even though proxy responds

### 🔎 Possible Causes

* Client IP not matching allowed networks in ACL
* ACL rules in wrong order (Squid processes top → down)
* Missing ACL definitions for custom networks
* Deny rules placed above allow rules

### ✅ Fix Steps

#### 1) Review ACL configuration in `squid.conf`

Focus on:

* `acl allowed_nets src <CIDR>`
* `http_access allow allowed_nets`
* Ensure `http_access deny all` comes **last**

#### 2) Confirm client IP belongs to allowed networks

* Example allowed networks in lab:

  * `192.168.1.0/24`
  * `10.0.0.0/8`

#### 3) Re-validate config after editing

```bash
ansible proxy_servers -i inventory/hosts.yml -m command -a "squid -k parse"
```

#### 4) Restart Squid after fixes

```bash
ansible proxy_servers -i inventory/hosts.yml -m systemd -a "name=squid state=restarted"
```

### ✅ Verification

* Requests return `200 OK`
* Access log shows allowed traffic entries

---

## 🚀 Performance Optimization Tips (Operational Hardening)

### 1) Cache size tuning

* Adjust `cache_dir` size based on disk availability:

  * Example from lab: `1000 MB`

### 2) Memory optimization

* `cache_mem 256 MB` should be set according to available RAM and workload

### 3) DNS performance

* Use fast/resilient resolvers; lab used:

  * `8.8.8.8` and `8.8.4.4`

### 4) Log management

* Ensure logrotate is configured (as done in this lab) to prevent logs filling disk:

  * `/etc/logrotate.d/squid`

---

## ✅ Quick Validation Checklist

Use this checklist if anything feels off:

* [ ] `squid -k parse` succeeds
* [ ] `systemctl status squid` shows `active (running)`
* [ ] `firewall-cmd --list-ports` includes `3128/tcp`
* [ ] `netstat -tlnp | grep 3128` shows Squid listening
* [ ] `tail -n 20 /var/log/squid/access.log` shows recent proxy requests
* [ ] `squidclient mgr:info` returns stats successfully

```
