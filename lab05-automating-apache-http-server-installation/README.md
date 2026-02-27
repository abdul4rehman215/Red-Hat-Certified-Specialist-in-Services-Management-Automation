# 🧪 Lab 05: Automating Apache HTTP Server Installation (Ansible)

> **Track:** Red Hat Certified Specialist in Services Management & Automation (Exam Labs)  
> **Lab Focus:** Automated Apache deployment, Virtual Hosts, SSL/TLS enablement, custom error pages, and automated validation/testing with Ansible.

---

## 🧰 Lab Environment

| Item | Value |
|---|---|
| OS | CentOS/RHEL 8 (Cloud Lab Environment) |
| Ansible | Ansible Core `2.11.12` (Ansible 4.x tooling available in lab) |
| Control Node User | `centos` |
| Terminal | `-bash-4.2$` |
| Target Nodes | `web1`, `web2` (CentOS/RHEL 8) |
| Key Tools | `httpd`, `mod_ssl`, `openssl`, `curl`, `firewalld` |

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Automate Apache HTTP Server installation on multiple nodes using Ansible
- Configure firewall rules for **HTTP/HTTPS**
- Configure **Virtual Hosts** (multiple websites on one server)
- Implement **SSL/TLS** (self-signed certificates for lab environment)
- Deploy modern SSL hardening and security headers
- Create and configure custom **404/500** error pages
- Build an automated **validation/testing** playbook
- Generate a web-based **test report** for quick verification

---

## ✅ Prerequisites

- Linux CLI fundamentals
- YAML basics
- Ansible basics (inventory, playbooks, tasks, modules)
- Web fundamentals (HTTP/HTTPS, vhosts, TLS)
- SSH key-based authentication understanding

---

## 📁 Repository Structure (Lab Folder)

```text
lab05-automating-apache-http-server-installation/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── apache-automation/
    │   ├── inventory/
    │   │   └── hosts.yml
    │   ├── playbooks/
    │   │   ├── apache-install.yml
    │   │   ├── configure-vhosts.yml
    │   │   ├── ssl-and-errors.yml
    │   │   └── test-apache.yml
    │   ├── templates/
    │   │   ├── vhost.conf.j2
    │   │   ├── ssl-security.conf.j2
    │   │   ├── test-report.html.j2
    │   │   └── error-pages/
    │   │       ├── 404.html.j2
    │   │       └── 500.html.j2
    │   ├── vars/
    │   │   └── vhosts.yml
    │   └── files/
    └── notes/
        └── README.md
````

> **Notes**
>
> * The lab was built as a mini-project (`apache-automation/`) with inventory, playbooks, templates, and vars separated cleanly.
> * `output.txt` captures the full execution outputs (playbook runs, curl checks, handler restarts, etc.).

---

## 🧩 Lab Tasks Overview (What was done)

### ✅ Task 1: Setup Ansible Project + Install Apache

* Verified Ansible version and environment readiness
* Created a clean project skeleton (`playbooks/`, `inventory/`, `templates/`, `vars/`, `files/`)
* Created YAML inventory for `web1` and `web2`
* Created and executed `apache-install.yml` to:

  * Update packages
  * Install `httpd`, `httpd-tools`, `mod_ssl`, and SSL dependencies
  * Enable and start `httpd`
  * Open firewall services for `http` and `https`
  * Deploy a basic default landing page
* Verified with `curl -I http://<target-ip>`

✅ Result: Apache deployed and reachable over HTTP on both nodes.

---

### ✅ Task 2: Configure Virtual Hosts (Multi-site Hosting)

* Created a reusable vhost Jinja template: `templates/vhost.conf.j2`
* Defined vhosts in `vars/vhosts.yml`:

  * `example1.local` (SSL enabled + redirect to HTTPS)
  * `example2.local` (SSL enabled + redirect to HTTPS)
  * `test.local` (no SSL)
* Created and executed `configure-vhosts.yml` to:

  * Create document roots per vhost
  * Generate self-signed certificates for SSL-enabled vhosts
  * Render vhost configuration files into Apache config path
  * Create unique site content per vhost
  * Restart Apache via handler

✅ Result: Multiple vhosts are deployed consistently across both servers.

---

### ✅ Task 3: SSL/TLS Hardening + Custom Error Pages

* Created SSL hardening template: `templates/ssl-security.conf.j2`
* Created error page templates:

  * `templates/error-pages/404.html.j2`
  * `templates/error-pages/500.html.j2`
* Created and executed `ssl-and-errors.yml` to:

  * Ensure headers module availability
  * Deploy SSL security settings
  * Configure global custom error pages using `blockinfile`
  * Validate Apache config with `httpd -t`
  * Restart service if changed

✅ Result: SSL security config and error pages are deployed reliably, with syntax validation.

---

### ✅ Task 4: Automated Testing + HTML Test Report

* Created `test-apache.yml` to validate:

  * Service status (systemd)
  * Ports 80/443 listening
  * HTTP default site works
  * Virtual host routing using Host headers
  * HTTPS works for SSL-enabled vhosts (cert validation disabled because self-signed)
  * Custom 404 response works
  * SSL certificate info collected
  * `httpd -t` syntax check
  * Generates `test-report.html` under `/var/www/html/`

✅ Result: Automated verification produces consistent evidence of a correct deployment.

---

### ✅ Task 5: Troubleshooting Workflow (Operational Readiness)

* Verified service health with `systemctl status httpd`
* Validated configuration with `httpd -t`
* Confirmed firewall services include `http` and `https`

✅ Result: Operational troubleshooting steps documented and repeatable.

---

## ✅ Validation Summary

* `ansible -m ping` to confirm connectivity
* `curl -I http://10.0.1.10` and `curl -I http://10.0.1.11` returned `HTTP/1.1 200 OK`
* Virtual hosts created and Apache restarted successfully
* SSL security config applied and `httpd -t` returned `Syntax OK`
* Test playbook succeeded and generated:

  * `http://<server-ip>/test-report.html`
* Firewall confirmed:

  * `firewall-cmd --list-services` includes `http https`

---

## 🧠 What I Learned

* How to structure an Ansible web deployment project for maintainability
* Managing multi-site Apache deployments using vhosts + templates
* Automating TLS enablement end-to-end, including certificate generation
* Hardening Apache SSL settings and using security headers
* Adding quality checks (`httpd -t`) and automated tests (ports, HTTP/HTTPS, vhosts)
* Producing a test report artifact to support audit/portfolio evidence

---

## 🌍 Why This Matters (Real-World Relevance)

* Repeatable deployments reduce human error and speed up rollouts
* Vhosts + TLS are standard enterprise requirements
* Validation playbooks help reduce risk in production changes
* Configuration as Code creates an audit trail and supports compliance

---

## ✅ Result

* Apache installed + configured on `web1` and `web2`
* Virtual hosts deployed with templated configs and per-site content
* SSL/TLS enabled with self-signed certs (lab-safe) + hardened SSL config
* Custom 404/500 pages deployed globally
* Automated testing completed successfully with a generated HTML report

---
