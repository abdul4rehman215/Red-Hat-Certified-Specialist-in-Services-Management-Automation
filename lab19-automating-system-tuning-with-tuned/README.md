# 🧪 Lab 19: Automating System Tuning with tuned

In this lab, I worked with **tuned** (Dynamic System Tuning Daemon) to apply performance profiles, create **custom tuned profiles** for different workloads, and automate profile deployment using **Ansible**.

This lab includes:
- ✅ Exploring built-in tuned profiles (`balanced`, `throughput-performance`, `latency-performance`)
- ✅ Applying profiles and verifying kernel parameter changes with `sysctl`
- ✅ Creating custom profiles:
  - `web-server-optimized`
  - `database-optimized`
- ✅ Building automation with Ansible:
  - role-based deployment
  - templates for custom profiles
  - verification + reporting playbooks
  - rollback playbook for safe change management
- ✅ Performance verification scripts and benchmarks (baseline + compare + CPU/I/O checks)

> **Note:** All work was performed in a **cloud lab environment** on **CentOS/RHEL 8/9** with `centos` user and sudo access.

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand the purpose of `tuned` for performance optimization
- Install and manage tuned services/profiles
- Apply tuned profiles and verify system parameter changes
- Create and customize tuned profiles under `/etc/tuned/`
- Automate tuned profile management using Ansible (roles + templates + playbooks)
- Generate tuning reports and verification logs for audit/operations
- Implement safe workflows using verification + rollback mechanisms

---

## ✅ Prerequisites

- Linux system administration basics
- Understanding of performance concepts (CPU, memory, I/O)
- Familiarity with YAML
- Basic Ansible knowledge (inventory, variables, roles, playbooks)
- Comfort reading `sysctl` values and kernel params

---

## 🧰 Lab Environment

| Component | Details |
|---|---|
| OS | CentOS/RHEL 8/9 |
| Shell | `-bash-4.2$` |
| User | `centos` (sudo access) |
| tuned | `tuned-2.21.0-1.el9.noarch`, `tuned-utils-2.21.0-1.el9.noarch` |
| Automation | Ansible available |
| Tools | `sysctl`, basic monitoring tools |

---

## 🗂️ Repository Structure

```text
lab19-automating-system-tuning-with-tuned/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── scripts/
│   ├── performance_test.sh
│   ├── automated_tuning.sh
│   ├── performance_analyzer.sh
│   ├── compare_performance.sh
│   ├── cpu_benchmark.sh
│   └── io_benchmark.sh
├── tuned-profiles/
│   ├── web-server-optimized/
│   │   └── tuned.conf
│   └── database-optimized/
│       └── tuned.conf
└── ansible-tuned-automation/
    ├── inventory/
    │   └── hosts
    ├── group_vars/
    │   ├── web_servers.yml
    │   └── database_servers.yml
    ├── playbooks/
    │   ├── deploy-tuned-profiles.yml
    │   ├── verify-tuned-performance.yml
    │   ├── rollback-tuned-profile.yml
    │   └── tuning_report.j2
    └── roles/
        └── tuned_management/
            ├── tasks/
            │   └── main.yml
            ├── handlers/
            │   └── main.yml
            └── templates/
                ├── web-server-optimized.conf.j2
                └── database-optimized.conf.j2
````

---

## ✅ Tasks Overview (What I Performed)

### ✅ Task 1: Install and Configure tuned Profiles for System Optimization

#### 🔎 1.1 Check tuned status + available profiles

* Verified tuned packages installed (`rpm -qa | grep tuned`)
* Checked service status (`systemctl status tuned`)
* Ensured tuned is enabled and running
* Listed profiles and confirmed current active profile:

  * `tuned-adm list`
  * `tuned-adm active`
  * `tuned-adm profile_info`

#### 🧠 1.2 Explore profile configs

* Reviewed profile directories under:

  * `/usr/lib/tuned/`
* Opened default profile config:

  * `/usr/lib/tuned/balanced/tuned.conf`
* Confirmed `/etc/tuned/` for custom profiles

#### ⚙️ 1.3 Apply profiles and verify kernel parameter changes

* Applied:

  * `throughput-performance`
  * `latency-performance`
* Verified impact using `sysctl` (example: `vm.swappiness`, scheduler parameters)
* Built a baseline script to collect system snapshot data across profiles and compared results using `diff`

#### 🧩 1.4 Create and test custom tuned profiles

Created:

* **web-server-optimized** (includes throughput-performance)

  * network socket buffer tuning
  * BBR congestion control
  * memory + file descriptor tuning
  * CPU performance governor
  * disk elevator tuning
* **database-optimized** (includes latency-performance)

  * low swappiness + aggressive dirty settings
  * shared memory settings (shmmax/shmall)
  * CPU governor
  * disk elevator tuning

Verified applied settings using `sysctl` after activating profiles.

---

### ✅ Task 2: Automate tuned Profile Deployment Using Ansible

#### 🧰 2.1 Build Ansible project structure

* Created:

  * inventory
  * group variables for web and DB server groups
* Used `localhost` as local target in inventory for lab testing

#### 🧱 2.2 Create Ansible role for tuned management

Role responsibilities:

* install tuned packages
* ensure tuned service enabled/running
* deploy custom tuned profile configs from templates (for non-default profiles)
* apply the selected profile
* verify active profile
* restart tuned when configs change (handler)

#### 📚 2.3 Create playbooks

* `deploy-tuned-profiles.yml`
  Deploy profile + collect system info + generate tuning report
* `verify-tuned-performance.yml`
  Collect active profile + sysctl + memory/load data, save metrics
* `rollback-tuned-profile.yml`
  Safely return to a default profile (`balanced`)

#### ▶️ 2.4 Execute automation

* Syntax check + dry-run (`--check`)
* Full deployment (`-v`)
* Verification playbook run and metrics output checked
* Rollback tested to ensure safe change management

---

### ✅ Task 3: Verify Performance Improvements

* Created scripts to capture and compare:

  * sysctl parameter snapshots
  * load + memory + process info
* Implemented:

  * performance analyzer report generator
  * profile comparison report generator
* Added benchmarking:

  * CPU benchmark (Python prime calculation)
  * I/O benchmark (`dd` write + read test)

---

## ✅ Validation Checklist

I verified correctness using:

* `tuned-adm active` (confirm profile is applied)
* `sysctl ...` (confirm kernel parameters changed as intended)
* Ansible outputs (successful role execution + reports generated)
* Performance script artifacts under `/tmp/`:

  * baseline reports
  * analyzer reports
  * comparison reports
  * benchmark results
* Rollback playbook confirms safe return to default settings

---

## 🧠 What I Learned

* `tuned` is an operational tool for applying **workload-specific** performance policies safely.
* Built-in profiles provide good defaults, but real environments often require **custom profile tailoring**.
* Automation matters:

  * consistent deployment (Ansible)
  * reporting for audit/compliance
  * rollback for safe operations
* Validation is not only “it applied” — it’s verifying:

  * sysctl values
  * service health
  * measurable changes via repeatable benchmarks

---

## 🌍 Real-World Relevance

This workflow mirrors enterprise operations where teams:

* maintain standard profiles per workload class (web vs database)
* deploy tuning centrally via automation
* generate evidence reports for audits
* ensure safe rollback in case of regressions

---

