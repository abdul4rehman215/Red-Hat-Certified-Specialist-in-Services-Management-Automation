# 🛠️ Troubleshooting Guide — Lab 01: Automation Using Ansible Basics

> This file documents common issues encountered during Ansible automation tasks, along with practical checks and fixes.

---

## 1) SSH / Connectivity Failures

### ✅ Symptoms
- `UNREACHABLE!` errors in Ansible output
- `Permission denied (publickey)` when Ansible attempts SSH
- `ansible all -m ping` fails

### 🔍 Likely Causes
- Wrong SSH username in inventory
- SSH key path incorrect
- Host unreachable / DNS issue
- Python interpreter mismatch on target nodes

### ✅ Fix / Validation Steps
```bash
# Verify inventory is correct
cat /etc/ansible/hosts

# Test SSH directly
ssh node1 "hostname"
ssh node2 "hostname"

# Ansible verbose ping
ansible all -m ping -vvv
````

### ✅ Notes from this lab

In this environment, key-based auth was preconfigured and the inventory included:

* `ansible_user=ansible`
* `ansible_ssh_private_key_file=/home/ansible/.ssh/id_rsa`
* `ansible_python_interpreter=/usr/bin/python3`

---

## 2) Privilege / Permission Errors (Missing become)

### ✅ Symptoms

* Package install fails (yum permission denied)
* Service start/enable fails
* Writing to `/etc/sudoers.d/` fails
* Firewall rules fail to apply

### 🔍 Likely Causes

* `become: yes` missing in playbook
* Using ad-hoc commands without `-b`

### ✅ Fix / Validation Steps

```bash
# Run playbook in check mode to validate expected behavior safely
ansible-playbook webserver-setup.yml --check --diff

# Use become in ad-hoc commands
ansible all -m shell -a "systemctl status httpd" -b
```

---

## 3) Service Start Failures (httpd / mariadb)

### ✅ Symptoms

* Playbook reports failure on service task
* `systemctl status httpd` shows error
* `uri` checks return connection refused / timeout

### 🔍 Likely Causes

* Package not installed correctly
* Firewall not opened
* Service misconfiguration / port conflict

### ✅ Fix / Validation Steps

```bash
# Check httpd status using Ansible become
ansible all -m shell -a "systemctl status httpd" -b

# Verify firewall service and http access
ansible all -m shell -a "systemctl status firewalld" -b
ansible webservers -m uri -a "url=http://{{ ansible_default_ipv4.address }}"
```

### ✅ Notes from this lab

Apache verification succeeded with HTTP 200 on both hosts after opening firewall for `http`.

---

## 4) YAML Syntax / Indentation Errors

### ✅ Symptoms

* `ERROR! mapping values are not allowed in this context`
* `ERROR! conflicting action statements`
* `ERROR! found character that cannot start any token`

### 🔍 Likely Causes

* Incorrect indentation (spaces vs tabs)
* Misaligned `hosts:` or `tasks:`
* Invalid loop structures

### ✅ Fix / Validation Steps

```bash
# Basic YAML sanity check by running playbook
ansible-playbook <playbook>.yml

# Use a linter if available (optional)
# yamllint <playbook>.yml
```

### ✅ Notes from this lab (realistic fixes applied)

* `complete-setup.yml`: `hosts:` alignment corrected (indentation fix only)
* `user-management.yml`: ensured nested directory creation used valid `with_nested`
* The intent of tasks was preserved; only minimal changes were applied to make playbooks runnable.

---

## 5) Template Variable Errors (Undefined variables)

### ✅ Symptoms

* Template task fails with undefined variable error:

  * `ERROR! 'ansible_user_list' is undefined`
  * `ERROR! 'ansible_group_list' is undefined`
  * `ERROR! 'users_to_create' is undefined`

### 🔍 Likely Causes

* Template references facts/vars that don’t exist by default
* Variables not passed into template task

### ✅ Fix / Validation Steps

```bash
# Use getent to gather passwd/group information
# and pass it into the template as vars.

ansible-playbook user-audit.yml
```

### ✅ Notes from this lab (realistic fix applied)

The audit workflow used `getent` to gather:

* `passwd_entries` from `getent passwd`
* `group_entries` from `getent group`

These were then passed into the template so the report rendered successfully.

---

## 6) User Creation / Group Membership Issues

### ✅ Symptoms

* Users missing on some hosts
* User exists but group membership missing
* Home directory not created
* SSH directory permissions incorrect

### 🔍 Likely Causes

* Group not created before user creation
* Incorrect list formatting for `groups`
* `create_home` missing

### ✅ Fix / Validation Steps

```bash
# Confirm users exist
ansible all -m shell -a "id developer1"
ansible all -m shell -a "id operator1"

# Confirm passwd entries exist
ansible all -m shell -a "getent passwd | grep developer"
```

---

## 7) Cleanup Playbook “Archive cannot stat /home/<user>” Errors

### ✅ Symptoms

* Archive task fails:

  * `Error, cannot stat /home/testuser1`
* Playbook shows failed archive tasks but continues

### 🔍 Likely Causes

* User never existed on system
* Home directory already deleted (or never created)
* Cleanup run on a fresh environment

### ✅ Fix / Handling Strategy

* Use `ignore_errors: yes` for archive step if the goal is best-effort backup.
* Optionally add a pre-check to verify path exists before archive.

### ✅ Notes from this lab

This behavior was expected and realistic because the users targeted for cleanup were not present in the environment, and `ignore_errors: yes` allowed the playbook to complete successfully.

---

## ✅ Quick Recovery Checklist

# 1) Connectivity
```
ansible all -m ping -vvv
```

# 2) Inventory sanity
```
cat /etc/ansible/hosts
```

# 3) Privilege check
```
ansible all -m shell -a "whoami" -b
```

# 4) Validate Apache
```
ansible webservers -m uri -a "url=http://{{ ansible_default_ipv4.address }}"
```

# 5) Validate users
```
ansible all -m shell -a "id developer1"
```

---
