# 🎤 Interview Q&A — Lab 14: Configuring Chrony for NTP Synchronization

## 1) What is Chrony and why is it used instead of older NTP daemons?
Chrony is a modern NTP client/server implementation designed for accuracy and stability, especially on systems with intermittent connectivity or variable network conditions. It is commonly preferred over older ntpd on modern Linux distributions.

---

## 2) What is the purpose of `iburst` in Chrony configuration?
`iburst` speeds up initial synchronization by sending a burst of packets when the server is reachable, improving time sync quickly after startup.

---

## 3) How do you confirm Chrony is installed on an RPM-based system?
Use:
```bash
rpm -qa | grep chrony
````

---

## 4) How do you check if Chrony service is running and enabled at boot?

```bash
systemctl status chronyd
systemctl is-enabled chronyd
```

---

## 5) What does `chrony sources -v` show?

It shows time sources and their states:

* `^*` = current best source
* `^+` = usable sources combined
* `^-` = sources not used currently
  It also shows reachability and offset/error values.

---

## 6) What does `chrony tracking` tell you?

It reports overall synchronization status like:

* stratum
* reference source
* system time offset
* RMS offset
* frequency/skew
* leap status

This is one of the best commands to validate NTP health.

---

## 7) Why configure multiple NTP servers?

For redundancy and reliability. If one server is unreachable or unstable, Chrony can select another source and maintain synchronization.

---

## 8) What is the difference between `minpoll` and `maxpoll`?

They control the polling interval range (how often Chrony queries time sources). Lower values poll more frequently; higher values reduce traffic but can slow convergence.

---

## 9) What does `makestep` do?

`makestep` allows Chrony to *step* (jump) the clock if the offset exceeds a threshold, typically during initial startup or when the clock drift is too large.

---

## 10) Why is time synchronization critical in security operations?

Accurate time is essential for:

* log correlation across hosts
* SIEM alert timeline accuracy
* certificate validation (TLS)
* authentication protocols (Kerberos)
* forensic investigations and incident response timelines

---

## 11) What does `allow 10.0.0.0/8` do in Chrony config?

It allows NTP clients from that subnet to query the machine if Chrony is acting as an NTP server (or if client access rules are applied). It’s required for internal time serving.

---

## 12) What firewall rule is commonly needed for NTP on RHEL/CentOS?

NTP uses UDP port 123. With firewalld you typically allow the `ntp` service:

```bash
firewall-cmd --permanent --add-service=ntp
firewall-cmd --reload
```

---

## 13) How do you verify Chrony is listening as an NTP server?

Check UDP 123:

```bash
netstat -ulnp | grep :123
```

(or use `ss -ulnp` in modern systems).

---

## 14) Why might `hwclock --compare` fail in cloud environments?

Some cloud VMs don’t expose a real RTC device in a way `hwclock` can access. This can be normal due to virtualization limitations.

---

## 15) What is one operational best practice for maintaining Chrony?

Create a monitoring or health-check script (like `chrony-monitor.sh`) to regularly verify:

* sources are reachable
* tracking offset is small
* service is running
* system clock is synchronized

---
