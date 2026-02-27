# 🎤 Interview Q&A — Lab 19: Automating System Tuning with tuned

## 1) What is `tuned` and why is it used?
`tuned` is a daemon-based system tuning framework that applies **performance profiles** based on workload needs (latency, throughput, power saving). It automates kernel and subsystem tuning using predefined or custom profiles.

---

## 2) What is the difference between `tuned` and manually setting sysctl values?
- Manual sysctl changes are often **one-off** and easy to forget.
- `tuned` provides:
  - workload-based templates
  - consistent applied settings
  - profile switching and rollback
  - centralized management in enterprise environments

---

## 3) How do you view available tuned profiles?
```bash
tuned-adm list
````

---

## 4) How do you check which tuned profile is currently active?

```bash
tuned-adm active
```

---

## 5) What is the purpose of profile inheritance (include=...)?

It allows custom profiles to **reuse** settings from a base profile (like `throughput-performance`), then override or extend with additional sysctl, CPU, disk, and network tuning.

Example:

```ini
include=throughput-performance
```

---

## 6) Where are built-in tuned profiles stored on RHEL/CentOS?

Built-in profiles are typically stored in:

* `/usr/lib/tuned/`

Custom profiles are usually placed in:

* `/etc/tuned/`

---

## 7) Why is using `/etc/tuned/` preferred for custom profiles?

Because it separates custom admin-managed content from vendor-managed packages. Updates won’t overwrite `/etc/tuned/` profiles like they might with `/usr/lib/tuned/`.

---

## 8) What types of system settings can tuned profiles modify?

Common areas include:

* **sysctl kernel parameters** (memory, network, scheduling)
* **CPU governor / power policy**
* **disk scheduler / I/O behavior**
* network interface tuning and buffer sizes

---

## 9) What sysctl parameter did this lab use to demonstrate profile impact quickly?

`vm.swappiness` was used as an easy-to-observe change:

* balanced example: `60`
* throughput-performance example: `30`
* custom web profile example: `10`
* database profile example: `1`

---

## 10) Why would a web server profile tune network buffers and congestion control?

Web workloads often involve many concurrent connections and high throughput needs. Increasing socket buffers (`rmem_max`, `wmem_max`) and using a modern congestion control algorithm (like `bbr`) can improve throughput and connection handling.

---

## 11) Why would a database profile lower swappiness and dirty ratios?

Databases benefit from:

* keeping hot pages in RAM (low swappiness)
* controlling dirty page writeback behavior
* reducing unpredictable latency spikes caused by swapping or heavy flush bursts

---

## 12) What is the role of Ansible in tuned management?

Ansible provides:

* repeatable deployment of tuned profiles at scale
* templated configuration management
* verification workflows
* rollback automation
  This is important for consistency across environments (dev/stage/prod).

---

## 13) Why is a rollback playbook important in enterprise tuning?

Because tuning changes can cause regressions (latency spikes, unexpected behavior). A rollback playbook enforces safe change management by allowing systems to quickly return to a known stable profile.

---

## 14) How do you validate that tuning changes actually applied?

Validation methods used in this lab:

* `tuned-adm active` confirms profile activation
* `sysctl` confirms parameter values
* generated reports and metrics files provide audit evidence
* simple CPU and disk I/O benchmarks provide practical comparison

---

## 15) Why might CPU governor show “N/A” on cloud VMs?

Many cloud virtual machines do not expose CPU frequency scaling information to the guest OS. In such cases, `/sys/devices/system/cpu/cpu0/cpufreq/` may not exist, and tools/scripts will correctly report it as unavailable.
