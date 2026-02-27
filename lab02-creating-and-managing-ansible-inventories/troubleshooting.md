# 🛠️ Troubleshooting Guide — Lab 02: Creating and Managing Ansible Inventories

> This document captures common inventory-related problems and the exact commands used to validate and fix them.

---

## 1) Inventory Not Parsing / Wrong Format Errors

### ✅ Symptoms
- `ansible-inventory` shows missing groups/hosts
- Ansible can’t find hosts when running `ansible all -m ping`
- Inventory appears empty or only shows `ungrouped`

### 🔍 Common Causes
- Wrong inventory path
- Syntax errors (INI/YAML indentation)
- File extension mismatch (less common, but can matter for auto-detection)
- Inventory plugin confusion (Ansible tries multiple parsers)

### ✅ Fix / Validation

# Always validate what Ansible "sees"
```
ansible-inventory -i production_inventory.ini --list
ansible-inventory -i inventory.yml --list
```

# Graph view to confirm group membership
```
ansible-inventory -i production_inventory.ini --graph
ansible-inventory -i inventory.yml --graph
````

---

## 2) YAML Inventory Indentation / Syntax Issues

### ✅ Symptoms

* YAML inventory fails to load
* Errors like:

  * `mapping values are not allowed`
  * `found character that cannot start any token`

### 🔍 Common Causes

* Incorrect indentation (YAML is indentation-sensitive)
* Tabs instead of spaces
* Mixing lists and dictionaries incorrectly

### ✅ Fix / Validation

# Validate YAML syntax quickly
```
python3 -c "import yaml; yaml.safe_load(open('inventory.yml')); print('YAML OK')"
```

# Confirm Ansible can render YAML inventory
```
ansible-inventory -i inventory.yml --list
```

---

## 3) Host Variables Missing / Incorrect Connections

### ✅ Symptoms

* SSH connects to wrong IP
* Host shows `ansible_host` missing
* Playbooks fail with `UNREACHABLE`

### 🔍 Common Causes

* Missing `ansible_host` variable
* Incorrect `ansible_user`
* Wrong key file assigned in group vars
* Conflicting host/group vars

### ✅ Fix / Validation

# Inspect resolved variables per host
```
ansible-inventory -i production_inventory.ini --host web01
ansible-inventory -i production_inventory.ini --host web03
```

```
ansible-inventory -i inventory.yml --host web01
```

---

## 4) SSH Connectivity Problems (Inventory Looks Fine but Ping Fails)

### ✅ Symptoms

* `ansible all -m ping` returns `UNREACHABLE`
* `Permission denied (publickey)`
* Timeout / no route to host

### 🔍 Common Causes

* SSH key missing or wrong permissions
* Host unreachable due to firewall/security group
* DNS name not resolvable (if using hostnames)
* Incorrect `ansible_ssh_private_key_file`

### ✅ Fix / Validation

# Verbose ping shows SSH attempt details and inventory parsing decisions
```
ansible all -i production_inventory.ini -m ping -vvv | head -n 35
```

# Manual SSH test (if keys/hostnames are real)
```
ssh -i ~/.ssh/your_key user@hostname
```

---

## 5) Dynamic Inventory Returning Empty Results

### ✅ Symptoms

* AWS inventory script returns `{ "_meta": { "hostvars": {} } }`
* Plugin returns no hosts
* Errors about missing credentials or region

### 🔍 Common Causes

* AWS credentials not configured
* IAM permissions insufficient
* Wrong region(s) configured
* EC2 filters exclude all instances (e.g., not running)

### ✅ Fix / Validation

# Confirm AWS identity is valid
```
aws sts get-caller-identity
```

# Validate boto3 can reach EC2 API
```
python3 -c "import boto3; print(boto3.client('ec2').describe_instances()['Reservations'][0].keys())"
```

# Validate plugin inventory output
```
ansible-inventory -i aws_ec2.yml --list --export | head -n 25
```

---

## 6) Inventory Plugin / Collection Not Found (AWS EC2 Plugin)

### ✅ Symptoms

* `ERROR! couldn't resolve module/action 'amazon.aws.aws_ec2'`
* `Failed to load plugin`

### 🔍 Common Causes

* `amazon.aws` collection not installed
* Wrong plugin name or YAML structure

### ✅ Fix

# Install required collection
```
ansible-galaxy collection install amazon.aws
```

# Retest plugin
```
ansible-inventory -i aws_ec2.yml --list
ansible-inventory -i aws_ec2.yml --graph
```

---

## 7) Missing Debugging Tools (jq not installed)

### ✅ Symptoms

* Commands like `jq` fail:

  * `bash: jq: not found`

### ✅ Fix

# Check jq existence
```
command -v jq
```

# Install jq on RHEL/CentOS
```
sudo yum install -y jq
```

---

## 8) Variable Precedence Confusion

### ✅ Symptoms

* `http_port` not applying as expected
* group variable overrides host variable unexpectedly (or vice versa)
* environment vars not applied when targeting a parent group

### 🔍 Common Causes

* Conflicting variable definitions at different levels
* Host vars overriding group vars (expected)
* Parent group vars overriding unexpected scopes

### ✅ Fix / Validation

# Inspect final variables resolved for a host
```
ansible-inventory -i production_inventory.ini --host web03
```

# Compare with YAML inventory
```
ansible-inventory -i inventory.yml --host web03
```

---

## 9) Inventory Directory Behavior Confusion (Hybrid inventories)

### ✅ Symptoms

* `ansible-inventory -i production/ --list` output missing expected hosts
* Confusion about how Ansible merges multiple files in a directory

### 🔍 Common Causes

* Directory missing inventory files
* Invalid file inside directory prevents parse
* Wrong working directory / wrong relative path

### ✅ Fix / Validation

# Confirm directory contents
```
ls -l inventories/production
```

# List combined inventory
```
ansible-inventory -i production/ --list
```

# Graph view to confirm both cloud and on-prem groups exist
```
ansible-inventory -i production/ --graph
```

# Filter outputs by group
```
ansible-inventory -i production/ --list --limit 'env_production'
ansible-inventory -i production/ --list --limit 'onpremise'
```

---

## 10) Large Inventory Performance Issues

### ✅ Symptoms

* `ansible-inventory --list` becomes slow
* Playbook targeting `all` becomes slow at scale

### 🔍 Common Causes

* Very large host lists
* dynamic inventory API calls not cached
* heavy variable processing or grouping logic

### ✅ Fix / Validation

# Benchmark inventory parse time
```
time ansible-inventory -i large_inventory.ini --list > /dev/null
time ansible-inventory -i large_inventory.ini --list --yaml > /dev/null
```

 # Best practice: target smaller groups/patterns instead of all
 ```ansible webservers -i large_inventory.ini -m ping```

---

## ✅ Quick Recovery Checklist

# 1) Confirm inventory parses correctly
```
ansible-inventory -i production_inventory.ini --list
ansible-inventory -i inventory.yml --list
```

# 2) Confirm groups and membership
```
ansible-inventory -i production_inventory.ini --graph
```

# 3) Inspect variables for a host
```
ansible-inventory -i production_inventory.ini --host web01
```

# 4) Connectivity check
```
ansible all -i production_inventory.ini -m ping
```

# 5) Dynamic inventory checks (if used)
```
aws sts get-caller-identity
ansible-inventory -i aws_ec2.yml --list
```

---
