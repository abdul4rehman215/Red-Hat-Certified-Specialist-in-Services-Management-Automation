# 🧪 Lab 01: Automation Using Ansible Basics

> **Track:** Red Hat Certified Specialist in Services Management & Automation (Exam Labs)  
> **Lab Focus:** Ansible ad-hoc automation, service configuration via playbooks, user management, auditing, and verification.

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Execute **Ansible ad hoc commands** to verify host connectivity and gather system information
- Create and run **simple Ansible playbooks** to automate service configuration
- Implement **user account management** across multiple systems using Ansible
- Understand the fundamentals of **Infrastructure as Code (IaC)**
- Apply Ansible best practices for **configuration management**

---

## ✅ Prerequisites

Before starting this lab, the following knowledge was required:

- Basic Linux command-line operations
- SSH concepts and key-based authentication
- YAML syntax fundamentals
- Basic system administration (users, groups, services)
- Comfort with text editors (vim/nano)

---

## 🧰 Lab Environment

| Component | Details |
|---|---|
| Control Node | CentOS/RHEL 8 (Ansible pre-installed) |
| Managed Nodes | `node1`, `node2` |
| SSH | Key-based authentication pre-configured |
| Inventory | `/etc/ansible/hosts` |
| Ansible Version (observed) | `2.9.27` |
| Python (control node) | `3.6.8` |

> **Note:** This lab was performed in a guided cloud lab environment and documented for portfolio upload.

---

## 📁 Repository Structure (Lab Folder)

```text
lab01-automation-using-ansible-basics/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── playbooks/
    │   ├── webserver-setup.yml
    │   ├── database-setup.yml
    │   ├── complete-setup.yml
    │   ├── user-management.yml
    │   ├── sudo-config.yml
    │   ├── user-audit.yml
    │   └── user-cleanup.yml
    └── templates/
        ├── system-info.j2
        └── user-audit.j2
````

---

## 🧩 Lab Tasks Overview (What was done)

### ✅ Task 1: Run Ad Hoc Commands to Check Host Availability

**Goal:** confirm Ansible setup, inventory correctness, SSH access, and basic system info gathering.

* Verified Ansible version and configuration
* Reviewed `/etc/ansible/hosts` inventory configuration
* Verified SSH connectivity to `node1` and `node2`
* Used ad-hoc modules:

  * `ping` for reachability
  * `setup` for facts collection
  * `shell` for disk usage and process listing
  * `command` for uptime
* Targeted the `webservers` group for group-level operations

---

### ✅ Task 2: Write Simple Ansible Playbooks to Configure Services

**Goal:** move from ad-hoc commands to repeatable automation using playbooks.

* Created working directory: `~/ansible-lab`
* Built and executed playbooks to:

  * Install and configure **Apache (httpd)**
  * Configure a **MariaDB** database server on `node2`
  * Run a **multi-service baseline configuration** on all nodes:

    * updates
    * essential packages
    * timezone config
    * create log directory
    * generate system info file from template

---

### ✅ Task 3: Manage User Accounts Across Systems

**Goal:** automate user lifecycle actions at scale.

* Created groups: `developers`, `operators`
* Created user accounts across all hosts:

  * `developer1`, `developer2`, `operator1`
* Generated per-user SSH directories and key pairs
* Created user home subdirectories:

  * `projects/`, `scripts/`, `logs/`
* Configured sudo permissions:

  * restricted sudo rules for developers
  * `NOPASSWD` full sudo for operators
* Implemented auditing:

  * generated user audit reports
  * checked sudo users
  * reviewed recent logins
* Implemented cleanup flow:

  * attempted to remove `testuser1`, `tempuser`, `olduser`
  * archived home dirs if present (ignored if missing)
  * removed temp files and generated user count stats

> **Real-life lab notes (kept realistic):**
> Some playbooks required minimal YAML/logic fixes to run correctly in Ansible (e.g., invalid loop block, missing template variables). These were corrected without changing the original intent.

---

## ✅ Verification & Validation (What was checked)

* Web server accessibility validated using `uri` module
* User creation validated using `id developer1` and `id operator1`
* Services validated using `service_facts`:

  * `httpd.service` running and enabled
  * `firewalld.service` running and enabled
  * `mariadb.service` running and enabled (on node2)
* Sudo permissions validated using:

  * `sudo -l -U developer1` (via Ansible become)

---

## 🧠 What I Learned

* How to confirm automation readiness: inventory + SSH + `ansible all -m ping`
* How to collect system facts and perform fleet-level checks via ad-hoc modules
* How to write repeatable automation with playbooks and templates
* How to automate service deployment (Apache/MariaDB) reliably
* How to manage user lifecycle at scale:

  * users, groups, sudoers, SSH keys, audits, and cleanup
* Why Infrastructure as Code matters for standardization and repeatability

---

## 🌍 Why This Matters

This lab demonstrates practical skills used in:

* **Linux administration automation**
* **DevOps / platform engineering**
* **Security operations support** (auditing, access control, consistency)
* **Enterprise compliance** (standardized configs, sudo policy, audit reporting)

---

## 🧪 Real-World Applications

* Deploying and maintaining consistent service configurations across many servers
* Automated user onboarding/offboarding with standardized permissions
* Generating audit reports for access review and compliance evidence
* Validating deployments using repeatable checks and idempotent playbooks

---

## ✅ Result

* Ad-hoc automation validated across `node1` and `node2`
* Apache deployed and verified on both webservers
* MariaDB deployed and verified on node2
* Multi-service baseline playbook successfully executed
* Users/groups created and permissions verified
* Audit report workflow executed successfully
* Cleanup workflow executed with realistic “missing home directory” archive behavior (ignored errors)

---

## 🧾 Conclusion

This lab built foundational confidence in Ansible-based automation—starting from ad-hoc verification to full playbook-driven configuration, user lifecycle management, auditing, and validation.

It reinforced the core principle of **Infrastructure as Code**: create repeatable, consistent, and scalable system management workflows that reduce human error and increase operational reliability.

---
