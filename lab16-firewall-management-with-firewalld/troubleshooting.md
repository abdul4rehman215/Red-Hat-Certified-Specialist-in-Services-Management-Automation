# 🛠️ Troubleshooting Guide — Lab 16: Firewall Management with firewalld (Ansible)

> This guide covers common issues when managing firewalld using Ansible across multiple nodes, including problems observed in this lab run.

---

## Issue 1: `ansible all -m ping` fails (SSH unreachable)

### ✅ Symptoms
- `UNREACHABLE!` errors
- SSH key authentication fails
- Host key verification prompts block automation

### 🔎 Checks (Control Node)
1) Verify inventory content:
```bash
cat inventory
````

2. Confirm the SSH key path exists:

```bash id="u4t9z2"
ls -la ~/.ssh/lab_key ~/.ssh/lab_key.pub
```

3. Manual SSH test:

```bash id="c2r1m9"
ssh -i ~/.ssh/lab_key student@192.168.1.10
ssh -i ~/.ssh/lab_key student@192.168.1.11
```

### ✅ Fix

* Generate the key if missing (this happened in this lab):

```bash id="k7x1m2"
ssh-keygen -t ed25519 -f ~/.ssh/lab_key -N ""
```

* Ensure host key checking doesn't block:

```ini
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

---

## Issue 2: firewalld service not running on managed nodes

### ✅ Symptoms

* firewall rules don’t apply
* `firewall-cmd` returns errors like “FirewallD is not running”
* Ansible tasks fail on `firewalld:` module

### 🔎 Checks

```bash id="f3w8z9"
ansible all -i inventory -m shell -a "systemctl status firewalld" --become
```

### ✅ Fix

Start and enable firewalld (Ansible):

```yaml id="e9a0u3"
- name: Start and enable firewalld service
  systemd:
    name: firewalld
    state: started
    enabled: yes
```

Or manually:

```bash id="b2n8x7"
sudo systemctl start firewalld
sudo systemctl enable firewalld
```

---

## Issue 3: Zones not applied / interface bound to unexpected zone

### ✅ Symptoms

* `firewall-cmd --get-zone-of-interface=eth0` returns wrong zone
* traffic doesn’t behave as expected

### 🔎 Check zone assignment

```bash id="j1x5k6"
ansible all -i inventory -m shell -a "firewall-cmd --get-zone-of-interface=eth0" --become
```

### ✅ Fix

Explicitly bind interface to zone (example used on db1):

```yaml id="d1m6r2"
- name: Set interface to database zone
  firewalld:
    interface: eth0
    zone: database
    permanent: yes
    immediate: yes
    state: enabled
```

If changes appear inconsistent:

```bash id="x7q2p8"
firewall-cmd --complete-reload
```

---

## Issue 4: Rich rule syntax errors

### ✅ Symptoms

* Playbook fails with “INVALID_RULE”
* firewalld rejects the rule

### 🔎 Validate config

```bash id="x2n9r1"
ansible webservers -i inventory -m shell -a "firewall-cmd --check-config" --become
```

Test a rule temporarily (safe approach):

```bash id="m0t1y9"
firewall-cmd --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" accept' --timeout=10
```

### ✅ Fix

* Ensure quoting is correct in YAML (single quotes wrapping the whole rule helps).
* Avoid line wrapping in port ranges (keep the rule on one line).
* Use `--check-config` after applying.

---

## Issue 5: Service appears allowed but port still unreachable

### ✅ Symptoms

* firewalld shows service enabled
* but connection tests fail

### 🔎 Checks

1. Confirm service is listening:

```bash id="f6p3r1"
ansible webservers -i inventory -m shell -a "ss -tlnp | grep :80 || true" --become
```

2. Verify firewall allows it:

```bash id="g2k8m1"
ansible webservers -i inventory -m shell -a "firewall-cmd --zone=public --list-services" --become
ansible webservers -i inventory -m shell -a "firewall-cmd --zone=public --list-ports" --become
```

### ✅ Fix

* Start the actual service (example: nginx/httpd), firewall alone won’t open a closed service.
* Confirm correct zone is applied to the interface.

---

## Issue 6: HTTPS shows BLOCKED/UNAVAILABLE in tests

### ✅ Symptoms

Connectivity test output:

* HTTP accessible
* HTTPS blocked/unavailable

### Causes

* Firewall allows `https` but the HTTPS service is not running/listening
* No server binding on port 443

### 🔎 Checks

```bash id="q2m7x9"
ansible webservers -i inventory -m shell -a "ss -tlnp | grep :443 || true" --become
```

### ✅ Fix

Install/enable HTTPS listener (nginx/httpd + TLS config) if required.
Firewall rule alone does not create a service listener.

---

## Issue 7: MariaDB service name mismatch (`mysqld.service` not found)

### ✅ Symptoms

```bash
systemctl status mysqld
```

returns:

* `Unit mysqld.service could not be found`

### ✅ Fix

On many systems, service is `mariadb`:

```bash id="b8r2v9"
ansible dbservers -i inventory -m shell -a "systemctl status mariadb" --become
```

---

## Issue 8: Firewall logging not showing in expected files

### ✅ Symptoms

* `/var/log/firewall-rejected.log` missing or empty
* firewall denies not logged

### 🔎 Checks

1. Confirm LogDenied is enabled:

```bash id="m7p4k2"
ansible all -i inventory -m shell -a "grep -E '^LogDenied=' /etc/firewalld/firewalld.conf" --become
```

2. Confirm rsyslog block exists:

```bash id="v5x9z7"
ansible all -i inventory -m shell -a "grep -n 'FIREWALL LOGGING BLOCK' -n /etc/rsyslog.conf -n" --become
```

3. Confirm rsyslog restarted:

```bash id="e2k1x3"
ansible all -i inventory -m shell -a "systemctl status rsyslog" --become
```

### ✅ Fix

* Restart firewalld and rsyslog:

```bash id="t3m8p1"
ansible all -i inventory -m shell -a "systemctl restart firewalld && systemctl restart rsyslog" --become
```

* Generate a deny event to test (attempt blocked port 9999), then check logs:

```bash id="k9r2m4"
ansible all -i inventory -m shell -a "tail -50 /var/log/messages | grep -i firewall" --become
```

---

## Issue 9: `AllowZoneDrifting` warning appears in logs

### ✅ Symptoms

`/var/log/messages` shows:

* `WARNING: AllowZoneDrifting is enabled. This is considered an insecure configuration option...`

### Meaning

This is a known warning on some firewalld builds. It is not a failure, but it is a **security note**.

### Recommendation

In hardened environments:

* avoid relying on drifting behavior
* ensure interfaces are explicitly bound to zones
* keep policies strict and predictable

---

## ✅ Quick Validation Checklist (Fast)

### Control Node

```bash id="w2x1a9"
ansible all -i inventory -m ping
ansible all -i inventory -m shell -a "firewall-cmd --state" --become
```

### Web Node (web1)

```bash id="c7m2p4"
ansible webservers -i inventory -m shell -a "firewall-cmd --get-default-zone" --become
ansible webservers -i inventory -m shell -a "firewall-cmd --zone=public --list-services" --become
ansible webservers -i inventory -m shell -a "firewall-cmd --zone=public --list-ports" --become
ansible webservers -i inventory -m shell -a "firewall-cmd --list-rich-rules" --become
```

### DB Node (db1)

```bash id="p8x1m6"
ansible dbservers -i inventory -m shell -a "firewall-cmd --get-zone-of-interface=eth0" --become
ansible dbservers -i inventory -m shell -a "firewall-cmd --list-rich-rules" --become
```

### End-to-end connectivity (Control Node script)

```bash id="r3m7x2"
./scripts/test-connectivity.sh
```

---
