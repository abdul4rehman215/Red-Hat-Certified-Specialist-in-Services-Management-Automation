# 🎤 Interview Q&A — Lab 17: SELinux Troubleshooting and Service Access

## 1) What problem does SELinux solve in Linux?
SELinux enforces **Mandatory Access Control (MAC)**, limiting what processes can do even if traditional UNIX permissions would allow it. This reduces damage from compromised services by enforcing policy boundaries.

---

## 2) What’s the difference between *enforcing*, *permissive*, and *disabled*?
- **Enforcing:** SELinux policy is enforced; denied actions are blocked and logged.
- **Permissive:** SELinux does not block; it only logs denials (useful for troubleshooting).
- **Disabled:** SELinux is turned off (not recommended in production).

---

## 3) Why did Apache return `403 Forbidden` even though file permissions were `755`?
Because the directory and files were labeled with SELinux type **`default_t`**, which `httpd_t` is not allowed to read. This is a classic case where **UNIX permissions look correct**, but SELinux policy blocks access.

---

## 4) What command confirms SELinux mode quickly?
`getenforce`  
It returns: `Enforcing`, `Permissive`, or `Disabled`.

---

## 5) What is an AVC denial?
An **Access Vector Cache (AVC)** denial is a logged event showing SELinux blocked an action. It contains:
- source context (`scontext`) — the process
- target context (`tcontext`) — the file/object
- class (`tclass`) and permission (e.g., `read`, `open`)

---

## 6) Where do you find SELinux denials?
Common places:
- `/var/log/audit/audit.log` (audit subsystem)
- `ausearch -m AVC -ts recent` (filtered view)

---

## 7) What does `audit2why` do?
It interprets AVC denials and suggests **why the denial occurred**, often pointing to:
- missing type enforcement rules
- missing labels
- missing SELinux boolean enablement

---

## 8) What does `sealert` provide that `ausearch` doesn’t?
`sealert` gives **human-readable explanations** and actionable suggestions like:
- fix contexts using `semanage fcontext` + `restorecon`
- generate a policy module using `audit2allow`
It’s very helpful for fast root-cause identification.

---

## 9) What is the recommended fix for services blocked by SELinux?
**Fix labeling (contexts)** first:
- Add a persistent mapping with `semanage fcontext`
- Apply using `restorecon`

This is safer than writing permissive allow rules.

---

## 10) Why is creating a custom policy module considered “alternative” (not best practice)?
Because policy modules can become too permissive if generated blindly and might allow access that shouldn’t be allowed. It’s better to align with existing SELinux policy by using correct labels and booleans.

---

## 11) What SELinux type is commonly expected for Apache static content?
`httpd_sys_content_t`  
Example standard path:
- `/var/www/html` is labeled `httpd_sys_content_t`

---

## 12) What SELinux type is used for MariaDB database files?
`mysqld_db_t`  
When MariaDB uses a custom datadir, that directory must be labeled correctly, or the database may fail to start or read data.

---

## 13) What is an SELinux boolean, and why is it useful?
A boolean is a toggle that enables or disables certain SELinux policy features without rewriting policy.  
Example used in this lab:
- `httpd_can_network_connect_db` → enables web services to connect to database services.

---

## 14) How do you list Apache-related SELinux booleans?
Example:
```bash
getsebool -a | grep httpd
````

---

## 15) How do you verify your SELinux changes worked?

* Web returns HTTP **200 OK**
* Database service is **active**
* Custom datadir is in use
* No recent AVC denials:

```bash
sudo ausearch -m AVC -ts recent
```
