# 🧪 Lab 06: Automating Squid Proxy Server Installation (Ansible)

## 📌 Lab Summary
This lab demonstrates how to **deploy and configure a Squid proxy server using Ansible** in a structured Infrastructure-as-Code workflow.  
The work includes building an Ansible project layout, writing playbooks for installation and advanced configuration, templating Squid configs with Jinja2, implementing firewall rules, validating configuration syntax, running automated functional tests, running client-side proxy testing, and finally monitoring proxy performance.

This lab was performed in a **college-provided cloud lab environment** and documented for a professional portfolio repository.

---

## 🎯 Objectives
By the end of this lab, I was able to:

- Install and configure **Squid proxy server** using **Ansible automation**
- Create structured **Ansible playbooks** for deployment and configuration management
- Configure Squid caching behavior and **access control rules**
- Validate Squid configuration using `squid -k parse`
- Test proxy server functionality with Ansible + curl-based validation
- Monitor proxy performance via Squid manager endpoints and system tools
- Apply **Infrastructure as Code (IaC)** and configuration management principles

---

## ✅ Prerequisites
Before starting this lab, the following knowledge was required:

- Basic Linux command line operations
- YAML syntax and structure
- Ansible fundamentals (playbooks, inventory, modules)
- Networking basics (IP, ports, HTTP/HTTPS)
- Text editors (nano/vim)
- Basic understanding of proxy servers (why/when used)

---

## 🧩 Lab Environment
| Component | Details |
|----------|---------|
| Control Node | CentOS/RHEL 8 (Ansible installed) |
| Target Node | CentOS/RHEL 8 (Squid installed here) |
| Client Machine | Used for proxy testing (curl validation) |
| Proxy Service | Squid |
| Proxy Port | `3128/tcp` |
| Firewall | firewalld |

> ⚠️ Note: The lab guide referenced a sample target IP (`192.168.1.100`). In real lab environments, the target IP may differ and should be replaced accordingly.

---

## 🗂️ Repository Structure (Lab Folder)
Below is the structure for this lab folder inside the category repository:

```text
lab06-automating-squid-proxy-installation/
├─ README.md
├─ commands.sh
├─ output.txt
├─ interview_qna.md
├─ troubleshooting.md
├─ inventory/
│  └─ hosts.yml
├─ playbooks/
│  ├─ install-squid.yml
│  ├─ configure-squid.yml
│  ├─ test-squid.yml
│  ├─ client-test.yml
│  └─ monitor-squid.yml
└─ templates/
   ├─ squid.conf.j2
   └─ blocked_domains.j2
````

---

## ✅ Tasks Overview (What I Performed)

### ✅ Task 1: Create a Playbook to Install Squid Proxy Server

**Goal:** Build a clean Ansible project and automate Squid installation end-to-end.

**Work Completed (High-Level):**

* Created a structured Ansible project directory (`playbooks/`, `inventory/`, `templates/`, `vars/`)
* Defined target host group `proxy_servers` in YAML inventory
* Automated:

  * system update
  * EPEL installation
  * Squid installation
  * utilities installation (wget/curl/net-tools)
  * cache directory creation + initialization (`squid -z`)
  * service enable/start
  * firewall opening (`3128/tcp`)
* Verified Squid service health via Ansible

---

### ✅ Task 2: Configure Squid Settings for Caching and Access Control

**Goal:** Apply advanced Squid configuration using templates + restart handler.

**Work Completed (High-Level):**

* Created `squid.conf.j2` template with:

  * `http_port` binding
  * cache dir setup
  * memory cache tuning
  * ACLs for local/private networks
  * additional allowed networks via Jinja loop
  * secure access rule ordering (deny unsafe ports, allow allowed networks, deny all else)
  * logging paths
  * performance tuning (DNS cache sizes, DNS servers)
  * security header restrictions
* Built `configure-squid.yml` playbook that:

  * backs up existing config
  * deploys template-managed config
  * creates blocked domains list
  * installs logrotate config for Squid logs
  * validates config using `squid -k parse`
  * restarts Squid via handler

---

### ✅ Task 3: Test Proxy Functionality

**Goal:** Verify the proxy works (server-side + client-side), confirm logging and statistics.

**Work Completed (High-Level):**

* Server-side testing playbook:

  * ensured Squid is started
  * confirmed port listening using `wait_for`
  * tested multiple URLs via Ansible `uri` module using proxy environment variables
  * tailed Squid access logs to confirm traffic visibility
  * pulled Squid proxy stats using `squidclient mgr:info`
* Client-side testing:

  * compared direct IP vs proxy IP using `httpbin.org/ip`
  * verified proxy operation with curl through the proxy
  * confirmed working for HTTP and HTTPS use-cases

---

### ✅ Task 4: Monitor and Verify Proxy Performance

**Goal:** Confirm cache usage, memory behavior, connections, and disk usage for cache directory.

**Work Completed (High-Level):**

* Collected:

  * cache stats using `squidclient mgr:storedir`
  * memory stats using `squidclient mgr:mem`
  * active connections using `netstat`
  * disk usage using `df -h /var/spool/squid`

---

## ✅ Verification & Validation

Key validation steps used:

* Confirm Squid service is **running** and **enabled**
* Confirm port **3128/tcp is open** in firewalld
* Confirm Squid config parses successfully:

  * `squid -k parse`
* Confirm access logs show proxy traffic (TCP_MISS/200 entries)
* Confirm test URLs return HTTP 200 through proxy
* Confirm monitoring commands report cache/memory/connection/disk stats

---

## ✅ Result

✅ Squid proxy server installation and configuration automation completed successfully.

* Squid installed and running via Ansible
* Firewall configured to allow proxy traffic on `3128/tcp`
* Configuration managed using Jinja2 templates
* Proxy functionality validated via server-side and client-side testing
* Monitoring playbook successfully produced cache/memory/connection/disk stats
* Log rotation configured for Squid logs

---

## 💡 Why This Matters

Proxy servers are widely used in real-world enterprise networks to:

* control outbound access (policy enforcement)
* improve performance through caching
* enable monitoring and auditing of traffic
* support compliance requirements
* reduce bandwidth usage and speed up repeated requests

Automating proxy deployment with Ansible makes deployments:

* repeatable
* consistent
* less error-prone
* easier to maintain at scale

---

## 🌍 Real-World Applications

This lab directly maps to real work such as:

* Enterprise proxy server rollout and standardization
* Web access control and content filtering
* Secure outbound internet gateways
* Network performance optimization via caching
* DevOps/IaC automation for infrastructure services
* Maintaining consistent security policies across environments

---

## ✅ Conclusion

In this lab, I successfully implemented a complete Infrastructure-as-Code workflow to deploy and manage a Squid proxy server:

* Built an Ansible project structure and inventory
* Automated Squid installation and service setup
* Applied template-based configuration and access controls
* Validated Squid configuration correctness
* Tested proxy functionality using multiple methods
* Implemented monitoring tasks for operational readiness

✅ Lab completed successfully on a cloud lab environment.
