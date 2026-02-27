# 🧪 Lab 02: Creating and Managing Ansible Inventories

> **Track:** Red Hat Certified Specialist in Services Management & Automation (Exam Labs)  
> **Lab Focus:** Static inventories (INI/YAML), host/group variables, dynamic inventory (AWS), hybrid inventory directories, validation + debugging.

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand the fundamentals of **Ansible inventory management**
- Create and configure **static inventory files** with multiple host groups
- Implement **dynamic inventories** to discover cloud resources automatically
- Test and validate inventory setups using `ansible-inventory` and ad-hoc Ansible commands
- Apply inventory best practices for **scalable automation environments**
- Troubleshoot common inventory issues (syntax, SSH, variable precedence, plugins)

---

## ✅ Prerequisites

- Basic Linux command line operations
- YAML syntax and file formatting basics
- Completed Lab 01 (or equivalent Ansible installation experience)
- Networking fundamentals (IP addressing, SSH)
- Familiarity with editors like `nano` / `vim`

### Required Knowledge Areas
- **Linux systems administration:** file permissions, directory navigation  
- **Network fundamentals:** SSH connectivity, ports  
- **Configuration management:** Infrastructure as Code (IaC) mindset

---

## 🧰 Lab Environment

| Component | Details |
|---|---|
| Control Node | CentOS/RHEL 8 with Ansible installed |
| Managed Nodes | 4 target systems (web, db, lb, monitoring roles) |
| SSH | Key-based authentication configured |
| Cloud Integration | AWS CLI available for dynamic inventory testing |
| Working Directory | `/home/ansible` |
| Interface Naming | `eth0` (as required) |
| Terminal Prompt | `-bash-4.2$` (as required) |

> **Note:** This lab was completed in a guided cloud lab environment and later organized into GitHub for portfolio documentation.

---

## 📁 Repository Structure (Lab Folder)

```text
lab02-creating-and-managing-ansible-inventories/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── inventories/
    │   └── production/
    │       ├── static_hosts.ini
    │       └── aws_ec2.yml
    ├── basic_inventory.ini
    ├── production_inventory.ini
    ├── inventory.yml
    ├── aws_ec2.yml
    ├── aws_ec2_inventory.py
    ├── validate_inventory.yml
    ├── debug_inventory.sh
    └── generate_large_inventory.py
````

---

## 🧩 Lab Tasks Overview (What was done)

### ✅ Task 1: Creating Static Inventory Files with Multiple Host Groups

**Goal:** Build foundational inventory skills using **INI inventory syntax**.

* Created working directory: `~/lab2-inventories`
* Built **basic inventory** (`basic_inventory.ini`) with groups:

  * `webservers`, `databases`, `monitoring`
* Validated inventory rendering using:

  * `ansible-inventory -i <file> --list`

---

### ✅ Task 1.2: Advanced Inventory with Variables

**Goal:** Use host/group variables to model a production environment.

* Created `production_inventory.ini` including:

  * host variables (ansible_host, ansible_user, ports)
  * group variables (`[webservers:vars]`, `[databases:vars]`)
  * environment group composition (`[production:children]`)
  * global production vars (`[production:vars]`)

Validated:

* list all inventory
* limit inventory output to a group
* render as YAML output

---

### ✅ Task 1.3: YAML Format Inventory

**Goal:** Build the same environment using **YAML inventory format**.

* Created `inventory.yml` with:

  * group children
  * hostvars for each host
  * group vars (webservers/databases)
  * environment grouping (`production`)

Validated using:

* `ansible-inventory --list`
* `ansible-inventory --host <host>`
* `ansible-inventory --graph`

---

## ☁️ Dynamic Inventory (AWS)

### ✅ Task 2: Implement Dynamic Inventories for Cloud Providers

**Goal:** Automatically discover resources in cloud environments.

#### Subtask 2.1: Custom AWS EC2 Dynamic Inventory Script

* Installed Python dependencies:

  * `boto3`, `botocore`
* Configured AWS credentials (local client config)
* Created dynamic inventory script:

  * `aws_ec2_inventory.py`
* Script behavior:

  * queries EC2 `describe_instances`
  * includes only running instances
  * sets `ansible_host` to public IP if present, else private IP
  * groups instances by:

    * tags (Environment/Application/Role/Owner/Name)
    * instance type

Validated using:

* `./aws_ec2_inventory.py --list`
* `ansible-inventory -i aws_ec2_inventory.py --list`

---

### ✅ Subtask 2.2: Built-in Ansible AWS EC2 Inventory Plugin

* Created plugin config `aws_ec2.yml` using:

  * `plugin: amazon.aws.aws_ec2`
  * regions filtering
  * keyed_groups by tag and AZ and type
  * compose for ansible_host and metadata
  * filters: running instances only
* Installed required collection:

  * `ansible-galaxy collection install amazon.aws`

Validated:

* `ansible-inventory -i aws_ec2.yml --list`
* `ansible-inventory -i aws_ec2.yml --graph`

---

## 🏢 Hybrid Inventory Setup (On-Prem + Cloud)

### ✅ Subtask 2.3: Inventory Directory Structure

**Goal:** Combine multiple inventory sources like real enterprise environments.

* Created:

  * `inventories/production/`
* Added:

  * `static_hosts.ini` (on-prem)
  * copied `aws_ec2.yml` (cloud)
* Validated combined inventory directory behavior:

  * `ansible-inventory -i production/ --list`
  * `ansible-inventory -i production/ --graph`
  * limited outputs by group:

    * `env_production` (cloud)
    * `onpremise` (on-prem)

---

## 🧪 Testing & Validation

### ✅ Task 3: Testing Inventory Setups Using Ansible Commands

* Ping tests with different inventory formats:

  * `ansible all -i production_inventory.ini -m ping`
  * `ansible webservers -i production_inventory.ini -m ping`
  * `ansible all -i inventory.yml -m ping`
* Fact collection and host data export:

  * `ansible ... -m setup --tree /tmp/facts`
  * verified `/tmp/facts` generated per-host JSON
* Group-limited commands:

  * disk usage checks for databases
  * OS family checks for webservers

---

## ✅ Inventory Validation Playbook

Created a playbook to validate and report:

* host IP, group membership, OS family
* ping success
* required variables existence via `assert`
* sudo capability check (`whoami` with `become`)

Playbook file:

* `validate_inventory.yml`

Executed on:

* static INI inventory
* YAML inventory
* verbose mode for detailed debugging

---

## 🧰 Debugging & Troubleshooting Toolkit

### ✅ Inventory debugging commands used

* Inventory parse inspection:

  * `ansible-inventory --list --yaml`
  * `python3 -m yaml.tool`
* Host variable inspection:

  * `ansible-inventory --host <host>`
* Graph view:

  * `ansible-inventory --graph`
* Duplicate/host key listing:

  * `jq '.["_meta"]["hostvars"] | keys'` (installed `jq` in lab)

### ✅ Debug helper script created

* `debug_inventory.sh`

  * generates a debug report:

    * structure graph
    * host list
    * groups list
    * connectivity test
    * sample host vars

---

## 📈 Large Inventory Performance Test

Created and tested inventory generation at scale:

* Script: `generate_large_inventory.py`
* Generated: `large_inventory.ini` (500 hosts)
* Benchmarked parse time using:

  * `time ansible-inventory ...`

---

## 🧠 What I Learned

* How Ansible inventories represent **real infrastructure**
* How to structure inventories using:

  * INI format (quick + common)
  * YAML format (more structured)
  * inventory directories (hybrid enterprise pattern)
* How to use variables effectively:

  * host vars vs group vars vs environment vars
* How dynamic inventory works in cloud:

  * custom scripts
  * built-in plugins (amazon.aws.aws_ec2)
* How to validate, debug, and scale inventories confidently

---

## 🌍 Why This Matters (Real-World Relevance)

* Enterprises run automation across **hundreds/thousands of hosts**
* Inventories must support:

  * role-based grouping (web/db/lb/monitoring)
  * environment separation (dev/stage/prod)
  * cloud elasticity (dynamic discovery)
  * hybrid deployments (on-prem + cloud)
* Strong inventory practices reduce failures and simplify collaboration across teams

---

## ✅ Result

* Static inventories built and validated (INI + YAML)
* AWS dynamic inventory tested (custom script + plugin)
* Hybrid inventory directory tested successfully
* Validation playbook executed successfully
* Debugging scripts and large-inventory performance testing completed

---
