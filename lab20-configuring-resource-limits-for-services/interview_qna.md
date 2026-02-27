# 🎤 Interview Q&A — Lab 20: Configuring Resource Limits for Services

## 1) How does systemd enforce resource limits on services?
systemd uses **cgroups (control groups)** to isolate and control resource usage per service. When you set directives like `CPUQuota` or `MemoryMax`, systemd writes those limits into the service’s cgroup.

---

## 2) What is `CPUQuota` and how is it interpreted?
`CPUQuota` sets a **CPU usage limit as a percentage**.  
Example:
- `CPUQuota=50%` means the service can use up to half of one CPU core worth of time (systemd distributes this across available CPUs but enforces quota time).

---

## 3) What does `MemoryMax` do?
`MemoryMax` sets a **hard memory limit** for the service’s cgroup. If the process exceeds the limit, it can be throttled or killed by the kernel OOM behavior within that cgroup.

---

## 4) What is `TasksMax`?
`TasksMax` limits the number of tasks (processes/threads) that a service can create. It’s a strong guardrail against fork bombs or runaway spawning.

---

## 5) Why did this lab enable CPU/Memory/Tasks/I/O accounting?
Accounting (`CPUAccounting=yes`, etc.) makes systemd track usage and expose metrics via:
- `systemctl status`
- `systemctl show --property=...`

Without accounting, you often won’t see usable usage fields in systemd output.

---

## 6) How can you check a service’s current memory usage and memory limit?
Use:
```bash
systemctl status <service>
````

or more precisely:

```bash
systemctl show <service> --property=MemoryCurrent,MemoryMax
```

---

## 7) What’s the difference between editing the unit file vs using a drop-in override?

* Editing unit file: changes the main definition and can be harder to manage across environments.
* Drop-in override (`/etc/systemd/system/<service>.service.d/*.conf`):

  * clean, modular
  * automation-friendly
  * easier rollback
  * best practice for fleet management

---

## 8) What do `IOReadBandwidthMax` and `IOWriteBandwidthMax` do?

They throttle disk I/O bandwidth for a service’s cgroup for a specific block device.

Example:

```ini
IOReadBandwidthMax=/dev/nvme0n1 10M
IOWriteBandwidthMax=/dev/nvme0n1 5M
```

---

## 9) Why did we verify the disk device name using `lsblk`?

Because cloud instances often use `nvme0n1` devices instead of `sda`. If the unit references the wrong device path, the I/O throttling configuration may not apply correctly.

---

## 10) How do you monitor resource usage via systemd without external tools?

Use:

```bash
systemctl show <service> --property=CPUUsageNSec,MemoryCurrent,TasksCurrent,IOReadBytes,IOWriteBytes
```

---

## 11) What does `CPUUsageNSec` represent?

It shows cumulative CPU time used by the service in nanoseconds since it started (or since accounting began). It can be converted into seconds:

* seconds = CPUUsageNSec / 1,000,000,000

---

## 12) Why automate resource limits with Ansible?

Automation ensures:

* consistency across systems
* repeatable deployments
* policy standardization per workload class
* reduced human error
* easier auditing and rollback

---

## 13) What are the risks of setting resource limits too low?

Services can:

* become unstable
* fail to start
* restart repeatedly due to timeouts
* experience latency spikes or degraded throughput
  So limits should be tuned based on real usage and monitoring.

---

## 14) What is the operational value of a resource dashboard script?

It provides:

* quick visibility of which services are active
* current resource usage metrics
* configured limits in one view
* recent service events via journald
  This improves incident response and capacity planning.

---

## 15) How does resource limiting improve security?

It reduces the blast radius of compromised or misbehaving services:

* prevents CPU starvation of the host
* prevents memory exhaustion system crashes
* limits process spawning and fork abuse
* limits I/O abuse that could degrade other workloads

```

