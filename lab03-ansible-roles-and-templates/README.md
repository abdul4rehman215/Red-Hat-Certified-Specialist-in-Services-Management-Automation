# 🧪 Lab 03: Ansible Roles and Templates

> **Track:** Red Hat Certified Specialist in Services Management & Automation (Exam Labs)  
> **Lab Focus:** Building reusable Ansible roles, OS-specific variables, handlers, Jinja2 templates, and role-driven playbook deployments.

---

## 🧰 Lab Environment

| Item | Value |
|---|---|
| Control Node OS | CentOS/RHEL (Cloud Lab Environment) |
| Control Node User | `centos` |
| Working Directory Base | `/home/centos` |
| Managed Nodes | 2–3 target servers (mixed OS supported) |
| Connectivity | SSH keys pre-configured |

> **Note:** This lab was completed in a guided cloud lab environment and later organized into GitHub as part of my automation portfolio.

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand the concept and benefits of **Ansible roles** for code organization and reuse
- Create a structured Ansible role for **Apache HTTP Server** installation and configuration
- Implement **Jinja2 templates** for dynamic configuration management
- Execute playbooks that use custom roles to automate service deployment
- Apply best practices for role structure and template management
- Troubleshoot common issues with roles, templates, and permissions

---

## ✅ Prerequisites

- Linux command line fundamentals
- YAML syntax and structure understanding
- Comfort with:
  - playbook creation and execution
  - basic modules (`yum/apt`, `service`, `copy`, `file`)
  - inventory configuration
- Apache basics (packages/services/config dirs)
- Text editor proficiency (`vim`, `nano`, etc.)

---

## 📁 Repository Structure (Lab Folder)

```text
lab03-ansible-roles-and-templates/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── inventory.ini
    ├── deploy-apache.yml
    ├── site.yml
    ├── group_vars/
    │   └── webservers.yml
    ├── host_vars/
    │   └── web1.yml
    └── apache-role/
        ├── README.md
        ├── defaults/
        │   └── main.yml
        ├── files/
        ├── handlers/
        │   └── main.yml
        ├── meta/
        │   └── main.yml
        ├── tasks/
        │   └── main.yml
        ├── templates/
        │   ├── apache-custom.conf.j2
        │   └── index.html.j2
        ├── tests/
        │   ├── inventory
        │   └── test.yml
        └── vars/
            ├── RedHat.yml
            └── Debian.yml
````

---

## 🧩 Lab Tasks Overview (What was done)

### ✅ Task 1: Understanding Ansible Roles Structure

**Goal:** Learn role layout and why roles improve maintainability.

* Created project directory: `ansible-roles-lab`
* Initialized a role skeleton using:

  * `ansible-galaxy init apache-role`
* Installed `tree` to inspect structure (since minimal images may not include it)
* Reviewed purpose of each role directory:

  * `tasks/`, `handlers/`, `templates/`, `files/`, `vars/`, `defaults/`, `meta/`

---

### ✅ Task 2: Creating an Apache HTTP Server Role

**Goal:** Build a reusable role that supports multiple OS families.

* Defined default variables in:

  * `apache-role/defaults/main.yml`

* Created OS-specific variables:

  * `apache-role/vars/RedHat.yml`
  * `apache-role/vars/Debian.yml`

* Implemented role tasks:

  * include correct vars by OS family
  * install Apache package
  * enable and start service
  * deploy:

    * custom Apache config from template (RedHat)
    * index page from template
  * open firewall:

    * `firewalld` (RedHat)
    * `ufw` (Debian)
  * used handlers to restart/reload service

> **Small real-life fix applied (kept same intent):**
> `include_vars` was corrected to reference `{{ ansible_os_family }}.yml` matching file names (`RedHat.yml`, `Debian.yml`). Without the `.yml`, Ansible would fail.

---

### ✅ Task 3: Creating Jinja2 Templates

**Goal:** Dynamically generate configuration files based on facts/variables.

* Created Apache custom configuration template:

  * `apache-custom.conf.j2`
  * Includes security headers and performance tuning based on RAM
* Created dynamic index page template:

  * `index.html.j2`
  * Displays hostname, IP, OS, CPU, memory, deployment time, etc.

---

### ✅ Task 4: Creating & Executing Playbooks

**Goal:** Use the role in playbooks and verify deployment.

* Created `inventory.ini` for `webservers`

  * mixed OS nodes supported
  * used SSH keys + disabled strict host checking for lab convenience

* Created `deploy-apache.yml`

  * uses role `apache-role`
  * overrides vars like admin email and server name
  * includes post_tasks verification using `uri`

* Created `site.yml`

  * includes pre_tasks (update cache for both RedHat and Debian)
  * uses role with environment-specific vars
  * installs a health-check script and runs it after deployment

Executed:

* `ansible -i inventory.ini webservers -m ping`
* `ansible-playbook ... --check` first (dry-run)
* `ansible-playbook ... -v` for actual deployment
* `ansible-playbook ... site.yml` for full stack workflow

---

## ✅ Validation & Testing (What was verified)

* Verified service status on all nodes:

  * `systemctl status httpd || systemctl status apache2`
* Verified HTTP response using:

  * `ansible ... -m uri ... status_code=200`
* Verified generated web page content using:

  * `curl` and title extraction

---

## ⭐ Advanced Role Features & Best Practices

Implemented additional real-world features:

* Role metadata enhancements (`meta/main.yml`)
* Basic role testing playbook (`tests/test.yml`)
* Environment-specific variables:

  * `group_vars/webservers.yml` (production-like)
  * `host_vars/web1.yml` (development override)

---

## 🧠 What I Learned

* Why roles are the standard for professional Ansible projects:

  * reuse, readability, and scalability
* How to structure roles and separate:

  * defaults, vars, tasks, handlers, templates
* How to use Jinja2 templates to generate dynamic config + HTML
* How to support multiple OS families with OS-specific vars + conditional tasks
* How to verify deployments using:

  * `uri`, `systemctl`, health checks, and idempotency reruns

---

## 🌍 Why This Matters (Real-World Relevance)

* Roles are the backbone of enterprise automation:

  * consistent deployments across teams/environments
* Templates ensure configuration consistency while still allowing flexibility
* Cross-platform compatibility is essential in mixed fleets
* Verification steps and idempotency checks are critical for safe automation

---

## ✅ Result

* Reusable Apache role created successfully
* Jinja2 templates deployed dynamic configurations and web page content
* Role-driven deployments succeeded on mixed OS web servers
* Validation checks confirmed:

  * service running
  * HTTP returning 200
  * rendered content visible and correct
* Best practices added:

  * metadata, tests, group_vars/host_vars, and troubleshooting workflow

---
