# 🛠️ Troubleshooting Guide — Lab 15: Centralized Logging with rsyslog

> This guide covers common problems when building centralized logging with rsyslog, including real issues encountered in this lab.

---

## Issue 1: Client logs not appearing on server

### ✅ Symptoms
- `/var/log/remote/` has no client directory
- No forwarded logs appear in `/var/log/remote/<client>/`
- `logger` on client produces no visible remote result

### ✅ Checks (Client)
1) Verify rsyslog is running:
```bash
sudo systemctl status rsyslog
````

2. Verify forwarding rules exist:

```bash
tail -n 20 /etc/rsyslog.conf
cat /etc/rsyslog.d/50-remote.conf
```

3. Verify the server address is correct:

```bash
ip addr show eth0 | grep inet
```

### ✅ Checks (Server)

1. Verify rsyslog is running:

```bash
sudo systemctl status rsyslog
```

2. Verify listeners:

```bash
sudo ss -tulnp | grep 514
```

3. Check firewall ports:

```bash
sudo firewall-cmd --list-ports
```

### ✅ Fix

* Restart services:

```bash id="b7l4o2"
sudo systemctl restart rsyslog
```

* Validate configuration syntax (server):

```bash id="m3q8w0"
sudo rsyslogd -N1 -f /etc/rsyslog.conf
```

---

## Issue 2: Port 514 blocked / connectivity failure

### ✅ Symptoms

* Client cannot connect to server on TCP 514
* Remote logs never arrive
* `telnet` or `nmap` show closed port

### ✅ Checks (Client)

Test TCP connectivity:

```bash id="m8r0k1"
telnet 10.0.2.41 514
```

If `telnet` is missing:

```bash id="x5f1s9"
sudo dnf install telnet -y
```

Port scan test:

```bash id="j6v2t3"
nmap -p 514 10.0.2.41
```

If `nmap` is missing:

```bash id="d2h7v4"
sudo dnf install nmap -y
```

### ✅ Fix (Server)

Open firewall ports:

```bash id="q0z3a1"
sudo firewall-cmd --permanent --add-port=514/tcp
sudo firewall-cmd --permanent --add-port=514/udp
sudo firewall-cmd --reload
sudo firewall-cmd --list-ports
```

---

## Issue 3: rsyslog server not listening on UDP/TCP 514

### ✅ Symptoms

* `ss -tulnp | grep 514` shows nothing
* Client forwarding works locally but server never receives

### ✅ Causes

* Input modules not enabled (`imudp`/`imtcp`)
* Configuration not loaded correctly
* rsyslog not restarted after changes

### ✅ Fix

Confirm server config has input modules:

```conf id="l3f8u1"
$ModLoad imudp
$UDPServerRun 514
$ModLoad imtcp
$InputTCPServerRun 514
```

Restart:

```bash id="n0p2u7"
sudo systemctl restart rsyslog
sudo ss -tulnp | grep 514
```

---

## Issue 4: `netstat: command not found`

### ✅ Symptoms

Running:

```bash
sudo netstat -tulnp | grep 514
```

returns:

```text
bash: netstat: command not found
```

### ✅ Fix

Install `net-tools`:

```bash id="f2x8c6"
sudo dnf install net-tools -y
```

Or use modern `ss`:

```bash id="q7r0z8"
sudo ss -tulnp | grep 514
```

---

## Issue 5: Permission denied writing under `/var/log/remote`

### ✅ Symptoms

* Client connects, but server doesn’t write logs
* rsyslog logs show permission failures
* log directory exists but files not created

### ✅ Cause

Directory ownership/group not aligned to syslog daemon expectations.

### ✅ Fix

In this lab, `adm` group was missing initially:

```bash id="x8u9f3"
sudo groupadd adm
sudo chown -R syslog:adm /var/log/remote
sudo chmod -R 755 /var/log/remote
ls -ld /var/log/remote
```

---

## Issue 6: SELinux blocking forwarding or remote log writes

### ✅ Symptoms

* Everything looks correct but logs still do not write
* SELinux is enforcing

### ✅ Checks

```bash id="m4w1p9"
sestatus
sudo journalctl -t setroubleshoot --no-pager -n 50
sudo journalctl | grep -i avc | tail -n 20
```

### ✅ Fix

Allow rsyslog networking:

```bash id="v6k2r1"
sudo setsebool -P rsyslog_can_network on
```

If you must customize ports (usually not needed for 514):

```bash id="m0s9y4"
sudo dnf install policycoreutils-python-utils -y
sudo semanage port -a -t syslogd_port_t -p tcp 514
sudo semanage port -a -t syslogd_port_t -p udp 514
```

⚠️ In this lab, `semanage` showed:

* `Port tcp/514 already defined`
* `Port udp/514 already defined`
  Which is normal on many builds.

---

## Issue 7: Log rotation not working / logs keep growing

### ✅ Symptoms

* `/var/log/remote/.../*.log` keeps increasing
* rotated/compressed logs not appearing

### ✅ Checks

Test logrotate config (dry run):

```bash id="z1u8p5"
sudo logrotate -d /etc/logrotate.d/remote-logs
```

Force rotation for testing:

```bash id="s0r7h2"
sudo logrotate -f /etc/logrotate.d/remote-logs
```

Check logrotate state:

```bash id="h3n4t8"
cat /var/lib/logrotate/status | tail -n 20
```

### ✅ Notes

If logs do not exist yet, logrotate will skip — which is expected early in the setup.

---

## Issue 8: Duplicate logs or unexpected file placement

### ✅ Symptoms

* Logs appear in multiple places unexpectedly
* Remote logs also appear in default `/var/log/messages` or others

### ✅ Cause

Rules continue processing after writing to RemoteLogs template.

### ✅ Fix

Ensure `& stop` exists after remote rule:

```conf id="j5k8v4"
*.* ?RemoteLogs
& stop
```

---

## ✅ Quick Validation Checklist (Fast)

### Server (10.0.2.41)

```bash id="d2r8c1"
sudo systemctl status rsyslog --no-pager | head -n 10
sudo ss -tulnp | grep 514
sudo firewall-cmd --list-ports
ls -la /var/log/remote
sudo rsyslogd -N1 -f /etc/rsyslog.conf
```

### Client (10.0.2.42)

```bash id="b1z0x6"
sudo systemctl status rsyslog --no-pager | head -n 10
tail -n 10 /etc/rsyslog.conf
cat /etc/rsyslog.d/50-remote.conf
sudo logger "Quick remote test from client"
```

### Confirm on server

```bash id="r5p1y9"
tail -n 20 /var/log/remote/client01/logger.log
```

---

## 🔐 Security Reminder (Production)

* Prefer **TCP** over UDP for reliability.
* Restrict firewall rules to trusted subnets (not 0.0.0.0/0).
* Use **TLS (6514)** for encrypted log transport.
* Harden permissions on `/var/log/remote` to prevent tampering.
* Forward logs into SIEM/ELK for alerting and correlation.

---
