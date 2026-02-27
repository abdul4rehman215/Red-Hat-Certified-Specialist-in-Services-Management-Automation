# 🛠️ Troubleshooting Guide — Lab 03: Ansible Roles and Templates

> This document captures real-world issues you can hit when working with roles and templates, and the exact commands used to debug and fix them.

---

## 1) Role Not Found

### ✅ Symptoms
- Playbook fails with:
  - `ERROR! the role 'apache-role' was not found`

### 🔍 Common Causes
- Running the playbook from the wrong directory
- Role folder name mismatch (e.g., `apache_role` vs `apache-role`)
- Role not in Ansible `roles_path`

### ✅ Fix / Validation
```bash
pwd
ls -la apache-role/
ansible-galaxy list
````

### ✅ Notes from this lab

Local roles stored inside the project directory are valid even if they are not installed system-wide.

---

## 2) `include_vars` Fails (OS-specific vars file not found)

### ✅ Symptoms

* Errors like:

  * `Could not find or access 'RedHat.yml'`
  * `Could not find or access 'Debian.yml'`

### 🔍 Common Causes

* Wrong filename in `include_vars`
* Missing `.yml` extension
* Case mismatch (Linux is case-sensitive)

### ✅ Fix / Validation

# confirm files exist
```
ls -la apache-role/vars/
```

# confirm ansible fact used for the include
```
ansible -i inventory.ini webservers -m setup -a "filter=ansible_os_family"
```

# ensure tasks/main.yml includes:
```
include_vars: "{{ ansible_os_family }}.yml"
```

---

## 3) Templates Render With Literal `{{ variable }}` (Variables Not Resolved)

### ✅ Symptoms

* Web page or config file contains:

  * `{{ ansible_hostname }}`
  * `{{ apache_server_name }}`

### 🔍 Common Causes

* Facts not gathered (missing `gather_facts: yes`)
* Variables not defined (missing defaults/vars/group_vars/host_vars)
* Template copied as a static file instead of `template:` module

### ✅ Fix / Validation

# verify playbook syntax
```
ansible-playbook -i inventory.ini deploy-apache.yml --syntax-check
```

# run verbose to see resolved vars and task execution
```
ansible-playbook -i inventory.ini deploy-apache.yml -v --extra-vars "debug=true"
```

---

## 4) Permission Denied Errors (Package install, service restart, file writes)

### ✅ Symptoms

* Tasks fail while installing packages, writing `/etc/...`, restarting services, or opening firewall.

### 🔍 Common Causes

* `become: yes` missing
* Remote user lacks sudo permissions
* SSH key permission too open

### ✅ Fix / Validation

# fix ssh key permissions (common)
```
chmod 600 ~/.ssh/id_rsa
```

# verify sudo works on targets
```
ansible -i inventory.ini webservers -m shell -a "sudo whoami"
```

---

## 5) Service Won’t Start (httpd/apache2)

### ✅ Symptoms

* `systemctl status httpd` shows failed
* HTTP check fails (`uri` or `curl`)

### 🔍 Common Causes

* Wrong service name (differs by OS)
* Port conflict
* Config syntax error
* Firewall blocking

### ✅ Fix / Validation

# check service status across all nodes
```
ansible -i inventory.ini webservers -m shell -a "systemctl status httpd || systemctl status apache2" --become
```

# check apache is active
```
ansible -i inventory.ini webservers -m shell -a "systemctl status httpd apache2 2>/dev/null | grep Active" --become
```

---

## 6) Firewall Blocking HTTP Access

### ✅ Symptoms

* Apache service is running but `curl` / browser cannot connect
* `uri` task fails or times out

### 🔍 Common Causes

* `firewalld` not configured (RedHat)
* `ufw` rules missing (Debian/Ubuntu)
* Security group / network ACL (cloud) blocks inbound 80/8080

### ✅ Fix / Validation (RedHat)

```bash
ansible -i inventory.ini webservers -m shell -a "firewall-cmd --list-services" --become
ansible -i inventory.ini webservers -m shell -a "firewall-cmd --permanent --add-service=http && firewall-cmd --reload" --become
```

### ✅ Notes from this lab

Ubuntu node showed:

* `/bin/sh: 1: firewall-cmd: not found`
  This is normal because Ubuntu commonly uses `ufw`, not `firewalld`.

---

## 7) `uri` Verification Issues

### ✅ Symptoms

* `status_code` not 200
* Connection refused / timeout
* Wrong URL or wrong port

### 🔍 Common Causes

* Apache bound to a different port
* Firewall blocking
* Using private IP that isn’t reachable from the control node’s network path

### ✅ Fix / Validation

# verify HTTP 200 using Ansible uri module
```
ansible -i inventory.ini webservers -m uri -a "url=http://{{ ansible_default_ipv4.address }} method=GET status_code=200" --delegate-to localhost
```

---

## 8) Idempotency Fails (Playbook keeps changing every run)

### ✅ Symptoms

* Second run still shows `changed > 0`

### 🔍 Common Causes

* Templates use timestamps or random values
* File permissions/ownership drift
* Service restart triggers due to file changes

### ✅ Fix / Validation

# run twice and compare recap
```
ansible-playbook -i inventory.ini deploy-apache.yml
ansible-playbook -i inventory.ini deploy-apache.yml
```

### ✅ Notes from this lab

Second run showed `changed=0` confirming idempotency.

---

## 9) Mixed OS Nodes (Different package/service names)

### ✅ Symptoms

* Debian nodes fail package install if using `httpd`
* RedHat nodes fail if using `apache2`

### 🔍 Common Causes

* Not separating OS-specific variables

### ✅ Fix / Validation

* Keep package/service names per OS in role vars:

  * `vars/RedHat.yml` → `httpd`
  * `vars/Debian.yml` → `apache2`
* Include them dynamically using:

  * `include_vars: "{{ ansible_os_family }}.yml"`

---

## ✅ Quick Recovery Checklist

# 1) Confirm role is present
```
ls -la apache-role/
```

# 2) Syntax check
```
ansible-playbook -i inventory.ini deploy-apache.yml --syntax-check
```

# 3) Connectivity
```
ansible -i inventory.ini webservers -m ping
```

# 4) Deploy (verbose)
```
ansible-playbook -i inventory.ini deploy-apache.yml -v
```

# 5) Service status
```
ansible -i inventory.ini webservers -m shell -a "systemctl status httpd || systemctl status apache2" --become
```

# 6) HTTP verification
```
ansible -i inventory.ini webservers -m uri -a "url=http://{{ ansible_default_ipv4.address }} method=GET status_code=200" --delegate-to localhost
```

---
