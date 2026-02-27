# 🛠️ Troubleshooting Guide — Lab 20: Configuring Resource Limits for Services

> This guide lists common issues when applying **systemd resource limits**, automating via **Ansible**, and validating via `systemctl` + `journalctl`.

---

## ✅ Issue 1: Service fails to start after adding resource limits

### **Symptoms**
- `systemctl start <service>` fails
- `systemctl status <service>` shows errors or restart loops

### **Likely Causes**
- Limits too restrictive (CPUQuota too low, TasksMax too low, MemoryMax too small)
- Wrong ExecStart path
- Service user lacks permissions for required files

### **Fix**
1) Inspect failure details:
```bash
systemctl status <service> -l
journalctl -u <service> --since "15 minutes ago" -l
````

2. Relax limits temporarily (edit unit or drop-in override):

```ini
CPUQuota=80%
MemoryMax=512M
TasksMax=100
```

3. Reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart <service>
```

---

## ✅ Issue 2: Limits appear not to be enforced

### **Symptoms**

* Service uses more CPU/memory than expected
* `systemctl status` does not show Memory/Tasks limits

### **Likely Causes**

* Accounting disabled
* You edited a unit file but forgot `daemon-reload`
* You changed a drop-in override but didn’t reload/restart
* You’re checking the wrong service name (typo)

### **Fix**

1. Ensure accounting is enabled in the unit:

```ini
CPUAccounting=yes
MemoryAccounting=yes
TasksAccounting=yes
IOAccounting=yes
```

2. Reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart <service>
```

3. Verify applied values:

```bash
systemctl show <service> --property=CPUQuotaPerSecUSec,MemoryMax,TasksMax,IOWeight
```

---

## ✅ Issue 3: `IOReadBandwidthMax` / `IOWriteBandwidthMax` not applied

### **Symptoms**

* No I/O throttling effect observed
* systemd logs may show device-related config issues

### **Likely Causes**

* Wrong block device path in unit file (`/dev/sda` vs `/dev/nvme0n1`)
* Service runs on a different device than the one throttled
* Device name differs across systems (common in clouds)

### **Fix**

1. Identify disks:

```bash
lsblk -d -o NAME,SIZE,TYPE
```

2. Update unit to correct device:

```ini
IOReadBandwidthMax=/dev/nvme0n1 10M
IOWriteBandwidthMax=/dev/nvme0n1 5M
```

3. Reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart webserver-sim.service
```

---

## ✅ Issue 4: Memory limit is different from the unit file value

### **Symptoms**

* Unit file says `MemoryMax=100M`
* `systemctl status` shows different limit (e.g., `256.0M`)

### **Likely Cause**

A **drop-in override** was applied via Ansible:

* `/etc/systemd/system/<service>.service.d/resource-limits.conf`

### **Fix**

Check drop-ins:

```bash
systemctl cat <service>
```

List override directory:

```bash
ls -la /etc/systemd/system/<service>.service.d/
cat /etc/systemd/system/<service>.service.d/resource-limits.conf
```

---

## ✅ Issue 5: Ansible playbook fails due to inventory or connection errors

### **Symptoms**

* `unreachable` errors
* authentication / SSH failures

### **Likely Causes**

* Wrong inventory syntax
* Wrong connection method
* Target hosts unreachable

### **Fix (local lab target)**

Use local connection:

```ini
localhost ansible_connection=local
```

Test:

```bash
ansible all -i inventory.ini -m ping
```

---

## ✅ Issue 6: Nginx-limited service fails to start

### **Symptoms**

* `nginx-limited.service` fails with missing binary or config error

### **Likely Causes**

* nginx not installed
* nginx default config missing/invalid
* port conflict (another nginx instance already bound)

### **Fix**

1. Install nginx:

```bash
sudo dnf install nginx -y
```

2. Validate nginx config:

```bash
sudo nginx -t
```

3. Check port usage if bind fails:

```bash
sudo ss -tlnp | grep :80
```

Restart:

```bash
sudo systemctl restart nginx-limited.service
```

---

## ✅ Issue 7: `systemctl show --property=...` returns empty or `[not set]`

### **Symptoms**

* `MemoryCurrent=[not set]` or properties missing

### **Likely Causes**

* Accounting disabled
* Service not running
* systemd version differences
* wrong unit name

### **Fix**

1. Ensure service is active:

```bash
systemctl is-active <service>
```

2. Enable accounting and restart service.

---

## ✅ Issue 8: Monitoring scripts don’t show expected services

### **Symptoms**

* Dashboard shows INACTIVE for services you expect ACTIVE

### **Likely Causes**

* Wrong service name
* Service is stopped
* Script checks `<name>.service` but you used different unit name

### **Fix**

List services:

```bash
systemctl list-units --type=service | grep -E "(resource-test|webserver-sim|database-sim|nginx-limited)"
```

Then update script service array if needed:

```bash
services=("resource-test" "webserver-sim" "database-sim" "nginx-limited")
```

---

## ✅ Issue 9: Cron job not running monitoring scripts

### **Symptoms**

* No output appended to `/var/log/service-resources.log`
* No alerts written

### **Likely Causes**

* script path not executable
* cron environment missing PATH
* permission issues writing to logs

### **Fix**

1. Confirm execute bit:

```bash
ls -la /usr/local/bin/service-resource-monitor.sh
ls -la /usr/local/bin/resource-threshold-monitor.sh
```

2. Test manually:

```bash
/usr/local/bin/service-resource-monitor.sh
/usr/local/bin/resource-threshold-monitor.sh
```

3. Ensure cron entry exists:

```bash
crontab -l
```

---

## ✅ Final Validation Checklist

Run these to confirm everything is working:

```bash
# Services exist and are enabled
systemctl list-unit-files | grep -E "(resource-test|webserver-sim|database-sim|nginx-limited)"

# Services are active
systemctl is-active resource-test.service webserver-sim.service database-sim.service

# Limits + accounting visible
systemctl show resource-test.service --property=CPUQuotaPerSecUSec,CPUUsageNSec,MemoryCurrent,MemoryMax,TasksCurrent,TasksMax,IOReadBytes,IOWriteBytes

# Logs are present
journalctl -u resource-test.service --since "30 minutes ago" --no-pager | tail

# Run dashboards
sudo /usr/local/bin/detailed-resource-monitor.sh
sudo /usr/local/bin/resource-dashboard.sh
```

Expected:

* services active
* MemoryCurrent/MemoryMax/Tasks fields populated
* CPU quota shown in `CPUQuotaPerSecUSec`
* dashboards show correct values

---
