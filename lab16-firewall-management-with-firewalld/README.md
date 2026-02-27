# 🧪 Lab 16: Firewall Management with firewalld (Ansible Automation)

> **Track:** Red Hat Certified Specialist in Services Management & Automation (Exam Labs)  
> **Environment:** CentOS/RHEL-based Control Node + 2 Managed Nodes (Cloud lab environment)  
> **Interface:** `eth0`  
> **Prompt Format:** `-bash-4.2$`

---

## 🖥️ Lab Nodes (as used in this run)

| Role | Hostname | IP | Notes |
|------|----------|----|------|
| Control Node | `control` | `192.168.1.5` | Ansible installed |
| Web Server | `web1` | `192.168.1.10` | Managed node |
| DB Server | `db1` | `192.168.1.11` | Managed node |

✅ Inventory uses: `ansible_user=student` and SSH key `~/.ssh/lab_key` (as in lab text).  
✅ We created `~/.ssh/lab_key` because it didn’t exist initially (required for Ansible connectivity here).

---

## 🎯 Objective

This lab demonstrates **enterprise firewall automation** using **Ansible + firewalld** across multiple managed nodes.

By completing this lab, I was able to:

- Understand firewalld zones and zone-based architecture
- Automate zone/service/port configuration across hosts using Ansible
- Create and apply **rich rules** (source restrictions, drops, port ranges, port-forwarding)
- Implement security policies for:
  - Web servers (HTTP/HTTPS + controlled access)
  - Database servers (MySQL restricted to web server IPs + admin SSH)
- Enable firewall logging and integrate with rsyslog + logrotate
- Build automated testing and validation framework:
  - Ansible validation playbooks
  - connectivity and performance scripts
  - generated reports pulled from managed nodes
- Troubleshoot common issues and verify rule effectiveness

---

## ✅ Prerequisites

- Linux CLI + networking basics (ports/protocols/subnets)
- SSH connectivity and key usage
- Ansible fundamentals (inventory, playbooks, YAML)
- Understanding systemd service management
- firewalld basics (zones, services, rich rules)

---

## 🧰 Lab Environment

- Control Node: CentOS/RHEL 8+ with Ansible pre-installed
- Managed Nodes: Web server (`web1`), DB server (`db1`)
- Pre-installed: firewalld, base utilities
- Secure lab network: `192.168.1.0/24`

---

## 🗂️ Repository Structure (Lab Format)

```text
lab16-firewall-management-with-firewalld/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── inventory
├── playbooks/
│   ├── firewall-config.yml
│   ├── advanced-firewall-rules.yml
│   ├── web-security-rules.yml
│   ├── database-security-rules.yml
│   ├── firewall-logging.yml
│   ├── firewall-testing.yml
│   └── advanced-firewall-tests.yml
├── scripts/
│   ├── test-connectivity.sh
│   └── firewall-performance-test.sh
└── reports/
    ├── firewall-report-web1.txt
    └── firewall-report-db1.txt
````

---

## ✅ What Was Done (High-Level Overview)

### ✅ Task 1: Zones and Services with Ansible

#### 1) Control node validation

* Verified Ansible installation: `ansible --version`

#### 2) Inventory + SSH key setup

* Created inventory for `webservers` and `dbservers`
* Ensured SSH key exists (`~/.ssh/lab_key`)
* Verified connectivity: `ansible all -m ping -i inventory`

#### 3) Apply base firewall configuration

Using `playbooks/firewall-config.yml`:

* **Web (`web1`)**

  * Ensure firewalld installed and enabled
  * Use default zone: `public`
  * Enable services: `http`, `https`, `ssh`
  * Enable ports: `8080/tcp`, `8443/tcp`
  * Create zone `internal-web` and allow: `ssh`, `mysql`

* **DB (`db1`)**

  * Ensure firewalld installed and enabled
  * Create zone `database`
  * Enable services: `ssh`, `mysql`
  * Add trusted sources:

    * `192.168.1.0/24`
    * `10.0.0.0/8`
  * Assign interface `eth0` → zone `database`

#### 4) Apply advanced rules

Using `playbooks/advanced-firewall-rules.yml`:

* SSH allow rule from `192.168.1.0/24` (web only)
* Block specific IP: `10.0.0.100` (all)
* Allow TCP port range `9000-9010` (web only)
* Port forward `80 → 8080` (web only)

---

### ✅ Task 2: Security Policy Rules

#### Web security rules (`web-security-rules.yml`)

* Create zone `web-dmz`
* Allow only `http` and `https` in `web-dmz`
* Allow HTTP/HTTPS only from:

  * `192.168.1.0/24`
  * `172.16.0.0/16`
* Block suspicious IP range:

  * `10.0.0.0/8` (example blocked range)
* Apply SSH rate limit rule:

  * `limit value="3/m"`

#### Database security rules (`database-security-rules.yml`)

* Create zone `secure-db`
* Allow MySQL only from the web server IP:

  * `192.168.1.10`
* Allow SSH only from admin network:

  * `192.168.1.0/24`
* Drop all other MySQL in public zone
* Allow backup port:

  * `3307/tcp` from `192.168.1.0/24`

---

### ✅ Task 2.2: Logging and Monitoring (`firewall-logging.yml`)

* Enable firewalld logging:

  * `LogDenied=all` in `/etc/firewalld/firewalld.conf`
* Add rsyslog block to capture firewall logs into:

  * `/var/log/firewall-rejected.log`
  * `/var/log/firewall-accepted.log`
* Create logrotate policy for these firewall logs
* Deploy monitoring script:

  * `/usr/local/bin/firewall-monitor.sh`
* Handlers restart services:

  * `firewalld`
  * `rsyslog`

---

### ✅ Task 3: Testing and Validation

#### 1) Automated firewall inspection (`firewall-testing.yml`)

* Verified:

  * firewalld active state
  * zones
  * default zone
  * services and ports in public zone
  * rich rules list

#### 2) Network connectivity script (`scripts/test-connectivity.sh`)

* Tested:

  * web ports 80/443/8080/22
  * db ports 3306/22
  * blocked port 9999

#### 3) Service validation via Ansible

* Verified web service responds:

  * `curl -I http://localhost:80` (web1)
* DB service name mismatch fixed:

  * `mysqld` not found → checked `mariadb` instead

#### 4) Advanced validation + reports (`advanced-firewall-tests.yml`)

* Asserted port 9999 blocked using `wait_for` + `assert`
* Verified interface zone assignment:

  * web1: public
  * db1: database
* Generated reports on each node and fetched into `reports/`

#### 5) Performance testing script (`firewall-performance-test.sh`)

* Measured:

  * time to list rules
  * HTTP request time
  * SSH connection time
  * firewall reload time
* Observed warning in logs:

  * `AllowZoneDrifting is enabled` (security consideration)

---

## ✅ Verification Summary (Results)

* ✅ Ansible ping success to web1/db1
* ✅ Zones created successfully (public, internal-web, database, web-dmz, secure-db)
* ✅ Services/ports applied as expected per role
* ✅ Rich rules applied (drop, allow, port range, port forward, rate limit)
* ✅ Firewall logging integrated with rsyslog + logrotate
* ✅ Blocked port tests pass (9999 blocked)
* ✅ Reports generated and fetched locally

---

## 🧠 What I Learned

* How to automate firewalld consistently across systems using Ansible
* How to implement zone-based security policies (least privilege)
* How to use rich rules for advanced traffic control
* How to validate firewall posture using automated testing + reports
* How to integrate firewall logs for monitoring and auditing

---

## 🔥 Why This Matters (Real-World Relevance)

Firewall automation is critical in enterprise environments to:

* reduce configuration drift
* enforce repeatable security baselines
* support compliance and audits
* speed up deployments and incident response
* ensure consistent network segmentation (web tier vs database tier)

---

## ✅ Result

✅ Enterprise-grade firewall rules automated across multiple nodes
✅ Logging + monitoring + rotation applied
✅ Testing framework confirmed rules are effective
✅ Reports created for auditing and troubleshooting

---

## 📌 Files Created in This Lab

* `inventory`
* `playbooks/` (all playbooks listed above)
* `scripts/test-connectivity.sh`
* `scripts/firewall-performance-test.sh`
* `reports/firewall-report-web1.txt`
* `reports/firewall-report-db1.txt`

---
