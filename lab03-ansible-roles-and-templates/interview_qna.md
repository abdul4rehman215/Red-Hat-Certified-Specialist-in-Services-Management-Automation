# 🎤 Interview Q&A — Lab 03: Ansible Roles and Templates

> Focus: Roles, structure, variable precedence, handlers, templates, cross-platform support, idempotency, and verification.

---

## 1) What is an Ansible role and why do we use it?
**Answer:**  
An Ansible role is a standardized structure to organize automation code (tasks, templates, vars, handlers, files) in a reusable and maintainable way. Roles reduce duplication, improve readability, and make playbooks easier to scale and share across teams.

---

## 2) What directories are commonly included in a role and what is each used for?
**Answer:**  
- `tasks/` → main automation logic  
- `handlers/` → event-driven actions (restart/reload services)  
- `templates/` → Jinja2 templates rendered with variables/facts  
- `files/` → static files copied to hosts  
- `defaults/` → default variables (lowest precedence)  
- `vars/` → role variables (higher precedence than defaults)  
- `meta/` → role metadata and dependencies  
- `tests/` → basic role test playbooks/inventory

---

## 3) What is the difference between `defaults/` and `vars/` in a role?
**Answer:**  
- `defaults/` contains values meant to be overridden easily (lowest precedence).  
- `vars/` contains role-specific variables that usually should not be overridden casually (higher precedence).  
In practice: put safe, override-friendly settings in `defaults/`, and OS/platform-specific settings in `vars/`.

---

## 4) How did you make this role work on both RedHat and Debian families?
**Answer:**  
I created OS-specific vars files (`vars/RedHat.yml` and `vars/Debian.yml`) and used:
```yaml
include_vars: "{{ ansible_os_family }}.yml"
````

Then I used conditional tasks for firewall handling (`firewalld` for RedHat, `ufw` for Debian).

---

## 5) What are Ansible handlers and when do they run?

**Answer:**
Handlers run when notified by tasks (using `notify:`). They run at the end of a play by default, and only if one or more tasks triggered them. This prevents unnecessary restarts and supports idempotent, efficient automation.

---

## 6) Why did you use templates instead of copying static configuration files?

**Answer:**
Templates allow dynamic configuration using facts and variables (hostname, IP, memory, OS, ports). This makes configuration consistent across servers while still adapting to differences between nodes.

---

## 7) What is Jinja2 in Ansible?

**Answer:**
Jinja2 is the templating language used by Ansible. It supports variable substitution, conditionals, loops, filters, and logic inside template files (`.j2`) that get rendered on the target host.

---

## 8) How did you verify Apache was working after deployment?

**Answer:**
I used multiple checks:

* `systemctl status httpd || systemctl status apache2` (service running)
* `uri` module to confirm HTTP status `200`
* `curl` to validate the generated HTML page content

---

## 9) What does idempotency mean and how did you test it in this lab?

**Answer:**
Idempotency means running automation multiple times produces the same result without reapplying changes unnecessarily. I tested it by running the same playbook twice; the second run showed `changed=0` in the recap.

---

## 10) Why is `gather_facts: yes` important for this lab?

**Answer:**
Facts are required because templates and OS-specific branching depend on variables like:

* `ansible_os_family`
* `ansible_hostname`, `ansible_fqdn`
* `ansible_default_ipv4.address`
* memory and CPU facts (`ansible_memtotal_mb`, `ansible_processor_vcpus`)

---

## 11) What is `post_tasks` and why did you use it?

**Answer:**
`post_tasks` run after roles/tasks. I used them to:

* verify Apache is responding via `uri`
* display deployment access details (`debug` output)

---

## 12) What is variable precedence and how did you demonstrate it here?

**Answer:**
Ansible resolves variables from multiple places in a defined order (host_vars/group_vars, extra vars, role vars, defaults, etc.). I demonstrated this using:

* `group_vars/webservers.yml` for production values
* `host_vars/web1.yml` to override web1 specifically
* `--extra-vars "apache_port=8080"` to override at runtime

---

## 13) Why did you include metadata (`meta/main.yml`) in the role?

**Answer:**
Metadata documents role intent, supported platforms, minimum Ansible version, and tags. It also supports dependency definition so roles can be composed and reused like building blocks.

---

## 14) What are common causes of “Role not found” errors?

**Answer:**

* Running playbook outside the project directory containing the role
* Role directory name mismatch
* Not setting `roles_path` when roles are stored in custom directories
  Fix: ensure the role directory exists and run from the project root or configure `roles_path`.

---

## 15) What are the most common template issues in Ansible?

**Answer:**

* Undefined variables (facts not gathered or vars not set)
* Incorrect Jinja2 syntax
* Quoting/escaping issues in HTML/config templates
  Fix: run `--syntax-check`, enable verbose output `-v`, and validate variables with debug tasks.

---
