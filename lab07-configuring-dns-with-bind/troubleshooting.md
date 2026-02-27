# 🛠️ Lab 07 — Troubleshooting Guide (BIND / named DNS Server)

> This guide lists common issues encountered when configuring **BIND (named)** as a caching/forwarding DNS server and when managing zone files. Each section includes **symptoms**, **likely causes**, **fix steps**, and **verification**.

---

## Issue 1: `named` service won’t start

### ✅ Symptoms
- `systemctl status named` shows **failed**
- `named` exits immediately after start
- Port 53 is not listening

### 🔎 Possible Causes
- Syntax error in `/etc/named.conf`
- Invalid `logging {}` block or duplicated configuration sections
- Zone declarations point to missing/incorrect files
- Zone file syntax errors prevent startup

### ✅ Fix Steps

#### 1) Validate main configuration syntax
```bash
sudo named-checkconf
````

**Expected Output (Lab Example):**

```text id="p0dunf"
(no output - syntax OK)
```

#### 2) Check service logs

```bash
sudo journalctl -u named -f
```

#### 3) Confirm port 53 availability

```bash
sudo netstat -tulnp | grep :53
```

**Expected Output (Lab Example):**

```text id="85q5db"
tcp        0      0 0.0.0.0:53              0.0.0.0:*               LISTEN      2701/named
udp        0      0 0.0.0.0:53              0.0.0.0:*                           2701/named
```

### ✅ Verification

* `sudo systemctl status named` → `active (running)`
* `sudo netstat -tulnp | grep :53` shows named listening on port 53

---

## Issue 2: DNS queries not working (timeouts / SERVFAIL / no response)

### ✅ Symptoms

* `dig @localhost google.com` hangs or returns SERVFAIL
* `nslookup` shows errors
* Clients cannot resolve external domains

### 🔎 Possible Causes

* `named` not listening on correct interfaces
* Firewall blocking DNS (service not allowed)
* Forwarders unreachable / incorrect
* Query access restrictions too strict (ACLs blocking localhost or test client)

### ✅ Fix Steps

#### 1) Confirm named is listening

```bash
sudo netstat -tulnp | grep named
```

**Expected Output (Lab Example):**

```text id="i7y4j1"
tcp        0      0 0.0.0.0:53              0.0.0.0:*               LISTEN      2701/named
udp        0      0 0.0.0.0:53              0.0.0.0:*                           2701/named
```

#### 2) Test local resolution explicitly

```bash
dig @127.0.0.1 google.com
```

**Expected Output (Lab Example):**

```text id="2m22lw"
; <<>> DiG 9.16.23-RH <<>> @127.0.0.1 google.com
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 50122
;; flags: qr rd ra; QUERY: 1, ANSWER: 1
google.com.             211     IN      A       142.250.190.14
```

#### 3) Verify firewall allows DNS

```bash
sudo firewall-cmd --list-services
```

**Expected Output (Lab Example):**

```text id="jdif4t"
cockpit dhcpv6-client dns ssh
```

#### 4) If forwarders are used, confirm reachability

```bash
dig @8.8.8.8 google.com | head
```

**Expected Output (Lab Example):**

```text id="nwxjpj"
; <<>> DiG 9.16.23-RH <<>> @8.8.8.8 google.com
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 11893
;; flags: qr rd ra; QUERY: 1, ANSWER: 1
```

### ✅ Verification

* `dig @localhost example.com` returns NOERROR with an A record
* `dig @localhost microsoft.com` returns NOERROR with an A record
* Logs show queries in `/var/log/messages` (optional)

---

## Issue 3: Zone file errors (named-checkzone fails)

### ✅ Symptoms

* `named-checkzone` returns errors
* `dig @localhost host.lab.local` returns NXDOMAIN or SERVFAIL
* `named` restarts fail after adding zones

### 🔎 Possible Causes

* Zone syntax error (missing dot, invalid record format)
* SOA record missing or incorrectly formatted
* Serial number not valid / not incremented after edits
* Bad NS records (missing hostname targets)

### ✅ Fix Steps

#### 1) Validate forward zone file

```bash
sudo named-checkzone lab.local /var/named/lab.local.zone
```

**Expected Output (Lab Example):**

```text id="5b7iz8"
zone lab.local/IN: loaded serial 2023110802
OK
```

#### 2) Validate reverse zone file

```bash
sudo named-checkzone 1.168.192.in-addr.arpa /var/named/192.168.1.rev
```

**Expected Output (Lab Example):**

```text id="ck8n39"
zone 1.168.192.in-addr.arpa/IN: loaded serial 2023110801
OK
```

#### 3) Confirm zone file permissions and ownership

```bash
ls -la /var/named/lab.local.zone
ls -la /var/named/192.168.1.rev
```

✅ Recommended:

* Owner/group: `named:named`
* Permissions: `640`

#### 4) Check SELinux context (if SELinux enforcing)

```bash
ls -Z /var/named/ | head
```

**Expected Output (Lab Example):**

```text id="p79vm7"
system_u:object_r:named_zone_t:s0 data
system_u:object_r:named_zone_t:s0 dynamic
system_u:object_r:named_cache_t:s0 named.ca
system_u:object_r:named_zone_t:s0 lab.local.zone
system_u:object_r:named_zone_t:s0 192.168.1.rev
```

### ✅ Verification

* Zone checks return OK
* `dig @localhost web.lab.local` returns the correct A record
* `dig @localhost -x 192.168.1.20` returns correct PTR

---

## Issue 4: Forwarding not working

### ✅ Symptoms

* External lookups are slow or fail
* Queries do not appear to go to forwarders
* `dig @localhost google.com` returns SERVFAIL

### 🔎 Possible Causes

* Forwarders blocked by network policy
* Forwarders incorrectly configured (syntax errors in `named.conf`)
* `forwarders {}` block placed in wrong scope (must be inside `options {}`)

### ✅ Fix Steps

#### 1) Validate configuration

```bash
sudo named-checkconf
```

#### 2) Restart and confirm service is stable

```bash
sudo systemctl restart named
sudo systemctl status named
```

#### 3) Monitor named activity via logs

```bash
sudo tail -f /var/log/messages | grep named
```

### ✅ Verification

* `dig @localhost example.com` returns quickly
* Logs show query activity

---

## Issue 5: Cache not behaving as expected

### ✅ Symptoms

* Repeated queries do not get faster
* Cache dump does not show expected entries

### 🔎 Possible Causes

* Recursion disabled
* Cache size too small or disabled by policy
* Queries served from different view or restricted scope

### ✅ Fix Steps

#### 1) Confirm recursion enabled and allowed for trusted clients

In `named.conf`, verify:

* `recursion yes;`
* `allow-recursion { trusted-clients; };`

#### 2) Dump DNS statistics

```bash
sudo rndc stats
cat /var/named/data/named_stats.txt | head -20
```

**Expected Output (Lab Example):**

```text id="v2j3zb"
+++ Statistics Dump +++ (Tue Feb 27 12:55:02 2026)
++ Incoming Requests ++
A  18
AAAA  7
PTR  6
MX  2
NS  3
SOA  2
SRV  1
TXT  1
++ Name Server Statistics ++
IPv4 requests sent  22
IPv6 requests sent  4
```

#### 3) Dump cache database

```bash
sudo rndc dumpdb -cache
cat /var/named/data/cache_dump.db | head -20
```

**Expected Output (Lab Example):**

```text id="d5s4o8"
; Dumped cache of view _default
; Tue Feb 27 12:56:41 2026
google.com.  198 IN A 142.250.190.14
example.com. 86340 IN A 93.184.216.34
microsoft.com. 289 IN A 20.76.201.171
```

### ✅ Verification

* `time dig @localhost google.com` shows faster response on second run
* Cache dump includes recent query entries

---

## 🔐 Security Notes (Best-Practice Fixes Used in This Lab)

These steps reduce DNS abuse risk and improve operational visibility:

* ACLs for trusted clients:

  * `trusted-clients`, `internal-networks`
* Restricted recursion and query access:

  * `allow-query`, `allow-recursion`
* Disabled zone transfers:

  * `allow-transfer { none; };`
* Reduced fingerprinting:

  * `version`, `hostname`, `server-id`
* Added logging for monitoring:

  * security logs and query logs to dedicated files

---

## ✅ Quick Validation Checklist

Use this list to confirm the DNS server is healthy:

* [ ] `sudo named-checkconf` returns no errors
* [ ] `sudo systemctl status named` shows `active (running)`
* [ ] `sudo netstat -tulnp | grep :53` shows TCP/UDP 53 listening
* [ ] `sudo firewall-cmd --list-services` includes `dns`
* [ ] `sudo named-checkzone lab.local /var/named/lab.local.zone` is OK
* [ ] `dig @localhost web.lab.local` returns expected A record
* [ ] `dig @localhost -x 192.168.1.100` returns expected PTR record
* [ ] `sudo rndc stats` + `sudo rndc dumpdb -cache` produce expected files

---
