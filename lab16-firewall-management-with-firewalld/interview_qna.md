# 🎤 Interview Q&A — Lab 16: Firewall Management with firewalld (Ansible)

## 1) What is firewalld and what is its main design concept?
firewalld is a dynamic firewall manager for Linux that uses a **zone-based architecture**. Zones define trust levels and control which services/ports/sources are allowed on an interface.

---

## 2) What is a firewalld “zone”?
A zone is a predefined or custom policy boundary (like `public`, `internal`, `trusted`) that controls:
- allowed services
- allowed ports
- allowed sources
- rich rules
- interface bindings

---

## 3) Why is zone-based firewalling useful in enterprise environments?
It supports segmentation and least privilege. Different systems (web vs database) can have different firewall posture consistently, and interfaces can be bound to zones for safe defaults.

---

## 4) How did you automate firewalld changes in this lab?
Using **Ansible playbooks** with the `firewalld` module to:
- install firewalld
- start/enable service
- create zones
- enable services/ports
- add sources
- apply rich rules
- configure port forwarding and rate limits

---

## 5) What does “permanent” vs “immediate” mean in the Ansible firewalld module?
- `permanent: yes` writes changes to disk so they persist after reboot.
- `immediate: yes` applies changes instantly at runtime.

In this lab, both were used to ensure persistence + live application.

---

## 6) What is a “rich rule” in firewalld?
A rich rule is an advanced rule syntax allowing more granular logic than basic service/port enabling — examples include:
- source-based allow/deny
- port ranges
- protocol-specific rules
- rate limiting
- port forwarding

---

## 7) Give an example of a rich rule used in this lab.
Allow SSH from only `192.168.1.0/24` on web servers:
```text
rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept
````

---

## 8) How did you restrict MySQL access to only the web server?

On db1, created the `secure-db` zone and allowed MySQL only from `192.168.1.10`:

```text
rule family="ipv4" source address="192.168.1.10" service name="mysql" accept
```

Then dropped all other MySQL attempts via public zone drop rule:

```text
rule service name="mysql" drop
```

---

## 9) How did you validate that a port was blocked?

Two ways:

1. Control-node connectivity test script using `/dev/tcp` with timeout.
2. Ansible playbook using `wait_for` + `assert` to confirm port `9999` is not reachable.

---

## 10) Why did the DB node show zone `database` for `eth0` while web node stayed in `public`?

Because the playbook explicitly assigned `eth0` on the DB server to the `database` zone:

```yaml
firewalld:
  interface: eth0
  zone: database
```

The web server remained in `public` based on default zone policy.

---

## 11) How do you check the active zone and rules directly from CLI?

Common commands:

```bash
firewall-cmd --get-default-zone
firewall-cmd --get-active-zones
firewall-cmd --list-all
firewall-cmd --list-all-zones
firewall-cmd --list-rich-rules
```

---

## 12) What is the purpose of enabling `LogDenied=all` in firewalld?

It logs denied traffic, which helps:

* detect scanning attempts
* troubleshoot access problems
* support security monitoring and auditing

---

## 13) How did you integrate firewall logs into log management?

The lab added rsyslog rules to write firewall matches into:

* `/var/log/firewall-rejected.log`
* `/var/log/firewall-accepted.log`

And created logrotate policy `/etc/logrotate.d/firewall-logs`.

---

## 14) What is `AllowZoneDrifting` and why is it a security concern?

`AllowZoneDrifting` allows traffic to drift between zones in certain scenarios. firewalld warns it is insecure and will be removed in the future. In secure environments, you typically want strict zone boundaries.

---

## 15) What is a real-world advantage of using Ansible for firewall management?

* consistent deployment across many hosts
* reduced human error and config drift
* version-controlled firewall policy
* faster rollout during incidents or security changes
* repeatable testing and audit evidence (reports + playbook output)

---
