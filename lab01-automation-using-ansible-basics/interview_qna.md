# 🎤 Interview Q&A — Lab 01: Automation Using Ansible Basics

> Focus: Ansible fundamentals, ad-hoc commands, playbooks, idempotency, privilege escalation, templates, and user management at scale.

---

## 1) What is Ansible and why is it used in enterprise environments?
**Answer:**  
Ansible is an agentless automation and configuration management tool that uses SSH (or WinRM) to manage systems. Enterprises use it to standardize deployments, reduce human error, automate repetitive tasks, and apply Infrastructure as Code (IaC) practices for consistency across many servers.

---

## 2) What’s the difference between an Ansible ad-hoc command and a playbook?
**Answer:**  
- **Ad-hoc commands** run one task quickly across one or many hosts (e.g., `ansible all -m ping`).  
- **Playbooks** are YAML files describing multiple tasks and desired state, making automation repeatable, version-controlled, and scalable.

---

## 3) What does “agentless” mean in Ansible?
**Answer:**  
Agentless means Ansible does not require a running agent on managed nodes. It connects over SSH and executes modules remotely, which simplifies deployment and reduces maintenance overhead.

---

## 4) What is an inventory and why is it important?
**Answer:**  
Inventory is the list of managed hosts and groups (like `[webservers]`). It controls targeting and can also define variables like usernames, SSH keys, and Python interpreter paths. It’s essential for organizing systems and running automation against the correct targets.

---

## 5) What does `ansible all -m ping` actually do?
**Answer:**  
It uses the **ping module** to verify that Ansible can connect and run a module on each host. It tests SSH connectivity, authentication, and Python execution on the managed nodes.

---

## 6) What are Ansible facts and how are they collected?
**Answer:**  
Facts are system details gathered by Ansible (OS version, IP address, memory, CPU, etc.). They are collected using the `setup` module automatically at the start of most playbooks (Gathering Facts). Facts can be filtered, e.g., `filter=ansible_distribution*`.

---

## 7) Explain idempotency in Ansible.
**Answer:**  
Idempotency means running the same automation repeatedly results in the same desired state without causing unnecessary changes. For example, if `httpd` is already installed and running, a well-written playbook won’t reinstall it or restart services unnecessarily.

---

## 8) Why is `become: yes` commonly used in playbooks?
**Answer:**  
Many tasks (install packages, manage services, edit `/etc/sudoers.d/`, create system users) require root privileges. `become: yes` enables privilege escalation (similar to `sudo`) during task execution.

---

## 9) What is the difference between `shell` and `command` modules?
**Answer:**  
- `command` runs commands without a shell, so operators like pipes (`|`), redirects (`>`) won’t work.  
- `shell` runs through a shell, so you can use pipes and complex syntax.  
Security-wise, `command` is preferred when shell features aren’t required.

---

## 10) How did you verify that Apache was correctly deployed on the web servers?
**Answer:**  
I used the `uri` module to make HTTP requests against each node’s IP and checked for HTTP `status: 200` and server headers. This validates not only service status but also that port 80 is reachable and responding.

---

## 11) Why did you use templates (`.j2`) in the complete setup playbook?
**Answer:**  
Templates let you generate dynamic files using facts/variables (hostname, OS version, IP address, timestamp). This is useful for system documentation, compliance evidence, and standardized configuration outputs.

---

## 12) How do you manage user accounts at scale with Ansible?
**Answer:**  
Using the `user` module and structured variables (lists/dicts) like `users_to_create`. This enables consistent creation of users, group membership, shells, home directories, SSH keys, and permissions across many servers.

---

## 13) What is the purpose of `validate: 'visudo -cf %s'` in sudoers tasks?
**Answer:**  
It ensures the sudoers file is syntactically valid before applying it. If the file would break sudo configuration, the task fails safely, preventing lockouts due to invalid sudo rules.

---

## 14) Why do you sometimes use `--check --diff` with `ansible-playbook`?
**Answer:**  
`--check` simulates changes without applying them (dry-run).  
`--diff` shows what would change in managed files.  
Together, they help validate automation safely before applying changes in production.

---

## 15) In your cleanup playbook, why would archive tasks fail but the playbook still succeed?
**Answer:**  
If users don’t exist or their home directories are missing, an archive task might fail with “cannot stat”. Using `ignore_errors: yes` allows the playbook to continue and still complete cleanup steps, which is realistic in environments where some resources may already be removed.

---
