# 🧪 Lab 15: Setting Up Centralized Logging with rsyslog

> **Track:** Red Hat Certified Specialist in Services Management & Automation (Exam Labs)  
> **Environment:** Two CentOS/RHEL-based systems (cloud lab environment)  
> **Prompt Format:** `-bash-4.2$`

---

## 🌍 Lab Topology

| Role | Hostname (example) | IP | Interface |
|------|---------------------|----|-----------|
| Central Log Server | `server01` | `10.0.2.41` | `eth0` |
| Log Forwarder Client | `client01` | `10.0.2.42` | `eth0` |

**Ports used**
- Syslog over **UDP 514**
- Syslog over **TCP 514**
- (Optional hardening) Syslog over **TLS TCP 6514**

---

## 🎯 Objective

This lab focuses on building a **centralized logging** setup using **rsyslog**, where one system acts as a **central log server** and another forwards logs as a **client**.

By the end of this lab, I was able to:

- Configure rsyslog server to receive logs over UDP/TCP
- Configure rsyslog client to forward logs to the server
- Store remote logs in organized per-host directories using templates
- Implement log rotation policies using `logrotate`
- Add automated cleanup via cron + script
- Verify log delivery end-to-end using generated test messages
- Troubleshoot realistic issues:
  - missing groups (`adm`)
  - missing tools (`netstat`, `telnet`, `nmap`, `semanage`)
  - SELinux considerations
- (Optional) Add TLS support for encrypted syslog transport
- Create monitoring scripts for server-side visibility

---

## ✅ Prerequisites

- Linux CLI basics
- Understanding of:
  - systemd services (`systemctl`)
  - networking (IP, ports)
  - firewall rules (`firewalld`)
- Comfort editing config files (`nano`/`vim`)
- Basic file ownership and permissions
- (Optional) SELinux basics

---

## 🗂️ Repository Structure (Lab Format)

```text
lab15-centralized-logging-with-rsyslog/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── server/
│   ├── configs/
│   │   ├── rsyslog.conf
│   │   └── rsyslog.conf.backup
│   ├── logrotate/
│   │   ├── remote-logs
│   │   └── custom-logs
│   ├── scripts/
│   │   ├── log-cleanup.sh
│   │   └── rsyslog-monitor.sh
│   └── tls/                       # Optional
│       ├── rsyslog.conf.tls-snippet.conf
│       ├── server-cert.pem
│       └── server-key.pem
└── client/
    ├── configs/
    │   ├── rsyslog.conf
    │   └── rsyslog.conf.backup
    ├── rsyslog.d/
    │   └── 50-remote.conf
    └── scripts/
        └── test-logging.sh
````

> Notes:
>
> * `server/` contains only server-side artifacts.
> * `client/` contains only client-side artifacts.
> * `output.txt` includes both server and client terminal output in the same file (labeled per section).

---

## ✅ What Was Done (High-Level Overview)

### ✅ Task 1: Configure rsyslog Server (10.0.2.41)

**1) Verify rsyslog is installed and running**

* Confirmed package is installed
* Verified `rsyslog` service is active

**2) Enable log reception**

* Enabled UDP input module (`imudp`) and TCP input module (`imtcp`)
* Bound to port `514` for both protocols
* Added a remote storage template:

  * Store logs under `/var/log/remote/<HOSTNAME>/<PROGRAM>.log`

**3) Remote log directory permissions**

* Created `/var/log/remote`
* Resolved a realistic group issue (`adm` group missing) by creating it
* Ensured directory is owned by `syslog:adm` and readable by policy

**4) Firewall (server)**

* Opened UDP/514 and TCP/514 using `firewall-cmd`
* Verified rules are present

**5) Verify listeners**

* Confirmed rsyslog is listening on both UDP/TCP 514
* Installed `net-tools` on minimal image when `netstat` was missing
* Verified using both `netstat` and `ss`

---

### ✅ Task 2: Configure rsyslog Client (10.0.2.42)

**1) Enable forwarding**

* Updated `/etc/rsyslog.conf` to forward all logs to server via TCP:

  * `*.* @@10.0.2.41:514`
    (`@@` = TCP, `@` = UDP)

**2) Create facility-based forwarding rules**

* Created `/etc/rsyslog.d/50-remote.conf` to forward specific facilities:

  * `auth/authpriv`, `mail`, `kern`
* Also kept local copies for local troubleshooting consistency

**3) Restart rsyslog client**

* Restarted service and verified it’s active

---

### ✅ Task 3: Log Rotation + Cleanup (Server)

**1) Remote log rotation**

* Created `/etc/logrotate.d/remote-logs` for:

  * `/var/log/remote/*/*.log`
* Daily rotation, compress, keep 30 rotations
* HUP rsyslog after rotation

**2) Local log rotation policy**

* Created `/etc/logrotate.d/custom-logs` for:

  * `/var/log/auth.log`, `/var/log/mail.log`, `/var/log/kern.log`

**3) Cleanup automation**

* Created `/usr/local/bin/log-cleanup.sh` to:

  * delete logs older than 30 days
  * remove empty directories
  * write cleanup activity log
* Scheduled with cron: `0 2 * * *`

---

### ✅ Task 4: Verify Remote Log Collection (End-to-End)

**1) Generate logs on the client**

* Used `logger` with multiple facilities and severity levels

**2) Validate logs on server**

* Confirmed server created a per-host directory: `/var/log/remote/client01/`
* Verified received logs in:

  * `logger.log`
  * `rsyslogd.log`
* Confirmed expected number of test messages:

  * **6 facilities × 6 priorities = 36 messages**

---

## 🔐 Optional Hardening: TLS Syslog (Reference Setup)

To demonstrate secure transport capability:

* Installed `rsyslog-gnutls`
* Generated a self-signed certificate for testing
* Added optional TLS listener configuration for TCP/6514

> In real environments, use a trusted CA, client auth, and restricted cipher suites.

---

## ✅ Verification & Validation Summary

* ✅ Server listening on UDP/TCP 514
* ✅ Firewall allows 514/udp and 514/tcp
* ✅ Client forwards logs successfully to server
* ✅ Remote logs stored in per-host directories
* ✅ logrotate configs created and tested
* ✅ cleanup script created + scheduled via cron
* ✅ SELinux checked and policy adjustments applied where needed
* ✅ Test messages received and counted correctly (36)

---

## 🧠 What I Learned

* How to build a centralized logging system using rsyslog templates and forwarding rules
* How to organize remote logs by hostname and program
* How to control logging transport using TCP vs UDP
* How to operationalize log growth management using logrotate + cleanup automation
* How to troubleshoot real issues around:

  * missing packages and tooling
  * service listeners
  * firewall and network validation
  * SELinux restrictions in enforcing mode

---

## 🔥 Why This Matters (Real-World Relevance)

Centralized logging is fundamental for:

* **Security monitoring** (audit trails, auth events, detection timelines)
* **Incident response** (single source of truth for multi-host events)
* **Operations troubleshooting** (service failures, kernel issues, app errors)
* **Compliance and retention** (log review + retention policies)
* **Scalability** (multiple clients feeding a central server)

---

## ✅ Result

✅ Central log server receiving logs from a client over TCP/UDP 514
✅ Logs stored cleanly under `/var/log/remote/<host>/<program>.log`
✅ Rotation + cleanup implemented to prevent disk exhaustion
✅ Optional TLS capability documented for secure transport scenarios

---
