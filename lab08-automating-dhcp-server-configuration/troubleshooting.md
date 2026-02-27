# 🛠️ Lab 08 — Troubleshooting Guide (DHCP Server Automation with Ansible)

> This troubleshooting guide covers common issues when deploying and testing an ISC DHCP server (`dhcpd`) using Ansible automation, along with clear verification steps.

---

## Issue 1: DHCP service fails to start

### ✅ Symptoms
- `systemctl status dhcpd` shows **failed**
- `dhcpd` starts and immediately exits
- Clients never receive offers (no DHCPOFFER)

### 🔎 Possible Causes
- Invalid syntax in `/etc/dhcp/dhcpd.conf`
- DHCP configured for a subnet/interface that does not exist on server
- Missing permissions or wrong ownership on config file
- Firewall rules missing or incorrect (less common for service start, but impacts leasing)

### ✅ Fix Steps

#### 1) Validate DHCP configuration syntax (server-side)
```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
````

**Expected Output (Lab Example):**

```text id="ap5b7b"
Internet Systems Consortium DHCP Server 4.3.6
Config file: /etc/dhcp/dhcpd.conf
Database file: /var/lib/dhcpd/dhcpd.leases
PID file: /var/run/dhcpd.pid
```

#### 2) Check service logs for exact failure reason

```bash id="0p2kfp"
journalctl -u dhcpd --no-pager -n 50
```

#### 3) Confirm service is bound/listening on correct interface

```bash id="d9kq1w"
systemctl status dhcpd | head -25
```

**Lab Evidence Example (service running & interface bound):**

```text id="u7q4h2"
Feb 27 13:27:31 dhcp-server dhcpd[2150]: Listening on LPF/ens5/.../192.168.1.0/24
```

### ✅ Verification

* `systemctl status dhcpd` shows `active (running)`
* config check returns rc=0
* server logs show “Listening on LPF/<iface>”

---

## Issue 2: Clients not receiving IP addresses

### ✅ Symptoms

* Client `dhclient -v` hangs or repeats DHCPDISCOVER without receiving offer
* Client gets no IP or stays on old static IP
* Lease file doesn’t show active leases

### 🔎 Possible Causes

* Firewall blocks DHCP
* Server not listening on correct interface/subnet
* Client and server not on same broadcast domain (DHCP relay not set up)
* DHCP range misconfigured (empty range or wrong subnet)

### ✅ Fix Steps

#### 1) Verify firewall allows DHCP service

```bash id="gk1k0j"
firewall-cmd --list-services | grep dhcp
```

**Lab Monitoring Playbook Expected Result:**

* DHCP service is enabled in firewall

#### 2) Check that dhcpd is listening on UDP 67

```bash id="tr07q3"
netstat -ulnp | grep :67
```

#### 3) Watch server logs while client requests a lease

```bash id="5sqb5q"
journalctl -u dhcpd --no-pager -n 50
```

**Expected Log Evidence (Lab Example):**

```text id="u2g0y7"
Feb 27 13:31:20 dhcp-server dhcpd[2150]: DHCPDISCOVER from 52:54:00:2b:9a:10 via ens5
Feb 27 13:31:20 dhcp-server dhcpd[2150]: DHCPOFFER on 192.168.1.101 to 52:54:00:2b:9a:10 via ens5
Feb 27 13:31:20 dhcp-server dhcpd[2150]: DHCPREQUEST for 192.168.1.101 (192.168.1.10) from 52:54:00:2b:9a:10 via ens5
Feb 27 13:31:20 dhcp-server dhcpd[2150]: DHCPACK on 192.168.1.101 to 52:54:00:2b:9a:10 via ens5
```

#### 4) Confirm the lease file includes active lease entries

```bash id="p9bbep"
tail -n 50 /var/lib/dhcpd/dhcpd.leases
```

**Expected Lease Evidence (Lab Example):**

```text id="7w4kgi"
lease 192.168.1.101 {
  starts 2 2026/02/27 13:31:20;
  ends 3 2026/02/28 13:31:20;
  binding state active;
  hardware ethernet 52:54:00:2b:9a:10;
  client-hostname "client-1";
}
```

### ✅ Verification

* Client receives an IP (e.g., `192.168.1.101/24`)
* Lease file shows the IP as `binding state active`
* Ping test to DHCP server succeeds

---

## Issue 3: DHCP configuration errors after template deployment (Ansible)

### ✅ Symptoms

* Ansible playbook fails at template step
* dhcpd fails to restart after playbook run
* service becomes inactive after automated update

### 🔎 Possible Causes

* Missing variables referenced in template
* Jinja loop syntax issues
* Unsupported Jinja filters in environment
* Using templating logic requiring collections not installed (example: ipaddr filter)

### ✅ Fix Steps

#### 1) Validate the rendered config on server

```bash id="t6dqki"
cat /etc/dhcp/dhcpd.conf
```

#### 2) Validate syntax immediately

```bash id="x8h72f"
dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

#### 3) If templating fails due to filters, simplify safely

* In this lab, broadcast address was set explicitly:

  * `option broadcast-address 192.168.1.255;`
    This avoids dependency on optional filter plugins.

### ✅ Verification

* Ansible playbook completes without failure
* `dhcpd -t` returns rc=0
* `systemctl status dhcpd` shows active

---

## Issue 4: Multiple scopes misbehaving (wrong subnet / wrong lease times)

### ✅ Symptoms

* Clients receive IPs from wrong scope
* Lease time not matching expected scope
* Options like DNS/domain name not applying

### 🔎 Possible Causes

* Wrong subnet declarations in dhcpd.conf
* Client network not actually connected to the declared subnet (lab topology mismatch)
* Overlapping ranges or incorrect netmask

### ✅ Fix Steps

1. Confirm client subnet and routes:

```bash id="r8j6bf"
ip addr show
ip route
```

2. Confirm server subnet declarations match real interface subnet:

```bash id="6l8u73"
ip addr show
cat /etc/dhcp/dhcpd.conf
```

3. Avoid overlapping ranges:

* Ensure each subnet has unique non-overlapping pools.

### ✅ Verification

* Client receives IP from correct range for its subnet
* Domain/DNS options match that scope’s config

---

## Issue 5: Load test / traffic capture doesn’t show packets

### ✅ Symptoms

* tcpdump output is empty
* dhcping commands fail
* `/tmp/dhcp-traffic.log` exists but shows no DHCP packets

### 🔎 Possible Causes

* tcpdump started on wrong interface (or too short capture)
* dhcping not installed
* environment does not allow simulated MAC requests (limited lab network)
* DHCP traffic not generated during capture window

### ✅ Fix Steps

#### 1) Ensure tools are installed

```bash
yum install -y tcpdump dhcping
```

#### 2) Run a short capture manually for validation

```bash id="b4pm3a"
sudo tcpdump -i any port 67 or port 68 -c 3
```

**Expected Output (Lab Example):**

```text id="h9a6z2"
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), capture size 262144 bytes
13:40:11.002301 IP 0.0.0.0.bootpc > 255.255.255.255.bootps: BOOTP/DHCP, Request from 52:54:00:2b:9a:10
13:40:11.003012 IP 192.168.1.10.bootps > 255.255.255.255.bootpc: BOOTP/DHCP, Reply, length 300
13:40:11.501004 IP 0.0.0.0.bootpc > 255.255.255.255.bootps: BOOTP/DHCP, Request from 52:54:00:2b:9a:10
3 packets captured
```

### ✅ Verification

* tcpdump shows DHCP Discover/Offer/ACK packets
* load test outputs line count and sample traffic

---

## ✅ Quick Validation Checklist

Use this checklist after automation runs:

* [ ] `dhcpd -t -cf /etc/dhcp/dhcpd.conf` returns OK
* [ ] `systemctl status dhcpd` shows `active (running)`
* [ ] firewall includes DHCP service (`firewall-cmd --list-services | grep dhcp`)
* [ ] client `dhclient -v` receives DHCPOFFER and DHCPACK
* [ ] lease file shows `binding state active`
* [ ] tcpdump captures DHCP traffic on ports 67/68

---
