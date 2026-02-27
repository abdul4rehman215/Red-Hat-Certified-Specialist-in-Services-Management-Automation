# 🧪 Lab 18: Systemd Unit Files for Custom Services

In this lab, I built **custom systemd services** from scratch and managed them like production workloads.  
I created:

- ✅ A **Python web server service** (`custom-webserver.service`)
- ✅ A **log monitoring service** with continuous loop + journald logging (`log-monitor.service`)
- ✅ A **timer-based cleanup job** using `oneshot` + `systemd timers` (`system-cleanup.service` + `.timer`)
- ✅ A full **test harness script** to validate status, logs, timers, and boot enablement

> **Note:** All work was performed in a **cloud lab environment** on **CentOS/RHEL 8/9**, using a `centos` user with sudo access.

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand the structure and core sections of systemd unit files (`[Unit]`, `[Service]`, `[Install]`, `[Timer]`)
- Create custom services with correct startup behavior and dependencies
- Enable, start, stop, restart, and monitor services using `systemctl`
- Build timer-based automation using `.timer` units
- Validate service resilience and restart-on-failure behavior
- Troubleshoot common unit file and runtime issues
- Apply service hardening settings (security options inside unit files)

---

## ✅ Prerequisites

- Linux CLI familiarity
- Basic shell scripting
- Understanding of file permissions and ownership
- Comfort using text editors (`nano`)
- Familiarity with system administration tasks and sudo usage
- Basic systemd knowledge from earlier labs

---

## 🧰 Lab Environment

| Component | Details |
|---|---|
| OS | CentOS/RHEL 8/9 |
| Shell | `-bash-4.2$` |
| User | `centos` (sudo access) |
| systemd | v245+ |
| Network | Available (local testing on port `8080`) |

---

## 🗂️ Repository Structure

```text
lab18-systemd-unit-files-for-custom-services/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── scripts/
│   ├── simple-webserver.py
│   ├── log-monitor.sh
│   ├── system-cleanup.sh
│   └── test-services.sh
└── unit-files/
    ├── custom-webserver.service
    ├── log-monitor.service
    ├── system-cleanup.service
    └── system-cleanup.timer
````

> The lab also used a working directory: `~/systemd-lab/` containing `scripts/` and `unit-files/` before deploying unit files into `/etc/systemd/system/`.

---

## 🔎 What I Built (High-Level)

### ✅ 1) Learned from existing unit structure

* Reviewed an existing unit (`sshd.service`) to understand real production structure:

  * Dependencies (`After=network.target`)
  * Restart behavior (`Restart=on-failure`)
  * Install target (`WantedBy=multi-user.target`)
* Confirmed system unit paths used by systemd (`UnitPath`).

---

### ✅ 2) Built a simple custom service (Python web server)

**Service goal:** Run a lightweight server on port `8080` with:

* `/` → static landing page
* `/status` → live status page with time + PID

**Key systemd features used:**

* `Type=simple`
* Restart on failure (`Restart=on-failure`)
* Dedicated restricted user/group (`nobody`)
* Service hardening options:

  * `NoNewPrivileges=true`
  * `PrivateTmp=true`
  * `ProtectSystem=strict`
  * `ProtectHome=true`
  * `ReadWritePaths=/tmp`

---

### ✅ 3) Built a long-running log monitor service (dependency example)

**Service goal:** Every 30 seconds, write operational metrics into:

* `/var/log/custom-monitor.log`

Includes:

* Monitoring directory file count (`/tmp/monitor`)
* System load average (from `uptime`)
* Clean shutdown handling using `trap` + PID file

**Key systemd features used:**

* Explicit dependencies (`After=` + `Requires=multi-user.target`)
* PID file usage (`PIDFile=/tmp/log-monitor.pid`)
* Always restart (`Restart=always`)
* Journald identifier (`SyslogIdentifier=log-monitor`)

---

### ✅ 4) Built a timer-based cleanup automation (systemd timer)

**Service goal:** Periodically clean up `.tmp` files older than 1 hour from test directories, then log:

* disk usage
* memory usage
* cleanup actions performed

**Timer behavior:**

* Starts after boot delay
* Repeats every 15 minutes
* Persistent scheduling (`Persistent=true`)

**Key unit type used:**

* `Type=oneshot` for the cleanup service (run-and-exit)

---

## ⚙️ Service Deployment & Management (Overview)

After creating the unit files and scripts:

* Copied unit files into `/etc/systemd/system/`
* Corrected permissions (`chmod 644`)
* Reloaded systemd (`daemon-reload`)
* Enabled + started:

  * `custom-webserver.service`
  * `log-monitor.service`
  * `system-cleanup.timer`
* Verified with:

  * `systemctl status`
  * `journalctl -u <unit>`
  * `systemctl list-timers`

---

## ✅ Validation (What I Verified)

### Web service

* Confirmed HTTP responses on:

  * `http://localhost:8080/`
  * `http://localhost:8080/status`
* Verified port open using:

  * `netstat` and `ss`

### Resilience testing

* Killed the web server PID and confirmed systemd restarted it with a new PID.

### Log monitor behavior

* Confirmed `/var/log/custom-monitor.log` updates every 30 seconds.
* Created files in `/tmp/monitor` to confirm file-count changes were detected and logged.

### Timer-based job

* Verified timer schedule using `systemctl list-timers`
* Triggered cleanup manually and confirmed:

  * journald entries
  * `/var/log/system-cleanup.log` updated

### Boot enablement simulation

* Verified units are enabled.
* Stopped services and started relevant targets to confirm they return to active state.

### Comprehensive testing

* Executed `scripts/test-services.sh` to generate a summarized health report.

---

## 🔐 Security Notes (Why it matters)

Systemd unit files are not just “start scripts”—they are a critical part of **service hardening** and **operational control**.

This lab emphasized:

* running services as non-root where possible
* limiting filesystem access via `ProtectSystem` + `ReadWritePaths`
* preventing privilege escalation with `NoNewPrivileges`
* isolating temporary directories with `PrivateTmp`
* structuring reliable service restarts using systemd, not ad-hoc loops

---

## ✅ Conclusion

This lab gave me hands-on practice writing production-style systemd units for:

* long-running services
* scheduled automation via timers
* dependency-aware startup
* restart resilience and journald observability

These are core skills for enterprise Linux administration and directly aligned with service management and automation objectives.

---
