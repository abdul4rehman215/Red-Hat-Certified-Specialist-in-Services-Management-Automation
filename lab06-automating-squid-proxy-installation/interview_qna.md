# 🎤 Lab 06 — Interview Q&A (Squid Proxy Automation with Ansible)

## 1) What problem does Squid solve in an enterprise network?
**Answer:** Squid acts as a **forward proxy** that can improve performance via **caching**, enforce **web access control**, provide **logging/auditing**, and centralize outbound internet access policies.

---

## 2) Why use Ansible to deploy Squid instead of installing manually?
**Answer:** Ansible ensures **repeatable**, **consistent**, and **auditable** deployments across many servers. It reduces human error, speeds up provisioning, and aligns with **Infrastructure as Code (IaC)** practices.

---

## 3) What does the Ansible inventory do in this lab?
**Answer:** The inventory defines the **managed hosts** (proxy servers) including connection details (host/IP, user, SSH key). In this lab, the host group `proxy_servers` contains the target machine `squid-server`.

---

## 4) Why was the EPEL repository installed?
**Answer:** EPEL provides additional packages not always present in the default RHEL/CentOS repositories. Installing `epel-release` ensures Squid and dependencies can be installed reliably.

---

## 5) What is the purpose of `squid -z`?
**Answer:** `squid -z` initializes the **cache directory structure** (creates cache swap directories like `00`, `01`) so Squid can store cached objects properly.

---

## 6) Why did we open port `3128/tcp` in the firewall?
**Answer:** Squid listens for proxy connections on port `3128` by default. Firewalld must allow inbound TCP connections to that port so clients can reach the proxy.

---

## 7) What is a Jinja2 template and why is it useful here?
**Answer:** Jinja2 templates allow dynamic configuration generation. Here it was used to build `/etc/squid/squid.conf` using variables like `squid_port`, `squid_cache_dir`, and looped lists like `allowed_networks`.

---

## 8) What is the purpose of ACLs in Squid?
**Answer:** ACLs (Access Control Lists) define **who can access** the proxy and what traffic is allowed. ACL ordering matters because Squid processes rules from top to bottom.

---

## 9) Why was `squid -k parse` used in the playbooks?
**Answer:** `squid -k parse` validates the configuration syntax. This prevents restarting Squid with a broken config, improving reliability and reducing downtime.

---

## 10) What did the access log entries confirm?
**Answer:** Entries like `TCP_MISS/200` confirm the proxy successfully processed client requests and fetched content from upstream servers, showing real proxy traffic flow.

---

## 11) What is the meaning of `TCP_MISS/200` in Squid logs?
**Answer:** `TCP_MISS` means the object was not served from cache (it was fetched from the internet), and `/200` indicates the HTTP response status code was 200 (OK).

---

## 12) How did you test proxy functionality in this lab?
**Answer:** Testing was done through:
- Ansible `uri` module with `http_proxy` / `https_proxy` environment variables
- `curl -x <proxy>:3128 <url>` from the client machine
- Viewing `/var/log/squid/access.log` for evidence
- Pulling stats with `squidclient mgr:info`

---

## 13) Why did we configure log rotation for Squid?
**Answer:** Squid logs can grow quickly. Logrotate prevents disk exhaustion, compresses older logs, and reloads Squid after rotation to continue logging cleanly.

---

## 14) What monitoring signals did you check to confirm health/performance?
**Answer:** The monitoring playbook collected:
- cache directory stats (`mgr:storedir`)
- memory stats (`mgr:mem`)
- active connections on port 3128 (`netstat`)
- disk usage for cache storage (`df -h /var/spool/squid`)

---

## 15) What’s one improvement you could add in a production environment?
**Answer:** Add:
- authentication (basic/LDAP)
- TLS bumping (with strict policy and compliance checks)
- centralized logging (rsyslog/ELK)
- HA/load balancing or multiple proxy nodes
- stricter domain blocking integration into `squid.conf` using `acl dstdomain` and `http_access deny`
