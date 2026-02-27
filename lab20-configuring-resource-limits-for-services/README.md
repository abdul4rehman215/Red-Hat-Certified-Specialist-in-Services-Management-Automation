# 🧪 Lab 20: Configuring Resource Limits for Services

In this lab, I configured **systemd resource limits** (cgroups-based controls) to prevent services from over-consuming CPU, memory, tasks (processes), and disk I/O. I also automated resource-limit deployment using **Ansible**, and built monitoring + alerting scripts using `systemctl` and `journalctl`.

This lab includes:
- ✅ Creating **custom services** designed to consume or simulate resource usage
- ✅ Enforcing limits with systemd directives like `CPUQuota`, `MemoryMax`, `TasksMax`, `IOReadBandwidthMax`, `IOWriteBandwidthMax`
- ✅ Applying **drop-in overrides** (`/etc/systemd/system/<service>.service.d/*.conf`)
- ✅ Automating service creation + limits using **Ansible templates**
- ✅ Monitoring dashboards + log analyzers + threshold alerts via scripts

> **Note:** All work was performed in a **cloud lab environment** on **CentOS/RHEL 8/9** using a `centos` user with sudo access.

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Define resource limits for services using systemd unit files
- Apply and validate limits using systemd/cgroups accounting fields
- Automate deployment of resource-limited services across systems using Ansible
- Monitor resource utilization using `systemctl show` and `journalctl`
- Implement alerting + dashboards for operational visibility
- Apply best practices for service stability and multi-service coexistence

---

## ✅ Prerequisites

- Linux system administration basics
- Comfort with systemd service management (`systemctl`)
- YAML familiarity (Ansible)
- Basic understanding of CPU, memory, and I/O concepts
- Comfort using text editors (`nano`)

---

## 🧰 Lab Environment

| Component | Details |
|---|---|
| OS | CentOS/RHEL 8/9 |
| Shell | `-bash-4.2$` |
| User | `centos` (sudo access) |
| Service Manager | systemd |
| Automation | Ansible installed |
| Testing | Localhost services + simulated workloads |

---

## 🗂️ Repository Structure

```text
lab20-configuring-resource-limits-for-services/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── scripts/
│   ├── resource-test.sh
│   ├── webserver-sim.sh
│   ├── detailed-resource-monitor.sh
│   ├── resource-log-analyzer.sh
│   ├── resource-threshold-monitor.sh
│   └── resource-dashboard.sh
├── systemd/
│   ├── resource-test.service
│   └── webserver-sim.service
└── ansible-resource-limits/
    ├── inventory.ini
    ├── resource-limits-playbook.yml
    ├── advanced-resource-management.yml
    └── templates/
        ├── service-template.j2
        └── resource-override.j2
````

---

## 🧠 Key systemd Resource Controls Used

### Core limits

* **CPUQuota** → Caps CPU usage per service (percentage)
* **MemoryMax** → Hard memory cap for the service
* **TasksMax** → Limits number of processes/threads
* **IOReadBandwidthMax / IOWriteBandwidthMax** → Throttles disk I/O bandwidth
* **IOWeight** → Relative I/O priority

### Accounting (visibility)

* **CPUAccounting=yes**
* **MemoryAccounting=yes**
* **TasksAccounting=yes**
* **IOAccounting=yes**

These allow `systemctl status` / `systemctl show` to report actual usage.

---

## ✅ Tasks Overview (What I Performed)

### ✅ Task 1: Define Resource Limits in systemd Unit Files

#### 1.2 Create a CPU+Memory consumer test service

* Created `/opt/testservice/resource-test.sh` to:

  * burn CPU in a loop
  * allocate a test memory file (`/tmp/memory_test`)
* Built `resource-test.service` with:

  * `CPUQuota=50%`
  * `MemoryMax=100M` (then later overridden by drop-in automation)
  * `TasksMax=10`
  * resource accounting enabled

#### 1.4 Create a second service with I/O throttling

* Created `/opt/testservice/webserver-sim.sh` to:

  * simulate request logging in `/tmp/webserver.log`
  * rotate logs after reaching a line threshold
* Built `webserver-sim.service` with:

  * `CPUQuota=75%`
  * `MemoryMax=200M`
  * `TasksMax=20`
  * `IOReadBandwidthMax` and `IOWriteBandwidthMax` applied to the correct disk device
* Verified disk device with `lsblk` and used `/dev/nvme0n1` (common on cloud instances)

---

### ✅ Task 2: Automate Resource Limits Using Ansible

#### 2.1 Inventory setup

* Created a local inventory (`localhost ansible_connection=local`)
* Structured groups for `webservers` and `databases` for scalability

#### 2.2 Main resource-limits playbook

* Generated services using a **Jinja2 unit template** (`service-template.j2`)
* Built resource-limited services:

  * `nginx-limited.service`
  * `database-sim.service`
* Included a monitoring helper script (`service-resource-monitor.sh`)
* Installed `nginx` to satisfy service ExecStart dependency (real-world fix)

#### 2.3 Advanced resource management playbook

* Used system capacity (RAM) to dynamically select a profile: `low / medium / high`
* Applied **drop-in overrides** at:

  * `/etc/systemd/system/<service>.service.d/resource-limits.conf`
* Created a cron job to run monitoring every 5 minutes and log to `/var/log/service-resources.log`

---

### ✅ Task 3: Monitor Resource Utilization

#### Monitoring methods used

* `systemctl status` to view:

  * Memory current vs limit
  * task count vs limit
* `systemctl show --property=...` to extract:

  * `CPUUsageNSec`, `MemoryCurrent`, `TasksCurrent`, `IOReadBytes`, `IOWriteBytes`
* `journalctl -u <service>` for service logs and lifecycle events
* Custom scripts created:

  * **detailed-resource-monitor.sh** (human-friendly usage report)
  * **resource-log-analyzer.sh** (find service restarts + limit events)
  * **resource-threshold-monitor.sh** (alerts if thresholds exceeded)
  * **resource-dashboard.sh** (live terminal dashboard)

---

## ✅ Validation Checklist

I verified correctness using:

* `systemctl list-unit-files | grep ...` to confirm services exist/enabled
* `systemctl status <services>` to confirm limits are enforced and accounting is enabled
* `systemctl show <service> --property=...` to confirm current usage metrics
* `journalctl -u <service>` to verify service starts and produces logs
* dashboard script output to confirm operational monitoring works

---

## 🧠 What I Learned

* systemd resource controls are **production-grade guardrails** to prevent noisy-neighbor issues
* accounting must be enabled to get measurable output from systemd/cgroups
* drop-in overrides are safer than editing unit files directly (clean automation + rollback)
* Ansible templates help standardize resource policy across service fleets
* monitoring is part of resource control — limits without visibility are risky

---

## 🌍 Real-World Relevance

This lab mirrors enterprise practices used to:

* prevent resource starvation on multi-tenant servers
* restrict blast radius of misbehaving services
* support stable system operations and predictable performance
* enforce guardrails similar to container platforms (Kubernetes/Docker resource limits)

---
