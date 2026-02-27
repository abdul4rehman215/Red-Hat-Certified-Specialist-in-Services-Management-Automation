# 🎤 Interview Q&A — Lab 02: Creating and Managing Ansible Inventories

> Focus: Inventory formats (INI/YAML), grouping strategy, variables, dynamic inventory, plugins, hybrid inventory, debugging and best practices.

---

## 1) What is an Ansible inventory?
**Answer:**  
An inventory is the source of truth listing the hosts Ansible can manage, along with host groups and variables. It tells Ansible *where* to run tasks and can define metadata like IPs, users, SSH keys, and ports.

---

## 2) What are the main inventory formats supported by Ansible?
**Answer:**  
Common formats include:
- **INI** (traditional and widely used)
- **YAML** (more structured and expressive)
- **Dynamic inventories** (scripts or plugins)
Ansible can also load inventories from directories containing multiple files.

---

## 3) What’s the difference between host variables and group variables?
**Answer:**  
- **Host variables** apply to a single host (e.g., `web03 http_port=8080`).  
- **Group variables** apply to all hosts in a group (e.g., `[webservers:vars] environment=production`).  
This reduces duplication and improves maintainability.

---

## 4) What does `[production:children]` mean in an INI inventory?
**Answer:**  
It defines a **parent group** named `production` and assigns other groups as its children. This lets you target `production` and automatically include `webservers`, `databases`, `loadbalancers`, and `monitoring`.

---

## 5) How do you validate an inventory before running playbooks?
**Answer:**  
Use `ansible-inventory` commands such as:
- `ansible-inventory -i <inventory> --list`
- `ansible-inventory -i <inventory> --graph`
- `ansible-inventory -i <inventory> --host <hostname>`
These confirm parsing, group membership, and variables.

---

## 6) What is `ansible-inventory --graph` useful for?
**Answer:**  
It shows the group hierarchy and membership visually. It’s great for verifying that hosts are correctly grouped and parent/child group relationships are correct.

---

## 7) When would you choose YAML inventory over INI inventory?
**Answer:**  
YAML is useful when the inventory is complex (nested groups, structured variables, lists) because it is more readable and supports richer data structures than INI.

---

## 8) What is a dynamic inventory and why is it important in cloud environments?
**Answer:**  
Dynamic inventory automatically discovers hosts from systems like AWS, Azure, or GCP. It matters because cloud environments change frequently (instances scaling up/down), so static host lists become outdated quickly.

---

## 9) What are two ways to implement AWS dynamic inventory in Ansible?
**Answer:**  
1) **Custom Python script** using `boto3` to query EC2 and output JSON inventory (`--list`).  
2) **Built-in inventory plugin** (`amazon.aws.aws_ec2`) using a YAML config file + Ansible collections.

---

## 10) What is the purpose of `keyed_groups` in the AWS EC2 inventory plugin?
**Answer:**  
`keyed_groups` automatically creates groups based on instance metadata such as:
- tags (Environment, Application)
- instance type
- availability zone  
This enables targeting “all prod instances” or “all t3.small nodes” without manual grouping.

---

## 11) What does `compose` do in an inventory plugin configuration?
**Answer:**  
It creates or transforms variables. For example:
- setting `ansible_host` to a public IP if available, else private IP  
It standardizes connection variables across discovered hosts.

---

## 12) What is a hybrid inventory and where is it used?
**Answer:**  
A hybrid inventory combines multiple sources (e.g., on-prem static inventory + cloud dynamic plugin). This is common in real enterprises running mixed infrastructure during cloud migration or multi-environment operations.

---

## 13) Why would `ansible-inventory` parsing say “declined parsing … verify_file() method”?
**Answer:**  
Ansible tries different inventory plugins (host_list, script, auto, ini, yaml). Some decline parsing if the file doesn’t match their expected format. It’s normal as long as the correct plugin (INI/YAML) successfully parses the file.

---

## 14) How do you troubleshoot variable precedence issues in inventory?
**Answer:**  
Inspect resolved variables using:
- `ansible-inventory --host <host>`
- `ansible <host> -m debug -a "var=hostvars[inventory_hostname]"`  
Also ensure variables aren’t conflicting between host vars, group vars, and parent group vars.

---

## 15) What are inventory best practices for production automation?
**Answer:**  
- Use **descriptive group names** by role (web/db/lb/monitoring)
- Separate environments (dev/stage/prod) via **separate files or directories**
- Prefer **group vars** to reduce duplication
- Avoid secrets in inventory; use **Ansible Vault**
- Regularly validate inventory with `ansible-inventory --list/--graph`
- Version control inventories and document structure

---
