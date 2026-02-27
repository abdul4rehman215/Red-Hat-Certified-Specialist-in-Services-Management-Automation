# 🎤 Interview Q&A — Lab 05: Automating Apache HTTP Server Installation (Ansible)

> Topics covered: Apache automation, vhosts, SSL/TLS, Ansible modules, idempotency, validation/testing, and troubleshooting.

---

## 1) Why automate Apache installation using Ansible instead of doing it manually?
**Answer:**  
Automation ensures **consistency, speed, and repeatability**. Manual installs are error-prone and inconsistent across servers. Ansible allows the same configuration to be applied across many nodes with version-controlled playbooks and clear auditing.

---

## 2) What does an Ansible inventory do in this lab?
**Answer:**  
The inventory defines **which servers** Ansible manages (`web1`, `web2`) and includes connection variables like:
- `ansible_host`
- `ansible_user`
- `ansible_ssh_private_key_file`
This makes targeting groups like `webservers` easy.

---

## 3) Which modules were used to install and manage Apache?
**Answer:**  
Key modules used:
- `yum` → install packages and update system  
- `systemd` → start/enable `httpd`  
- `firewalld` → open HTTP/HTTPS services  
- `copy` / `template` → deploy HTML + config files  
- `file` → create directories  
- `openssl_privatekey`, `openssl_csr`, `openssl_certificate` → generate TLS material  
- `uri` and `wait_for` → validation (HTTP checks, port checks)

---

## 4) What does “idempotency” mean in Ansible, and why is it important?
**Answer:**  
Idempotency means running the same playbook multiple times results in the **same end state** without unnecessary changes. It matters because it:
- reduces risk
- supports re-runs in CI/CD
- helps enforce configuration drift control

---

## 5) Why were `mod_ssl` and `openssl` installed?
**Answer:**  
- `mod_ssl` enables Apache HTTPS support.
- `openssl` is needed to generate keys/certificates (in this lab, self-signed certs).

---

## 6) What is a Virtual Host in Apache?
**Answer:**  
A Virtual Host allows Apache to host **multiple websites** on one server by mapping different domains/hostnames to different document roots and configs.

---

## 7) How did you configure virtual hosts in this lab?
**Answer:**  
Using:
- A Jinja2 template `templates/vhost.conf.j2`
- A vars file `vars/vhosts.yml` defining each site
- A playbook that loops through `virtual_hosts` and renders one config per vhost into `/etc/httpd/conf.d/`

---

## 8) How did you test vhosts without real DNS in a lab environment?
**Answer:**  
By using HTTP Host headers.  
The Ansible `uri` module can send:
```yaml
headers:
  Host: "example1.local"
````

So Apache routes to the correct vhost.

---

## 9) Why were self-signed certificates used in this lab?

**Answer:**
Because it’s a controlled lab environment without public DNS/CA integration. Self-signed certs are acceptable for testing TLS configuration, but production should use trusted CA or internal PKI.

---

## 10) What security hardening was applied for TLS?

**Answer:**
A dedicated SSL security config was deployed that:

* disables old protocols (`TLSv1`, `TLSv1.1`, SSLv3)
* sets modern ciphers
* disables session tickets
* applies security headers including HSTS, X-Frame-Options, nosniff, XSS protection, etc.

---

## 11) Why create custom error pages (404/500)?

**Answer:**
Custom error pages:

* improve user experience
* reduce information leakage (avoid default server signatures)
* standardize response behavior across servers

---

## 12) How did you validate Apache configuration before and after changes?

**Answer:**

* Used `httpd -t` inside playbooks to ensure syntax is valid
* Used `uri` tests for HTTP/HTTPS
* Used `wait_for` to confirm ports 80 and 443 are listening

---

## 13) Why did the playbook include `httpd -t`?

**Answer:**
To prevent bad configurations from being deployed silently. If syntax is broken, Apache reload/restart can fail, so validating config early reduces downtime risk.

---

## 14) What is the purpose of the generated `test-report.html`?

**Answer:**
It creates a visible **evidence artifact** of validation (reporting environment, vhosts, and test assumptions) that can be accessed via:

* `http://<server-ip>/test-report.html`

This is useful for documentation, portfolio proof, and operational handover.

---

## 15) The SSL playbook attempted `apache2_module` and it failed — why?

**Answer:**
`apache2_module` is commonly used on Debian/Ubuntu systems (apache2 tooling). On RHEL/CentOS, module enabling is usually handled differently (config includes / installed modules).
So the playbook used an alternative method: inserting `LoadModule` lines via `lineinfile` (and kept `ignore_errors: yes`).

---

## 16) How did you confirm firewall configuration was correct?

**Answer:**
By checking:

```bash
firewall-cmd --list-services
```

and verifying `http` and `https` are allowed, plus confirming curl access succeeds.

---

## 17) What troubleshooting steps do you follow when Apache is not reachable?

**Answer:**

1. Check service status:

   * `systemctl status httpd`
2. Validate config:

   * `httpd -t`
3. Check firewall rules:

   * `firewall-cmd --list-services`
4. Check logs:

   * `/var/log/httpd/error_log`
5. Confirm ports:

   * `ss -tulpn | grep :80` and `:443`

---

## 18) What real-world scenario matches this lab?

**Answer:**
This mirrors production automation for:

* deploying Apache across multiple nodes
* enabling TLS everywhere
* standardizing vhost definitions
* verifying deployments automatically
* producing proof/report artifacts for audits or handover

---
