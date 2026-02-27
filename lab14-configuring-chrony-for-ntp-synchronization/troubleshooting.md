# 🛠️ Troubleshooting Guide — Lab 14: Configuring Chrony for NTP Synchronization

> This guide lists common Chrony/NTP issues and how to diagnose and fix them on CentOS/RHEL-based systems.

---

## Issue 1: `chronyd` service is inactive / not running

### ✅ Symptoms
- `systemctl status chronyd` shows:
  - `inactive (dead)` or `failed`

### 🔎 Checks
```bash
sudo systemctl status chronyd
sudo journalctl -u chronyd --no-pager -n 50
````

### ✅ Fix

```bash
sudo systemctl start chronyd
sudo systemctl enable chronyd
sudo systemctl status chronyd
```

---

## Issue 2: Chrony is running but not synchronizing (no `^*` source)

### ✅ Symptoms

* `chrony sources -v` shows no `^*` selected source
* `chrony tracking` shows large offsets or `Leap status` not normal

### ✅ Causes

* NTP servers blocked by firewall / no internet
* DNS resolution issues
* Incorrect server entries in `/etc/chrony.conf`

### 🔎 Checks

```bash
chrony sources -v
chrony tracking
ping -c 3 pool.ntp.org
timedatectl status
```

Check firewall configuration:

```bash
sudo firewall-cmd --state
sudo firewall-cmd --list-all
```

### ✅ Fix

Force a step sync (especially after boot or big drift):

```bash
sudo chrony makestep
```

If servers unreachable, validate network + DNS:

```bash
ping -c 3 8.8.8.8
getent hosts pool.ntp.org
```

---

## Issue 3: Firewall blocks NTP (server mode / client issues)

### ✅ Symptoms

* Clients cannot sync from this host when configured as server
* NTP queries appear blocked

### ✅ Cause

NTP requires UDP port 123. In firewalld you must allow it.

### ✅ Fix

```bash
sudo firewall-cmd --permanent --add-service=ntp
sudo firewall-cmd --reload
sudo firewall-cmd --list-services | grep ntp
```

---

## Issue 4: `netstat: command not found`

### ✅ Symptoms

```bash
sudo netstat -ulnp | grep :123
```

returns:

```text
bash: netstat: command not found
```

### ✅ Cause

Minimal installs often don’t include `net-tools`.

### ✅ Fix

```bash
sudo dnf install net-tools -y
sudo netstat -ulnp | grep :123
```

✅ Expected output:

```text
udp   0  0 0.0.0.0:123   0.0.0.0:*   <PID>/chronyd
udp6  0  0 :::123        :::*        <PID>/chronyd
```

> Tip: On modern systems, `ss` can replace netstat:

```bash
sudo ss -ulnp | grep :123
```

---

## Issue 5: Configuration typo prevents Chrony from starting

### ✅ Symptoms

* `systemctl start chronyd` fails
* Logs show parsing errors

### 🔎 Checks

Run chronyd in foreground debug mode:

```bash
sudo chronyd -n -d
```

Check logs:

```bash
sudo journalctl -u chronyd --no-pager -n 50
```

### ✅ Fix

Restore original config backup:

```bash
sudo cp /etc/chrony.conf.backup /etc/chrony.conf
sudo systemctl restart chronyd
```

Then re-apply changes carefully.

---

## Issue 6: Large time jumps / unstable time adjustments

### ✅ Symptoms

* System time jumps by seconds/minutes unexpectedly
* Logs mention stepping the clock frequently

### ✅ Causes

* Very large drift at boot
* Poor network conditions or unstable time source
* Too aggressive stepping config

### ✅ Fix

Tune makestep to smaller threshold (lab used an example):

```bash
echo "makestep 0.1 3" | sudo tee -a /etc/chrony.conf
sudo systemctl restart chronyd
```

Check if stepping occurred:

```bash
sudo journalctl -u chronyd --no-pager | grep -i step | tail -n 20
```

---

## Issue 7: `hwclock --compare` fails on cloud VM

### ✅ Symptoms

```bash
sudo hwclock --compare
```

returns:

```text
hwclock: Cannot access the Hardware Clock via any known method.
```

### ✅ Cause

Some cloud VMs do not expose a standard RTC device. This is common in virtualized environments.

### ✅ Fix / Workaround

* Treat this as expected on some VMs
* Use `timedatectl status` and Chrony tracking for time health:

```bash
timedatectl status
chrony tracking
```

---

## ✅ Quick Validation Checklist (Fast)

# Service status
```
sudo systemctl status chronyd --no-pager | head -n 12
```

# Sync sources (look for ^*)
```
chrony sources -v | head -n 20
```

# Tracking health
```
chrony tracking | head -n 20
```

# Is system clock synchronized?
```
timedatectl status | tail -n 10
```

# Firewall (server mode)
```
sudo firewall-cmd --list-services | grep ntp
```

# UDP 123 listening
```
sudo ss -ulnp | grep :123
```

---

## ✅ Operational Tip (Day-2 Admin)

Run the monitoring script to capture a quick report:

```bash
sudo /usr/local/bin/chrony-monitor.sh
```

This provides sources + tracking + service status in one place.
---
