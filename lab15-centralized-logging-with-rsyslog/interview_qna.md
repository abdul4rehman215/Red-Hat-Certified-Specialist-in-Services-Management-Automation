# 🎤 Interview Q&A — Lab 15: Centralized Logging with rsyslog

## 1) What is rsyslog and why is it commonly used on Linux?
rsyslog is a syslog daemon used for collecting, processing, and storing logs. It supports local logging, remote forwarding, filtering, templates, and multiple protocols, making it suitable for centralized logging in enterprise environments.

---

## 2) Why is centralized logging important?
Centralized logging provides:
- single place to search and correlate events
- improved incident response and forensic timeline accuracy
- easier compliance and retention management
- reduced troubleshooting time across multiple systems

---

## 3) What is the difference between UDP syslog and TCP syslog?
- **UDP (514/udp):** faster, lower overhead, but no delivery guarantee
- **TCP (514/tcp):** reliable delivery, supports larger messages, preferred for production forwarding

---

## 4) What do `@` and `@@` mean in rsyslog forwarding rules?
- `@SERVER:514`  → send logs using **UDP**
- `@@SERVER:514` → send logs using **TCP**

In this lab, TCP was used:
```conf
*.* @@10.0.2.41:514
````

---

## 5) Which rsyslog modules enable the server to receive remote logs?

* `imudp` → UDP input
* `imtcp` → TCP input

Enabled using:

```conf
$ModLoad imudp
$UDPServerRun 514
$ModLoad imtcp
$InputTCPServerRun 514
```

---

## 6) How did you organize remote logs on the server?

Using a template:

```conf
$template RemoteLogs,"/var/log/remote/%HOSTNAME%/%PROGRAMNAME%.log"
*.* ?RemoteLogs
& stop
```

This stores logs in per-host directories and per-program log files.

---

## 7) Why is `& stop` used after the remote logging rule?

It stops further processing of messages after writing them to remote log files, preventing duplicate logging or unintended rule matching.

---

## 8) How do you verify rsyslog is listening on the correct ports?

Use:

```bash
ss -tulnp | grep 514
```

Or netstat (if installed):

```bash
netstat -tulnp | grep 514
```

---

## 9) What firewall changes are required for a centralized syslog server?

Allow syslog ports:

* UDP 514
* TCP 514

Example:

```bash
firewall-cmd --permanent --add-port=514/udp
firewall-cmd --permanent --add-port=514/tcp
firewall-cmd --reload
```

---

## 10) How do you generate test log messages on a client machine?

Use the `logger` command:

```bash
logger -p auth.info "Test authentication message"
logger "General test message"
```

---

## 11) How did you validate end-to-end forwarding worked?

On the server:

* confirmed the client directory appears under `/var/log/remote/`
* confirmed log lines arrived in `/var/log/remote/client01/logger.log`
* confirmed correct message count for scripted test:

  * 6 facilities × 6 priorities = **36 messages**

---

## 12) What is logrotate and why was it configured?

logrotate manages log file growth and disk usage by rotating, compressing, and retaining logs. It prevents `/var/log` (or remote log storage) from filling the disk.

---

## 13) Why send HUP to rsyslog after rotation?

Rsyslog may keep file handles open. Sending `HUP` helps it reopen log files after rotation:

```conf
postrotate
  /bin/kill -HUP `cat /var/run/rsyslogd.pid 2> /dev/null` 2> /dev/null || true
endscript
```

---

## 14) What role can SELinux play in rsyslog forwarding?

SELinux can block rsyslog network activity or writing into certain directories unless contexts/booleans are correct. In this lab:

```bash
setsebool -P rsyslog_can_network on
```

---

## 15) What is one security improvement for centralized logging in production?

Use encrypted transport:

* rsyslog over TLS (commonly TCP 6514)
* certificates + proper authentication modes
  Also restrict firewall sources to trusted subnets and apply strict permissions on log storage.

---
