# 🎤 Lab 07 — Interview Q&A (Configuring DNS with BIND)

## 1) What is BIND and what service does it provide?
**Answer:** BIND (Berkeley Internet Name Domain) provides a DNS server implementation (`named`) that can operate as a **caching (recursive) resolver**, an **authoritative DNS server**, or both depending on configuration.

---

## 2) What is the difference between a recursive (caching) DNS server and an authoritative DNS server?
**Answer:**  
- A **recursive/caching DNS server** resolves names on behalf of clients by querying other DNS servers and storing answers in cache.  
- An **authoritative DNS server** hosts zone data and answers queries for domains it manages directly (zones).

---

## 3) Why is enabling recursion on a public DNS server risky?
**Answer:** Public recursive DNS servers without access control can be abused in **DNS amplification attacks** (DDoS). That’s why recursion should be restricted to trusted client networks.

---

## 4) Which file is the main BIND configuration file in this lab?
**Answer:** The main configuration file is `/etc/named.conf`.

---

## 5) What are forwarders in BIND and why use them?
**Answer:** Forwarders are upstream DNS resolvers (e.g., Google/Cloudflare) that BIND forwards queries to. They can improve performance, reliability, and simplify outbound DNS resolution behavior.

---

## 6) What does `forward first;` mean in BIND?
**Answer:** It tells BIND to **try forwarders first**, and if they fail, BIND attempts to resolve queries directly using the normal recursive resolution process.

---

## 7) What is conditional forwarding?
**Answer:** Conditional forwarding forwards queries for specific zones (e.g., `internal.company.com`) to specific DNS servers (e.g., internal domain controllers or internal resolvers).

---

## 8) What tools did you use to test DNS resolution?
**Answer:**  
- `dig` for detailed DNS query output and record testing  
- `nslookup` for quick resolution checks  
- `time dig` for measuring cache performance improvement

---

## 9) How did you confirm caching was working?
**Answer:** By running the same `dig @localhost google.com` query twice and observing the second query returning significantly faster (e.g., 39 ms → 1 ms).

---

## 10) What is a forward zone file and what does it contain?
**Answer:** A forward zone file maps **hostnames to IP addresses** (A records), aliases (CNAME), mail routing (MX), and more. In this lab, `lab.local.zone` defined multiple records for `lab.local`.

---

## 11) What is a reverse zone file and what does it contain?
**Answer:** A reverse zone file maps **IP addresses to hostnames** using PTR records. In this lab, `192.168.1.rev` handled reverse DNS for the `192.168.1.0/24` network.

---

## 12) Why is the SOA serial number important?
**Answer:** The serial number signals zone updates. When the zone file changes, the serial should be incremented (e.g., `2023110801 → 2023110802`) so secondary servers and resolvers recognize the update.

---

## 13) What do `named-checkconf` and `named-checkzone` do?
**Answer:**  
- `named-checkconf` validates the syntax of `named.conf`  
- `named-checkzone` validates a specific zone file’s structure and records

---

## 14) What is `rndc` and what was it used for here?
**Answer:** `rndc` is the remote name daemon control tool. It was used to:
- reload configuration/zone data (`rndc reload`)
- dump stats (`rndc stats`)
- dump cache database (`rndc dumpdb -cache`)
- enable query logging (`rndc querylog on`)

---

## 15) What security hardening steps were applied to BIND in this lab?
**Answer:**  
- Restricted recursion and queries to **trusted ACLs**  
- Disabled zone transfers by default (`allow-transfer { none; };`)  
- Hid fingerprinting details (`version`, `hostname`, `server-id`)  
- Implemented query/security logging for monitoring and auditing
