# 🧪 Lab 07: Configuring DNS with BIND (Caching + Forwarding + Zones)

## 📌 Lab Summary
This lab focuses on installing and configuring **BIND (named)** as a **caching (recursive) DNS server**, enabling **DNS forwarding** to upstream resolvers, and creating both **forward and reverse DNS zones** with common record types (A, CNAME, PTR, NS, MX, SOA), plus advanced additions like TXT and SRV records.

The lab also includes:
- firewall configuration for DNS service
- validation of configuration and zone files
- performance monitoring via `rndc stats`, caching database dumps
- security best practices including ACL restrictions and logging enhancements
- troubleshooting steps for common DNS issues

This lab was performed in a **college-provided cloud lab environment** and documented for a professional portfolio repository.

---

## 🎯 Objectives
By the end of this lab, I was able to:

- Install and configure **BIND (Berkeley Internet Name Domain)** as a caching DNS server
- Enable **DNS forwarding** to upstream servers for efficient resolution
- Create and manage **zone files** and DNS record types:
  - A, CNAME, PTR, NS, MX, SOA
  - Advanced: TXT and SRV
- Understand the DNS resolution process and hierarchy
- Validate and troubleshoot DNS configs using:
  - `named-checkconf`, `named-checkzone`, `dig`, `nslookup`
- Apply DNS security and performance best practices:
  - ACL restrictions, disable transfers, hide version info
  - query/security logging configuration
  - cache tuning parameters

---

## ✅ Prerequisites
Before starting this lab, the following knowledge was required:

- Basic Linux command line operations
- Text editor familiarity (nano/vim)
- Networking fundamentals (IP addressing, domain names)
- Client-server architecture basics
- Service management using systemd

---

## 🧩 Lab Environment
| Component | Details |
|----------|---------|
| OS | CentOS/RHEL 8 or 9 |
| Access | Root (sudo) |
| DNS Service | BIND (`named`) |
| Config File | `/etc/named.conf` |
| Zone Directory | `/var/named/` |
| Logs | `/var/log/messages` and BIND runtime logs |

---

## 🗂️ Repository Structure (Lab Folder)
```text
lab07-configuring-dns-with-bind/
├─ README.md
├─ commands.sh
├─ output.txt
├─ interview_qna.md
├─ troubleshooting.md
└─ configs/
   ├─ named.conf
   ├─ lab.local.zone
   └─ 192.168.1.rev
````

> ✅ Note: In this lab, multiple edits were made to `/etc/named.conf`.
> For portfolio clarity, the `configs/named.conf` file should represent the **final effective configuration** after all changes (caching + forwarding + zones + performance + security + logging).

---

## ✅ Tasks Overview (What I Performed)

### ✅ Task 1: Install BIND and Configure as a Caching DNS Server

**Goal:** Install BIND packages and configure named to work as a recursive caching resolver.

**High-Level Actions:**

* Updated packages and installed:

  * `bind`, `bind-utils`
* Reviewed BIND structure:

  * `/etc/named.conf`
  * `/var/named/`
* Backed up configuration and created a working caching DNS config
* Started and enabled `named`
* Confirmed DNS is listening on port 53 (TCP/UDP)
* Opened DNS service in firewalld
* Verified caching behavior by repeated `dig` queries (second query faster)

---

### ✅ Task 2: Configure DNS Forwarding to Upstream DNS Servers

**Goal:** Improve resolution efficiency by forwarding queries to upstream resolvers.

**High-Level Actions:**

* Added forwarders:

  * Google DNS: `8.8.8.8`, `8.8.4.4`
  * Cloudflare DNS: `1.1.1.1`, `1.0.0.1`
* Set forwarding policy:

  * `forward first;`
* Added conditional forwarding zones for:

  * `internal.company.com`
  * reverse domain `1.168.192.in-addr.arpa`
* Validated configuration with `named-checkconf`
* Restarted `named` and confirmed service health
* Verified forwarder usage through queries and log monitoring

---

### ✅ Task 3: Manage Zone Files for DNS Records (A, CNAME, PTR)

**Goal:** Build authoritative zones locally for a fictional domain to practice record management.

**High-Level Actions:**

* Created a **forward zone** `lab.local` with:

  * NS, A, CNAME, MX records
  * additional A records for testing
* Created a **reverse zone** for `192.168.1.0/24` with PTR records
* Declared zones in `named.conf`
* Set correct ownership and permissions (`named:named`, mode `640`)
* Validated zone syntax using:

  * `named-checkzone`
* Restarted named and verified record resolution using `dig`

---

### ✅ Task 4: Advanced Record Management + Safe Reload

**Goal:** Add more record types and reload zones safely.

**High-Level Actions:**

* Added TXT records (SPF, DMARC)
* Added SRV records for service discovery
* Added additional CNAME aliases
* Updated SOA serial number (from `2023110801` to `2023110802`)
* Reloaded zones without full restart using:

  * `rndc reload`
* Verified new records with `dig` queries

---

### ✅ Task 5: Troubleshooting + Security & Performance Enhancements

**Goal:** Apply operational best practices and common diagnostics.

**High-Level Actions:**

* Verified service startup with:

  * `named-checkconf`, `journalctl`, port checks
* Verified query behavior, firewall services, interface binding
* Validated SELinux contexts for zone files using `ls -Z`
* Collected stats with:

  * `rndc stats`
  * `rndc dumpdb -cache`
  * `rndc querylog on`
* Applied performance tuning values inside `named.conf`:

  * `max-cache-size`, TTL tuning, cleaning interval
* Implemented security hardening:

  * ACLs (`trusted-clients`, `internal-networks`)
  * restricted recursion/query access
  * disabled zone transfers by default
  * hid version/host identifiers
* Implemented structured logging:

  * query logs and security logs to dedicated files
* Validated and restarted named after major changes

---

## ✅ Verification & Validation Checklist

The following checks confirmed the lab worked correctly:

* `systemctl status named` → **active (running)**
* `netstat -tulnp | grep :53` → named listening on TCP/UDP 53
* `firewall-cmd --list-services` includes `dns`
* `named-checkconf` returns no output (syntax OK)
* `named-checkzone` for both zones returns **OK**
* `dig @localhost google.com` works (recursive resolution)
* second `dig` query faster (cache effect)
* local authoritative records resolve correctly:

  * A, CNAME, PTR, NS, MX, SOA, TXT, SRV
* `rndc reload` succeeds for zone reload

---

## ✅ Result

✅ BIND configured successfully as:

* **caching recursive DNS resolver**
* **forwarding resolver** (upstream DNS servers configured)
* **authoritative server** for local forward + reverse zones (`lab.local`)

Records validated using `dig`, and operational visibility enabled through `rndc stats`, cache dump, and query logging.

---

## 💡 Why This Matters

DNS is a foundational network service. In enterprise environments, DNS impacts:

* internal service discovery
* authentication and directory services
* email routing and security (MX, SPF, DMARC)
* troubleshooting and incident response (reverse DNS)
* performance (caching) and resiliency (forwarders)
* security monitoring (query logging can reveal malware/DGA activity)

A secure and well-tuned DNS server reduces risk of:

* DNS amplification abuse
* unauthorized recursion usage
* information leakage through version/hostname banners
* misconfigured zones leading to downtime

---

## 🌍 Real-World Applications

This lab maps directly to real operational tasks such as:

* managing internal DNS for organizations
* deploying DNS in cloud environments for apps/services
* configuring forwarders and conditional forwarding for hybrid networks
* building and maintaining authoritative zones (forward/reverse)
* troubleshooting production DNS issues (latency, SERVFAIL, NXDOMAIN)
* implementing DNS security controls and visibility for SOC teams

---

## ✅ Conclusion

In this lab, I installed and configured BIND as a production-style DNS service with:

* caching + forwarding for efficient resolution
* custom forward and reverse zones for internal naming
* full record coverage (A, CNAME, PTR, NS, MX, SOA, TXT, SRV)
* validation and troubleshooting workflows
* performance monitoring and cache visibility using `rndc`
* security hardening via ACLs, restricted recursion, transfer control, and logging

✅ Lab completed successfully on a cloud lab environment.
