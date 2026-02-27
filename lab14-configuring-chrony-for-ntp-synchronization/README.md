# 🧪 Lab 14: Configuring Chrony for NTP Synchronization

> **Track:** Red Hat Certified Specialist in Services Management & Automation (Exam Labs)  
> **Environment:** CentOS Linux 9 (Cloud lab environment)  
> **User:** `root`  
> **Prompt Format:** `-bash-4.2$`

---

## 🎯 Objective

This lab focuses on installing, configuring, and validating **Chrony** for accurate **NTP time synchronization** in an enterprise Linux environment.

By completing this lab, I was able to:

- Install Chrony and verify package/version details
- Configure Chrony to sync against multiple **redundant NTP sources**
- Start and enable Chrony (`chronyd`) with systemd
- Validate synchronization using:
  - `chrony sources`, `chrony sourcestats`, `chrony tracking`, `chrony activity`
- Force immediate correction using `chrony makestep`
- Align system time with hardware clock (where supported)
- Configure Chrony as an **NTP server** for internal networks
- Configure firewall (`firewalld`) to allow NTP traffic (UDP/123)
- Build a monitoring script for operational visibility (`chrony-monitor.sh`)
- Troubleshoot realistic issues (missing `netstat`, cloud RTC limitations)

---

## ✅ Prerequisites

- Linux CLI basics
- Service management with `systemctl`
- Comfort editing config files (`nano`/`vi`)
- Basic networking + firewall awareness
- Root access

---

## 🧰 Lab Environment

- **OS:** CentOS Linux 9  
- **Time Service:** `chronyd` (Chrony)  
- **Firewall:** `firewalld` (enabled/running)  
- **NTP Port:** UDP `123`

---

## 🗂️ Repository Structure (Lab Format)

```text
lab14-configuring-chrony-for-ntp-synchronization/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    └── chrony-monitor.sh
````

> Notes:
>
> * `commands.sh` contains **only commands executed**, sequential, copy-paste ready.
> * `output.txt` contains **all outputs**, including sample watch/journal output.
> * Scripts used/created are placed under `scripts/`.

---

## ✅ What Was Done (High-Level Overview)

### ✅ Task 1: Install Chrony and Review Defaults

* Updated package metadata and ensured system packages are current
* Installed Chrony (`chrony` package) and verified:

  * RPM installed
  * version output (`chronyd --version`)
* Reviewed the default Chrony configuration in `/etc/chrony.conf`
* Created a safe rollback copy: `/etc/chrony.conf.backup`
* Confirmed service state (installed but initially inactive)

### ✅ Task 2: Configure Chrony with Redundant Time Sources

Edited `/etc/chrony.conf` to include:

* Public pool servers (0–3.pool.ntp.org)
* Additional reliable sources:

  * `time.nist.gov`
  * `time.google.com`
  * `time.cloudflare.com`
* Client tuning controls:

  * `minpoll`, `maxpoll`
  * `maxdistance`
  * `makestep`
* Client behavior / stability:

  * drift file, RTC sync
  * `logchange`, `dumponexit`, `dumpdir`
  * `maxupdateskew`
  * `hwtimestamp *`

### ✅ Task 3: Start/Enable Service and Validate Synchronization

* Started and enabled `chronyd`
* Verified synchronization health using:

  * `chrony sources -v` (current best source shown as `^*`)
  * `chrony sourcestats -v` (quality/offset statistics)
  * `chrony tracking` (stratum, offsets, frequency/skew)
  * `chrony activity` (sources online/offline)
* Forced immediate step correction when needed:

  * `sudo chrony makestep`
* Verified system time and time zone:

  * `date`, `timedatectl status`

### ✅ Task 4: Firewall Configuration for NTP

* Verified firewall service is active
* Allowed NTP traffic through firewall:

  * `firewall-cmd --add-service=ntp --permanent`
  * `firewall-cmd --reload`
* Confirmed `ntp` service is allowed

### ✅ Task 5: Monitoring and Operational Script

Created a reusable monitoring script:

* `/usr/local/bin/chrony-monitor.sh`

It prints:

* time sources
* tracking status
* stats
* system vs hardware clock
* service status

This is useful for quick troubleshooting and routine checks.

### ✅ Task 6: Configure Chrony as an NTP Server (Client + Server)

* Enabled client allowances for internal networks (`allow ...`)
* Configured “local stratum” behavior for controlled environments
* Restarted Chrony service
* Verified server is listening on UDP/123 using `netstat`

  * Installed `net-tools` when `netstat` was missing

---

## ✅ Verification & Validation Summary

This lab confirmed:

* ✅ Chrony installed (`rpm -qa | grep chrony`)
* ✅ Chronyd running and enabled at boot (`systemctl status/is-enabled chronyd`)
* ✅ Synchronization active (sources show `^*` and `System clock synchronized: yes`)
* ✅ Multiple NTP sources online (redundancy)
* ✅ Firewall configured to allow NTP (service `ntp` in `firewalld`)
* ✅ Chronyd listening on UDP 123 (server readiness)
* ✅ Reboot persistence validated (Chrony running after reboot)

---

## 🧠 What I Learned

* How to configure Chrony as both **NTP client** and **internal time server**
* How to validate synchronization health using Chrony tools (sources/tracking/stats)
* How polling intervals and max distance affect stability and reliability
* How to operationalize NTP monitoring with a shell script
* Common troubleshooting patterns:

  * missing utilities (install `net-tools`)
  * RTC limitations on some cloud VMs

---

## 🔥 Why This Matters (Real-World Relevance)

Accurate time synchronization is critical for:

* **Security:** Kerberos, TLS certificates, token-based auth, and MFA flows depend on valid time
* **Logging & Incident Response:** accurate timestamps are required to correlate events across systems
* **Compliance:** many standards require synchronized clocks
* **Distributed Systems:** clustered services, databases, and orchestration rely on consistent time

Chrony is commonly preferred in modern Linux environments due to accuracy and performance.

---

## ✅ Result

✅ Chrony installed and configured with multiple reliable sources
✅ NTP synchronization verified via Chrony tooling
✅ Firewall opened for NTP server capability
✅ Monitoring script created for ongoing operations
✅ Service persistence verified via reboot

---
