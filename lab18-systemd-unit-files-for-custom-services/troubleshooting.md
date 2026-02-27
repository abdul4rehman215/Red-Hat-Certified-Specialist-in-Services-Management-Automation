# 🛠️ Troubleshooting Guide — Lab 18: Systemd Unit Files for Custom Services

> This document covers common issues seen when creating **custom systemd services** and **timers** on CentOS/RHEL 8/9.

---

## ✅ Issue 1: systemd does not detect the new unit file

### **Symptoms**
- `systemctl start custom-webserver.service` returns:
  - `Unit custom-webserver.service not found`
- `systemctl list-unit-files | grep custom-webserver` returns nothing

### **Likely Causes**
- Unit file is not in `/etc/systemd/system/`
- File name mismatch
- systemd cache not reloaded

### **Fix**
1) Confirm file exists:
```bash
ls -la /etc/systemd/system/custom-webserver.service
````

2. Reload systemd:

```bash
sudo systemctl daemon-reload
```

3. Re-check:

```bash
systemctl list-unit-files | grep custom-webserver
```

---

## ✅ Issue 2: Service fails to start due to wrong script path

### **Symptoms**

* `systemctl status <unit>` shows:

  * `ExecStart=/usr/bin/python3 /home/student/...` (path invalid)
  * `No such file or directory`

### **Likely Cause**

The unit file references a path that doesn’t exist for the current user/home directory.

### **Fix**

Update `ExecStart` to the correct absolute path:

```ini
ExecStart=/usr/bin/python3 /home/centos/systemd-lab/scripts/simple-webserver.py
```

Then reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart custom-webserver.service
```

---

## ✅ Issue 3: Permission denied when running script

### **Symptoms**

* `systemctl status <unit>` shows:

  * `Permission denied`
* Script fails if not executable

### **Likely Causes**

* Script missing execute permission
* Wrong ownership
* SELinux may be involved in hardened environments

### **Fix**

```bash
chmod +x ~/systemd-lab/scripts/<script-name>
ls -la ~/systemd-lab/scripts/<script-name>
```

Restart service:

```bash
sudo systemctl restart <unit>
```

---

## ✅ Issue 4: Web server is running but curl fails / port not listening

### **Symptoms**

* `curl http://localhost:8080/status` fails
* `ss -tlnp | grep :8080` shows no listener

### **Likely Causes**

* Service is not active
* Port is already in use
* Wrong PORT inside script or firewall limitations (for non-local tests)

### **Fix**

1. Confirm service state:

```bash
systemctl status custom-webserver.service -l
```

2. Check port usage:

```bash
sudo ss -tlnp | grep :8080
```

3. If port conflict exists, either:

* stop the conflicting service, or
* change PORT in `simple-webserver.py` and restart service

---

## ✅ Issue 5: Restart behavior not working as expected

### **Symptoms**

* Killing the process stops the service permanently
* service does not restart automatically

### **Likely Cause**

Restart policy not set, or wrong exit condition:

* Missing `Restart=...`
* Incorrect unit configuration

### **Fix**

In unit file:

```ini
Restart=on-failure
RestartSec=5
```

Reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart custom-webserver.service
```

Test:

```bash
WEB_PID=$(systemctl show --property MainPID custom-webserver.service | cut -d= -f2)
sudo kill -9 $WEB_PID
sleep 5
systemctl status custom-webserver.service
```

---

## ✅ Issue 6: Timer enabled but service never runs

### **Symptoms**

* `systemctl status system-cleanup.timer` shows active
* No logs appear for the cleanup service
* Timer doesn’t trigger

### **Likely Causes**

* Timer unit not linked to correct service
* Service file name mismatch
* Timer not started (`enable` alone is not enough until reboot)

### **Fix**

1. Confirm timer triggers correct service:

```bash
systemctl status system-cleanup.timer
systemctl list-timers --all | grep system-cleanup
```

2. Start timer immediately:

```bash
sudo systemctl start system-cleanup.timer
```

3. Trigger service manually (to confirm it works):

```bash
sudo systemctl start system-cleanup.service
sudo journalctl -u system-cleanup.service --lines=30
```

---

## ✅ Issue 7: Timer/service naming mismatch (hyphen issue)

### **Symptoms**

Command returns:

* `No such file or directory`

Example seen in lab:

```bash
ls -la /etc/systemd/system/systemcleanup.*
```

### **Cause**

Actual file is:

* `system-cleanup.*` (with hyphen)

### **Fix**

Use correct filename:

```bash
ls -la /etc/systemd/system/system-cleanup.*
```

---

## ✅ Issue 8: Log monitor is active but file `/var/log/custom-monitor.log` is missing

### **Symptoms**

* Service active
* Log file not created

### **Likely Causes**

* Script cannot write to `/var/log` (permissions)
* Script uses `sudo tee` but service is running as non-root
* Script path or execution failed early

### **Fix**

1. Confirm service user:

```bash
systemctl cat log-monitor.service
```

2. Confirm it is running as root (as designed in lab):

```ini
User=root
Group=root
```

3. Inspect logs:

```bash
journalctl -u log-monitor.service --since "10 minutes ago" -l
```

4. Confirm file permissions:

```bash
sudo ls -la /var/log/custom-monitor.log
```

---

## ✅ Final Validation Checklist

Run the following to confirm everything is working:

```bash
systemctl is-active custom-webserver.service
curl -s http://localhost:8080/status | head

systemctl is-active log-monitor.service
sudo tail -5 /var/log/custom-monitor.log

systemctl is-active system-cleanup.timer
systemctl list-timers system-cleanup.timer
sudo journalctl -u system-cleanup.service --since "30 minutes ago"
```

Expected:

* web service responds
* monitor log updates
* timer is active and triggers the cleanup service

---
