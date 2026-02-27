# 🧪 Lab 08: Automating DHCP Server Configuration (Ansible)

## 📌 Lab Summary
This lab demonstrates how to **install, configure, and validate a DHCP server** using **Ansible automation**. The lab covers building an Ansible workspace, creating inventories and playbooks, templating DHCP configurations with Jinja2, deploying multi-scope DHCP configurations, validating syntax, testing real DHCP lease acquisition from a client node, monitoring leases and logs, and performing load/performance testing.

This lab was performed in a **college-provided cloud lab environment** and documented for a professional portfolio repository.

---

## 🎯 Objectives
By the end of this lab, I was able to:

- Install and configure a DHCP server using **Ansible automation**
- Create and manage DHCP scopes and DHCP options
- Deploy DHCP configuration using templates (Infrastructure as Code)
- Validate DHCP configuration syntax (`dhcpd -t`)
- Test real DHCP leasing using `dhclient`
- Monitor leases, logs, and firewall state
- Perform basic DHCP load testing and traffic capture with tcpdump
- Troubleshoot common DHCP issues (service start, leasing failures, firewall)

---

## ✅ Prerequisites
Before starting this lab, the following knowledge was required:

- Linux command line fundamentals
- DHCP concepts: IP addressing, subnetting, DHCP discover/offer/request/ack flow
- YAML basics
- SSH and remote management concepts
- Prior exposure to Ansible playbooks/inventory

---

## 🧠 Required Knowledge Areas
- TCP/IP fundamentals
- Linux system administration basics
- Text editing (nano/vim)
- Basic troubleshooting practices

---

## 🧩 Lab Environment
| Component | Details |
|----------|---------|
| Control Node | CentOS/RHEL 8 (Ansible installed) |
| Target Node | CentOS/RHEL 8 (DHCP server configured here) |
| Client Node | DHCP client for lease testing |
| Network | Isolated lab network for safe DHCP testing |
| DHCP Service | ISC DHCP (`dhcpd`) |
| DHCP Ports | UDP 67 (server), UDP 68 (client) |
| Firewall | firewalld |

---

## 🗂️ Repository Structure (Lab Folder)
```text
lab08-automating-dhcp-server-configuration/
├─ README.md
├─ commands.sh
├─ output.txt
├─ interview_qna.md
├─ troubleshooting.md
├─ inventory.ini
├─ dhcp-server-setup.yml
├─ dhcp-advanced-config.yml
├─ dhcp-monitoring.yml
├─ dhcp-client-test.yml
├─ dhcp-comprehensive-test.yml
├─ dhcp-load-test.yml
├─ test-dhcp-server.yml
├─ test-client-assignment.yml
└─ templates/
   ├─ dhcpd.conf.j2
   └─ dhcpd-advanced.conf.j2
````

---

## ✅ Tasks Overview (What I Performed)

### ✅ Task 1: Install and Configure the DHCP Server

**Goal:** Build a working Ansible deployment for the DHCP server and confirm the service is running.

**High-Level Actions:**

* Created Ansible project directory (`~/dhcp-automation`)
* Created INI inventory with:

  * `dhcp_servers` group
  * `dhcp_clients` group
  * shared SSH settings in `[all:vars]`
* Verified connectivity using `ansible all -m ping`
* Created `dhcp-server-setup.yml` to automate:

  * DHCP server package install (`dhcp-server`)
  * config backup creation (`/etc/dhcp/backup/`)
  * deployment of `/etc/dhcp/dhcpd.conf` using template
  * service enable/start (`dhcpd`)
  * firewall enablement (`dhcp` service)
* Verified:

  * `systemctl status dhcpd`
  * deployed config contents with `cat /etc/dhcp/dhcpd.conf`

---

### ✅ Task 2: Configure DHCP Scopes and Options (Advanced)

**Goal:** Deploy a multi-scope DHCP configuration and validate it before applying.

**High-Level Actions:**

* Created `dhcp-advanced-config.yml`:

  * defined `dhcp_scopes` list (main + guest networks)
  * defined `static_reservations` for fixed IP assignments
  * deployed advanced config template
  * validated syntax via `dhcpd -t -cf /etc/dhcp/dhcpd.conf`
  * restarted service using handlers
* Verified:

  * `dhcpd -t` output (successful parse)
  * service status remains active

---

### ✅ Task 3: Test IP Leasing + Monitoring

**Goal:** Confirm that DHCP leases are being issued to clients and visible in server logs/lease file.

**High-Level Actions:**

* Created `dhcp-client-test.yml`:

  * installed DHCP client tools
  * released existing lease (`dhclient -r`)
  * requested a new lease (`dhclient -v`)
  * verified the assigned IP address on the client
  * confirmed connectivity to DHCP server
  * tested DNS resolution from the client
* Created `dhcp-monitoring.yml`:

  * verified `dhcpd` active state
  * checked existence of lease file `/var/lib/dhcpd/dhcpd.leases`
  * extracted active lease evidence (binding state, client hostname)
  * extracted recent dhcpd logs from journald
  * verified firewall has dhcp enabled

---

### ✅ Task 4: Comprehensive Testing (Multi-Play Validation)

**Goal:** Build a multi-stage “validation pipeline” that verifies server and client state.

**High-Level Actions:**

* Created `dhcp-comprehensive-test.yml` containing multiple plays:

  * localhost orchestration
  * server tests (service running, config syntax, firewall, ports)
  * client tests (lease acquisition, IP presence, gateway test)
* The playbook referenced `include_tasks` files; missing tasks were created:

  * `test-dhcp-server.yml`
  * `test-client-assignment.yml`
* Executed the comprehensive test playbook and confirmed successful recaps.

---

### ✅ Task 5: Performance / Load Testing

**Goal:** Simulate multiple DHCP requests and capture DHCP traffic.

**High-Level Actions:**

* Created `dhcp-load-test.yml`:

  * installed tools (`nmap`, `tcpdump`, `dhcping`)
  * captured DHCP traffic to `/tmp/dhcp-traffic.log`
  * simulated multiple DHCP requests
  * summarized capture results (line count + sample output)
* Validated DHCP activity through tcpdump capture and output summary.

---

## ✅ Verification & Validation Checklist

The lab was validated using:

* `ansible all -m ping` successful
* `systemctl status dhcpd` shows **active (running)**
* `dhcpd -t -cf /etc/dhcp/dhcpd.conf` successful parse
* Client successfully received lease:

  * DHCPOFFER + DHCPACK from server
  * client bound to `192.168.1.101`
* DHCP lease visible on server in `/var/lib/dhcpd/dhcpd.leases`
* Journald shows DHCPDISCOVER/DHCPOFFER/DHCPREQUEST/DHCPACK entries
* tcpdump captured DHCP traffic during load test

---

## ✅ Result

✅ DHCP server was successfully deployed and validated using automation.

* DHCP service installed, enabled, and running
* DHCP configuration deployed via Ansible templates
* Multi-scope configuration applied (main + guest scope)
* Static reservations defined
* DHCP leasing confirmed from real client using `dhclient -v`
* Monitoring playbook confirmed leases and logs
* Load test captured and verified DHCP request/response traffic

---

## 💡 Why This Matters

DHCP is a critical network service. Automating DHCP deployment provides:

* **Scalability:** Rapid, repeatable deployments across environments
* **Consistency:** Eliminates configuration drift and human error
* **Reliability:** Safer updates using validation checks (`dhcpd -t`)
* **Auditability:** Playbooks serve as “living documentation”
* **Operational readiness:** Monitoring and testing are integrated into workflow

---

## 🌍 Real-World Applications

This lab maps directly to real enterprise tasks such as:

* rolling out DHCP servers in branch offices
* managing multi-scope DHCP configurations for segmented networks
* assigning fixed IP reservations to servers/printers/network appliances
* integrating DHCP validation into CI/CD or change workflows
* monitoring DHCP leasing activity for network troubleshooting

---

## ✅ Conclusion

In this lab, I automated the deployment of a DHCP server using Ansible:

* built inventory + playbooks + templates
* deployed base DHCP configuration and validated service health
* extended to multi-scope configuration with reservations
* tested real lease acquisition from a client machine
* created monitoring and comprehensive test workflows
* performed load testing with traffic capture

✅ Lab completed successfully on a cloud lab environment.
