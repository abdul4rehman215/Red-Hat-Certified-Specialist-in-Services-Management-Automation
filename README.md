# 🛠️ Red Hat Certified Specialist in Services Management & Automation – Enterprise Linux Services Engineering Portfolio

> Enterprise Services Automation • Infrastructure as Code • Secure Operations • Reliability Engineering

### A complete 20-lab hands-on enterprise engineering program focused on automating, securing, validating, and governing production-grade Linux services — from Ansible-driven infrastructure deployment to firewall policy-as-code, SELinux enforcement, systemd service engineering, and resource-level performance control.

### This portfolio simulates real-world DevOps, Infrastructure Automation, and Linux Platform Engineering workflows.

<div align="center">

<!-- ===================== PLATFORM & STACK ===================== -->
![RHEL](https://img.shields.io/badge/OS%20%7C%20Red%20Hat-Enterprise%20Linux%208%20%7C%209-EE0000?style=for-the-badge&logo=redhat&logoColor=EE0000)
![CentOS](https://img.shields.io/badge/CentOS-Stream-purple?style=for-the-badge&logo=centos)
![OS](https://img.shields.io/badge/OS-Ubuntu%2020.04%2F22.04-orange?style=for-the-badge&logo=ubuntu)
![Linux](https://img.shields.io/badge/Linux-Enterprise%20Administration-black?style=for-the-badge&logo=linux)
![Ansible](https://img.shields.io/badge/Ansible-Automation%20%7C%20IaC-EE0000?style=for-the-badge&logo=ansible)
![YAML](https://img.shields.io/badge/YAML-Playbooks%20%7C%20Automation%20Design-0A0FFF?style=for-the-badge&logo=yaml)
![Bash](https://img.shields.io/badge/Bash-Scripting%20%7C%20Ops%20Tooling-4EAA25?style=for-the-badge&logo=gnu-bash)
![Python](https://img.shields.io/badge/Python-Inventory%20%7C%20Automation%20Helpers-3776AB?style=for-the-badge&logo=python)

<!-- ===================== SPECIALIZATION ===================== -->
![Focus](https://img.shields.io/badge/Focus-Enterprise%20Services%20Management-222222?style=for-the-badge)
![ConfigMgmt](https://img.shields.io/badge/Config%20Management-Idempotent%20Deployments-6E40C9?style=for-the-badge)
![Security](https://img.shields.io/badge/Security-Vault%20%7C%20SELinux%20%7C%20TLS-2E7D32?style=for-the-badge&logo=letsencrypt)
![Systemd](https://img.shields.io/badge/Systemd-Services%20%7C%20Timers%20%7C%20Reliability-10A0CC?style=for-the-badge&logo=systemd)
![Networking](https://img.shields.io/badge/Network%20Services-DNS%20%7C%20DHCP%20%7C%20Mail%20%7C%20Proxy-3949AB?style=for-the-badge)
![Logging](https://img.shields.io/badge/Observability-rsyslog%20%7C%20logrotate%20%7C%20Monitoring-FF6F00?style=for-the-badge)

<!-- ===================== SCOPE & STATUS ===================== -->
![Labs](https://img.shields.io/badge/Labs-20%20Hands--On%20Enterprise%20Labs-brightgreen?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)
![Level](https://img.shields.io/badge/Level-Intermediate%20%E2%86%92%20Advanced-blueviolet?style=for-the-badge)

<!-- ===================== REPO METADATA ===================== -->
![RepoSize](https://img.shields.io/github/repo-size/abdul4rehman215/Red-Hat-Certified-Specialist-in-Services-Management-Automation?style=for-the-badge)
![Stars](https://img.shields.io/github/stars/abdul4rehman215/Red-Hat-Certified-Specialist-in-Services-Management-Automation?style=for-the-badge)
![Forks](https://img.shields.io/github/forks/abdul4rehman215/Red-Hat-Certified-Specialist-in-Services-Management-Automation?style=for-the-badge)
![LastCommit](https://img.shields.io/github/last-commit/abdul4rehman215/Red-Hat-Certified-Specialist-in-Services-Management-Automation?style=for-the-badge)

</div>

---

## 🎯 Executive Summary

This repository demonstrates practical capability across:

- ✅ Enterprise Linux Services Deployment (DNS, DHCP, Proxy, Mail, NFS, SMB)
- ✅ Infrastructure as Code with Ansible (Playbooks, Roles, Vault, Templates)
- ✅ Secure Service Hardening (TLS, SELinux, RBAC, Policy Enforcement)
- ✅ Operational Engineering (Backups, Logging Pipelines, Monitoring Scripts)
- ✅ Firewall & Network Policy Automation (Zones, Rich Rules, Logging)
- ✅ Performance & Resource Governance (tuned profiles, systemd cgroups)

This is execution-driven infrastructure engineering — not theoretical configuration notes.

Each lab includes structured automation, command evidence, validation outputs, and troubleshooting documentation aligned with real production workflows.

---

## 📌 About This Repository

A structured 20-lab Enterprise Linux Services Automation program simulating real production infrastructure responsibilities:

- Multi-host configuration management with Ansible
- Secure deployment of core network services
- Database hardening and automated backup/restore pipelines
- Time synchronization for audit integrity
- Centralized logging architecture and maintenance
- Policy-as-code firewall automation with verification reporting
- SELinux troubleshooting while maintaining enforcing mode
- Engineering resilient systemd services and timers
- Workload-specific performance tuning
- Service-level CPU, memory, and I/O resource control

All labs are executed in controlled RHEL/CentOS-based environments and emphasize validation, repeatability, and operational reliability.

---

## 👤 Who This Repository Is For

- **Linux System Administrators** (RHCSA/RHCE progression + Specialist track)
- **DevOps / Infrastructure Automation Engineers** (Ansible + enterprise services)
- **Platform / SRE-minded engineers** (reliability, verification, governance)
- **Network & Systems Engineers** managing production services
- Anyone building **portfolio-grade evidence** in Linux automation and services management

---

## 🗂️ Labs Index (1–20)

> Click any lab title to jump directly to its folder.

---

# 🗂 Lab Architecture Overview


## 🔹 Section 1 — Ansible Foundations & Secure Automation (Labs 01–05)

<div align="left">

![Category](https://img.shields.io/badge/Category-Automation%20Foundations-darkred?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-Infrastructure%20as%20Code-blue?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-Secure%20Configuration%20Management-2E7D32?style=for-the-badge)

</div>

| Lab | Title                                                                                            | Focus Area                                   |
| --: | ------------------------------------------------------------------------------------------------ | -------------------------------------------- |
|  01 | [Automation Using Ansible Basics](./lab01-automation-using-ansible-basics)                       | Ad-hoc commands & Playbooks                  |
|  02 | [Creating & Managing Ansible Inventories](./lab02-creating-and-managing-ansible-inventories)     | Static + Dynamic Inventory                   |
|  03 | [Ansible Roles & Templates](./lab03-ansible-roles-and-templates)                                 | Modular automation (roles, handlers, Jinja2) |
|  04 | [Secure Sensitive Data with Ansible Vault](./lab04-secure-sensitive-data-with-ansible-vault)     | Encryption & secret lifecycle                |
|  05 | [Automating Apache HTTP Server Installation](./lab05-automating-apache-http-server-installation) | Production-ready web automation              |

### 🧠 Skills Demonstrated

* IaC fundamentals + idempotent playbook design
* Enterprise inventory modeling (group_vars/host_vars, hybrid inventory)
* Role-based automation architecture (handlers, templates, OS-aware vars)
* Secure automation with Vault (Vault IDs, permission controls)
* Full web infra automation (SSL/TLS, headers, redirects, testing)

---

## 🌐 Section 2 — Network Services Automation (Labs 06–11)

<div align="left">

![Category](https://img.shields.io/badge/Category-Enterprise%20Network%20Services-3949AB?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-Service%20Deployment%20%26%20Validation-6A1B9A?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-Access%20Control%20%26%20Hardening-2E7D32?style=for-the-badge)

</div>

| Lab | Title                                                                                  | Focus Area                       |
| --: | -------------------------------------------------------------------------------------- | -------------------------------- |
|  06 | [Automating Squid Proxy Installation](./lab06-automating-squid-proxy-installation)     | Proxy automation & ACL security  |
|  07 | [Configuring DNS with BIND](./lab07-configuring-dns-with-bind)                         | DNS zones, records, hardening    |
|  08 | [Automating DHCP Server Configuration](./lab08-automating-dhcp-server-configuration)   | IP scope automation + testing    |
|  09 | [Configuring Postfix for Email Sending](./lab09-configuring-postfix-for-email-sending) | Mail relay + TLS + auth          |
|  10 | [Configuring NFSv4 File Sharing](./lab10-configuring-nfsv4-file-sharing)               | Linux file sharing + reliability |
|  11 | [Setting Up Samba (SMB) File Sharing](./lab11-setting-up-samba-smb-file-sharing)       | Cross-platform sharing + SELinux |

### 🧠 Skills Demonstrated

* Secure service deployment & configuration
* Ansible automation for network services
* Validation tooling: dig, tcpdump, openssl s_client, smbclient, exportfs
* Access control design: ACLs, auth, protocol version hardening
* Production troubleshooting and structured verification

---

## 🏗️ Section 3 — Core Infrastructure Services (Labs 12–16)

<div align="left">

![Category](https://img.shields.io/badge/Category-Core%20Infrastructure%20Services-455A64?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-Operations%20Engineering-00897B?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-Policy%20as%20Code%20%26%20Observability-FF6F00?style=for-the-badge)

</div>

| Lab | Title                                                                                            | Focus Area                                       |
| --: | ------------------------------------------------------------------------------------------------ | ------------------------------------------------ |
|  12 | [MariaDB Installation & Configuration](./lab12-mariadb-installation-and-configuration)           | Secure DB setup + RBAC validation                |
|  13 | [Automating MariaDB Backup & Restore](./lab13-automating-mariadb-backup-and-restore)             | IaC backup/restore + retention + integrity tests |
|  14 | [Configuring Chrony for NTP Synchronization](./lab14-configuring-chrony-for-ntp-synchronization) | Reliable time sync for infra correlation         |
|  15 | [Centralized Logging with rsyslog](./lab15-centralized-logging-with-rsyslog)                     | Log forwarding + templates + rotation            |
|  16 | [Firewall Management with firewalld](./lab16-firewall-management-with-firewalld)                 | Policy-as-code + zones + rich rules + logging    |

### 🧠 Skills Demonstrated

* Database hardening + role-based privilege design
* Backup/restore automation with scheduling + verification
* Time-sync engineering (multi-source, validation tooling)
* Centralized logging pipeline: ingest → store → rotate → maintain
* Firewall automation: zones, services, ports, rich rules, deny logging, reporting

### 🎯 High-Value Evidence Artifacts

* Ansible playbooks/roles + Jinja2 templates
* scripts: monitoring, validation, cleanup, dashboards
* reports/ outputs demonstrating verification and compliance-style evidence

---

## 🛡️ Section 4 — Services Management, Tuning & Governance (Labs 17–20)

<div align="left">

![Category](https://img.shields.io/badge/Category-Platform%20Engineering-1E88E5?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-Reliability%20%26%20Service%20Engineering-6A1B9A?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-Performance%20%26%20Resource%20Governance-2E7D32?style=for-the-badge)

</div>

| Lab | Title                                                                                          | Focus Area                                  |
| --: | ---------------------------------------------------------------------------------------------- | ------------------------------------------- |
|  17 | [SELinux Troubleshooting & Service Access](./lab17-selinux-troubleshooting-and-service-access) | AVC denial investigation + safe remediation |
|  18 | [Systemd Unit Files for Custom Services](./lab18-systemd-unit-files-for-custom-services)       | Custom services + timers + hardening        |
|  19 | [Automating System Tuning with tuned](./lab19-automating-system-tuning-with-tuned)             | Tuned profiles + automation + rollback      |
|  20 | [Configuring Resource Limits for Services](./lab20-configuring-resource-limits-for-services)   | systemd cgroups + monitoring dashboards     |

### 🧠 Skills Demonstrated

* SELinux investigations (ausearch, audit2why, sealert) + correct fixes (contexts/booleans)
* systemd engineering (dependencies, restart policies, timers, security hardening options)
* Performance tuning with tuned (custom profiles, verification, rollback)
* Resource governance using systemd cgroups (CPUQuota, MemoryMax, TasksMax, IO controls)
* Automation with Ansible + templates + monitoring/alert scripts

---

## 🧰 Tools & Technologies Used Across Repository

<details>
<summary><b>📌 Click to expand</b></summary>

### 🖥 Operating Systems / Platform
- **RHEL / CentOS 8/9** (enterprise services lab environment)
- **Ubuntu 20.04** (selected cross-compatibility automation scenarios)

### ⚙️ Automation & Infrastructure as Code (IaC)
- **Ansible**: playbooks, roles, inventories, handlers, conditionals, loops, fetch
- **Ansible Vault**: AES256 encryption, Vault IDs, encrypted variable files
- **Jinja2**: configuration templating and environment-based configs
- **YAML**: playbook + inventory + variable design
- **SSH**: key-based automation and multi-host orchestration

### 🌐 Enterprise Network & Infrastructure Services
- **Web Services**: Apache HTTP Server (**httpd**), `mod_ssl`, `mod_headers`
- **Proxy**: **Squid** (ACLs, caching policies, access control)
- **DNS**: **BIND / named** (forward + reverse zones, record management, validation)
- **DHCP**: **dhcpd** (scopes, leases, reservations, validation)
- **Mail**: **Postfix** (relay config, TLS encryption, SASL auth, queue troubleshooting)
- **File Sharing**:
  - **NFSv4** (exports, fsid=0 design, mounts, reliability tests)
  - **Samba / SMB2–SMB3** (users, shares, permissions, SELinux integration)
- **Database**: **MariaDB** (hardening, RBAC users, mysqldump backups/restores)
- **Time Sync**: **Chrony (NTP)** (sources, tuning, tracking validation)
- **Central Logging**: **rsyslog** (server/client forwarding, templates, log routing)
- **Firewall**: **firewalld** (zones, services, ports, rich rules, forwarding, logging)
- **Service Management**: **systemd** (custom units, timers, restart policies, hardening)
- **Performance Tuning**: **tuned** (profiles, custom profiles, rollout + rollback)

### 🔐 Security & Access Control
- **TLS/SSL**: OpenSSL certificate generation, verification, service TLS validation
- **SELinux**:
  - Status/modes: `sestatus`, `getenforce`, `setenforce`
  - Context + labeling: `semanage`, `restorecon`
  - Denial analysis: `ausearch`, `audit2why`, `sealert`, `audit2allow` (when needed)
- **RBAC**: least-privilege database users and permission validation
  
### ✅ Validation, Testing & Troubleshooting Tooling
- **Service control & logs**: `systemctl`, `journalctl`, `systemd-analyze`
- **Network validation**: `ss`, `netstat`, `curl`, `wget`
- **DNS/DHCP testing**: `dig`, `nslookup`, `tcpdump`
- **Mail validation**: `openssl s_client`, mail queue/log inspection
- **File sharing validation**: `exportfs`, `rpcinfo`, `smbclient`, CIFS mount testing
- **Automation verification**: `ansible-inventory`, `ansible-playbook --check`
- **Logging maintenance**: `logrotate`, `logger`, cleanup scripts, cron scheduling

</details>

---

# 📂 Repository Structure

```

Red-Hat-Certified-Specialist-in-Services-Management-Automation/
├── 🔹 Ansible Foundations & Secure Automation (Labs 1–5)
├── 🔹 Enterprise Network Services Automation (Labs 6–11)
├── 🔹 Core Infrastructure Services (Labs 12–16)
├── 🔹 Platform Engineering & Resource Governance (Labs 17–20)
└── README.md

````

This repository is organized progressively — from Infrastructure as Code foundations to advanced service engineering, performance tuning, and resource governance.

---

## 🧩 Standard Lab Structure

Each lab follows a consistent, enterprise-aligned structure:

```text
labXX-<service-or-topic-name>/
├── README.md                # Objectives, architecture, execution steps
├── commands.sh              # Executed commands (copy/paste runnable)
├── playbooks/               # Ansible playbooks (where applicable)
├── roles/                   # Modular role-based automation (if applicable)
├── templates/               # Jinja2 configuration templates
├── scripts/                 # Monitoring, validation, or helper scripts
├── reports/                 # Validation outputs, verification artifacts
├── outputs/                 # Command outputs, logs, screenshots
├── troubleshooting.md       # Root cause analysis & fixes
└── interview_qna.md         # Interview-focused technical explanations
````

### 📌 What This Ensures

* ✅ Reproducibility of configurations
* ✅ Structured automation artifacts
* ✅ Service validation evidence
* ✅ Troubleshooting transparency
* ✅ Interview-ready documentation
* ✅ Production-aligned engineering workflow

This structure mirrors real enterprise service engineering practices — deploy → secure → validate → troubleshoot → document.

---

## 🎓 Learning Outcomes Across 20 Labs

After completing all 20 labs, this repository demonstrates the ability to:

- Design and implement **Infrastructure as Code (IaC)** using Ansible
- Architect and deploy **enterprise Linux services** (DNS, DHCP, Proxy, Mail, NFS, SMB)
- Implement **secure configuration management** with Vault, RBAC, and TLS
- Build automated **backup & restore pipelines** with validation and retention policies
- Engineer **centralized logging pipelines** for audit and observability
- Automate firewall policies using **zones, rich rules, and logging controls**
- Troubleshoot and remediate **SELinux denials while maintaining enforcing mode**
- Develop resilient **systemd services and timers** with security hardening
- Apply workload-based optimization using **tuned profiles**
- Enforce CPU, memory, task, and I/O limits using **systemd cgroups**

This represents practical infrastructure engineering — not theoretical lab exercises.

---

## 🌍 Real-World Alignment

These labs simulate enterprise infrastructure responsibilities such as:

- Multi-server service deployment and validation
- Secure service hardening and access control design
- Policy-as-code firewall management
- Production-grade logging and audit pipelines
- Database lifecycle management and disaster recovery workflows
- Performance optimization for workload-specific environments
- Resource governance to prevent service instability

The focus is automation-first, security-aware, and operations-driven.

---

## 📊 Professional Relevance

This portfolio reflects capability aligned with:

- Enterprise Linux System Administration
- DevOps & Infrastructure Automation Engineering
- Platform Engineering & Reliability Operations
- Network & Services Infrastructure Management
- Ansible-focused Automation Roles

It demonstrates repeatability, validation discipline, and production-aligned configuration standards.

---

## 🧪 Real-World Simulation Model

All labs were executed in controlled RHEL/CentOS environments designed to simulate realistic enterprise infrastructure operations:

- Multi-host architecture (web, DB, logging, client/server models)
- Automation pipelines using Ansible roles and templates
- Service validation through functional testing and log analysis
- Structured troubleshooting and root cause documentation
- Monitoring, reporting, and verification artifacts for operational evidence

This repository represents applied enterprise Linux services engineering — not academic configuration notes.

---

# 📊 Services Automation Skills Heatmap

This heatmap reflects **hands-on implementation across 20 labs** in:

**Enterprise Linux Services • Infrastructure as Code • Secure Configuration • Reliability Engineering • Performance & Resource Governance**

> Exposure bars use text-style blocks similar to previous portfolio repositories.

| Skill Area | Exposure Level | Practical Depth | Tools / Frameworks Used |
|------------|---------------|----------------|--------------------------|
| ⚙️ Ansible Automation Engineering | ██████████ 100% | Playbooks, roles, Vault, inventory design, validation workflows | Ansible, YAML, Jinja2 |
| 🏗 Infrastructure as Code (IaC) | ██████████ 100% | Idempotent deployments, multi-host automation | Ansible roles, handlers |
| 🌐 Network Services Deployment | █████████░ 90% | DNS, DHCP, Proxy, Mail, NFS, SMB configuration | BIND, DHCPD, Squid, Postfix, NFS, Samba |
| 🔐 Secure Configuration & Hardening | █████████░ 90% | TLS, RBAC, SELinux contexts, access controls | Vault, firewalld, SELinux |
| 🗄 Database Operations Engineering | █████████░ 90% | MariaDB hardening, user privileges, backup/restore validation | MariaDB, mysqldump |
| 📜 Centralized Logging & Observability | █████████░ 90% | Log forwarding, rotation, validation, cleanup automation | rsyslog, logrotate, logger |
| 🔥 Firewall Policy Engineering | ██████████ 100% | Zones, services, rich rules, deny logging, validation reports | firewalld |
| 🧠 SELinux Troubleshooting | █████████░ 90% | AVC analysis, context correction, policy modules | ausearch, semanage, audit2allow |
| 🔧 systemd Service Engineering | ██████████ 100% | Custom units, timers, restart policies, hardening controls | systemd, journalctl |
| 🚀 Performance Tuning | █████████░ 90% | Workload-based profile tuning and verification | tuned, sysctl |
| 📊 Resource Governance (cgroups) | ██████████ 100% | CPU, memory, tasks, I/O limits with monitoring | systemd cgroups |
| 🧪 Validation & Operational Testing | ██████████ 100% | Service checks, connectivity testing, reporting artifacts | curl, ss, systemctl |

## 🧭 Proficiency Scale

- ██████████ = Implemented End-to-End with Automation & Validation  
- ████████░░ = Advanced Practical Implementation with Real Outputs  
- ██████░░░░ = Strong Working Implementation with Applied Context  
- ████░░░░░░ = Foundational + Applied Engineering Exposure  

This heatmap reflects **program-level enterprise services engineering capability**, not isolated configuration tasks — covering:

> Deploy → Secure → Automate → Validate → Tune → Govern

---

## 🧪 How To Use

```bash
# Clone the repository
git clone https://github.com/abdul4rehman215/Red-Hat-Certified-Specialist-in-Services-Management-Automation.git
cd Red-Hat-Certified-Specialist-in-Services-Management-Automation

# Open any lab
cd labXX-<lab-name>
````

### 📖 Review Lab Documentation

```bash
cat README.md
```

### ⚙ Execute Commands / Automation

For command-based labs:

```bash
bash commands.sh
```

For Ansible-based labs:

```bash
ansible-playbook playbooks/<playbook-name>.yml
```

For service validation:

```bash
systemctl status <service>
curl localhost
firewall-cmd --list-all
```

---

> Each lab is self-contained and includes **setup, execution steps, automation artifacts, validation outputs, and structured troubleshooting notes** aligned with enterprise Linux operations workflows.

---

## 🖥 Execution Environment

All labs were executed in isolated Enterprise Linux environments designed to simulate real production services management and automation workflows.

**Environment characteristics:**

- CentOS / RHEL 8/9 based lab systems  
- Ansible control node with SSH key-based authentication  
- Multi-host architecture (web, DB, logging, client/server models)  
- firewalld enabled with zone-based policy testing  
- SELinux enforcing mode (where applicable)  
- systemd-managed services and timers  
- Structured logging, validation scripts, and verification outputs  

Outputs were validated using service checks, connectivity testing, log inspection, and automated verification playbooks to reflect production-grade operational standards.

---

## 🎯 Intended Use

This repository is designed to support:

- Enterprise Linux services deployment & automation
- Infrastructure as Code (IaC) engineering with Ansible
- Secure service configuration & hardening practices
- Database lifecycle management & backup automation
- Centralized logging and firewall policy engineering
- Performance tuning and resource governance via systemd & tuned
- Platform engineering and reliability-focused operations

All automation workflows and configurations are intended for controlled lab environments, infrastructure engineering training, and professional portfolio development.

---

## ⚖️ Ethical & Legal Notice

All automation, configuration, and validation activities in this repository were performed:

- In controlled lab environments
- On self-configured or authorized systems
- For educational and professional engineering purposes

No unauthorized systems were accessed.  
No production systems were modified without permission.

This repository represents responsible infrastructure engineering practice aligned with enterprise operations standards.

---

---

## ⭐ Final Note

This repository reflects **execution-driven enterprise Linux services engineering** — not theoretical notes.

It demonstrates the ability to design, deploy, secure, validate, and automate real-world infrastructure using production-aligned practices.

> **Automate → Secure → Validate → Harden → Govern**

Automation alone is not engineering.  
Engineering is **repeatability + security + operational validation**.

If this portfolio adds value, consider starring it ⭐

---

## 👨‍💻 Author

**Abdul Rehman**

Enterprise Linux Services • Ansible Automation • Secure Operations • Reliability Engineering  
Red Hat Services Management & Automation Portfolio

### 📧 Reach Out

  <a href="https://github.com/abdul4rehman215">
    <img src="https://img.shields.io/badge/Follow-181717?style=for-the-badge&logo=github&logoColor=white" alt="Follow" />
  </a>  
  <a href="https://linkedin.com/in/abdul4rehman215">
     <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white&v=1" />
  </a>
  <a href="mailto:abdul4rehman215@gmail.com">
    <img src="https://img.shields.io/badge/Email-EE0000?style=for-the-badge&logo=gmail&logoColor=white" />
  </a>

---
