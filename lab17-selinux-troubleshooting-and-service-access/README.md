# 🧪 Lab 17: SELinux Troubleshooting and Service Access

This lab focuses on **real-world SELinux troubleshooting** when services (Apache and MariaDB) are configured to use **non-standard directories**.  
I intentionally triggered SELinux denials, investigated them using audit tooling, and resolved the issues using **two approved approaches**:

- ✅ **Best practice:** fix **SELinux labeling / file contexts**
- 🧩 **Alternative:** generate and install a **custom policy module** using `audit2allow`

> **Note:** All activities were performed in a **cloud lab environment** on **CentOS/RHEL 8/9** with SELinux enabled.

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand SELinux contexts and enforcement behavior
- Investigate SELinux denials using audit logs (`ausearch`) and analysis tools (`audit2why`, `sealert`)
- Generate allow rules with `audit2allow`
- Apply correct SELinux labels using `semanage fcontext` + `restorecon`
- Install custom policy modules using `semodule`
- Validate service access with SELinux in **enforcing** mode
- Apply production-safe troubleshooting methodology

---

## ✅ Prerequisites

- Linux system administration basics
- Familiarity with CLI editors (`nano`)
- Services management (`systemctl`)
- File permissions & ownership
- Basic networking (ports / localhost testing)
- SELinux concepts (modes, contexts, policies)

---

## 🧰 Lab Environment

| Component | Details |
|---|---|
| OS | CentOS/RHEL 8/9 |
| Shell | `-bash-4.2$` |
| SELinux | Enabled + Enforcing |
| Tools | `audit2why`, `audit2allow`, `sealert`, `ausearch`, `restorecon`, `semanage` |
| Services | Apache (`httpd`), MariaDB (`mariadb`) |
| Test Port | Apache on `8080` |

---

## 🗂️ Repository Structure

```text
lab17-selinux-troubleshooting-and-service-access/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── create_index_html.sh
    ├── create_custom_apache_conf.sh
    ├── create_custom_mariadb_conf.sh
    ├── create_dbtest_php.sh
    └── generate_selinux_summary_report.sh
````

---

## 🧪 Tasks Overview (What I Performed)

### ✅ Task 1 — Investigate SELinux Logs for Denied Access

* Verified SELinux is **enabled** and **enforcing**
* Installed Apache and configured it to serve content from:

  * `/custom/web/content`
* Accessed `http://localhost:8080` to trigger **403 Forbidden**
* Confirmed the service was running and listening on port `8080`
* Used SELinux tooling to identify and explain the denial:

  * `ausearch -m AVC -ts recent`
  * `audit2why`
  * `sealert -a /var/log/audit/audit.log`
* Compared contexts between:

  * `/custom/web/content` (initially `default_t`)
  * `/var/www/html` (`httpd_sys_content_t`)

---

### ✅ Task 2 — Modify SELinux Policies to Allow Required Services

#### ✅ Method 1 (Recommended): Fix File Context Labels

* Added persistent SELinux file context mapping for the custom Apache directory:

  * `httpd_sys_content_t`
* Applied with `restorecon`
* Re-tested: Apache successfully served the page (HTTP 200 OK)

#### 🧩 Method 2 (Alternative): Create Custom SELinux Policy Module

* Removed the custom file context mapping to reproduce denial
* Generated a policy module using recent AVC denials:

  * `audit2allow -M custom_httpd_policy`
* Installed it using `semodule -i`
* Confirmed module presence via `semodule -l`

---

### ✅ Task 2 (Extended) — Database Service Access with SELinux

* Installed MariaDB
* Moved database datadir to a non-standard directory:

  * `/custom/database/data`
* Labeled it correctly using:

  * `mysqld_db_t`
* Initialized DB files using `mysql_install_db`
* Started and enabled MariaDB successfully

---

### ✅ Task 3 — Test Service Access Post-Configuration

* Verified Apache returned HTTP 200 with full response
* Verified no recent SELinux AVC denials remained
* Verified Apache could read content as the `apache` user
* Verified MariaDB was running and using the custom datadir
* Installed PHP + DB connector and tested web→DB integration
* Enabled SELinux boolean for web-to-DB connectivity:

  * `httpd_can_network_connect_db`

---

## ✅ Verification & Validation

I validated results using:

* `getenforce` → confirmed Enforcing
* `curl -v http://localhost:8080` → HTTP 200
* `sudo ausearch -m AVC -ts recent` → no matches
* `sudo systemctl status httpd mariadb` → both active
* `sudo mysql -u root -e "SHOW VARIABLES LIKE 'datadir';"` → `/custom/database/data/`
* `ls -laZ` checks to confirm correct SELinux labeling
* Generated a final report file:

  * `selinux_config_summary.txt`

---

## 📌 Result

* ✅ Apache served content from `/custom/web/content` while SELinux remained enforcing
* ✅ MariaDB used `/custom/database/data` with proper SELinux labeling
* ✅ SELinux denials were correctly identified and resolved using **best practice** + **policy module** method
* ✅ Web + DB integration succeeded after boolean and access alignment
* ✅ A final SELinux configuration summary was generated for documentation

---

## 🧠 What I Learned

* SELinux is often not “breaking” a service — it is **protecting** it based on policy boundaries
* The most secure fix is usually:

  * ✅ **label the resource correctly** (contexts)
  * ✅ use **booleans** where appropriate
* Custom policy modules are powerful but should be used **sparingly** and reviewed carefully
* Audit logs + `audit2why` are the fastest path to the real root cause

---

## 🔥 Why This Matters

In enterprise environments, SELinux is often **mandatory** for compliance and defense-in-depth.

This lab reflects common real-world admin work:

* Serving web apps from non-standard directories
* Running databases from custom storage paths
* Troubleshooting “permissions” issues that are actually SELinux policy enforcement
* Keeping services functional **without disabling SELinux**

---

## 🌍 Real-World Applications

* Deploying custom Apache virtual hosts and document roots
* Moving database datadirs to dedicated storage volumes
* Troubleshooting production SELinux denials safely
* Building audit-backed approvals for policy changes
* Supporting compliance requirements in hardened Linux environments

---

## ✅ Conclusion

This lab strengthened my ability to troubleshoot service failures caused by SELinux enforcement by:

* identifying denials in audit logs
* analyzing with `audit2why` and `sealert`
* applying **correct file contexts** (recommended)
* creating **custom allow modules** (alternative)
* validating Apache + MariaDB functionality while SELinux stays enforcing

---
