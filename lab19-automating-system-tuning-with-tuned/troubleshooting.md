# 🛠️ Troubleshooting — Lab 19: Automating System Tuning with tuned

> This guide lists common issues when working with **tuned profiles**, **custom tuned.conf settings**, and **Ansible automation** for system tuning.

---

## ✅ Issue 1: `tuned-adm` command not found

### **Symptoms**
- Running `tuned-adm list` fails:
  - `command not found`

### **Likely Cause**
`tuned` package not installed.

### **Fix**
```bash
sudo dnf install tuned tuned-utils -y
sudo systemctl enable --now tuned
````

---

## ✅ Issue 2: tuned service is inactive or not running

### **Symptoms**

* `systemctl status tuned` shows `inactive (dead)` or `failed`

### **Likely Causes**

* service disabled
* crash due to profile errors
* profile contains invalid syntax

### **Fix**

1. Start and enable:

```bash id="1cv4et"
sudo systemctl enable tuned
sudo systemctl start tuned
```

2. Review logs:

```bash id="st0c4l"
sudo journalctl -u tuned --since "30 minutes ago" -l
```

3. Check active profile:

```bash id="jrr4x8"
tuned-adm active
```

---

## ✅ Issue 3: Custom profile does not appear in `tuned-adm list`

### **Symptoms**

* You created `/etc/tuned/<profile>/tuned.conf`
* But `tuned-adm list` does not show it

### **Likely Causes**

* wrong folder name
* missing `tuned.conf`
* incorrect permissions

### **Fix**

```bash id="sjyoj8"
sudo ls -la /etc/tuned/
sudo ls -la /etc/tuned/<profile>/
sudo cat /etc/tuned/<profile>/tuned.conf
```

Ensure:

* directory exists
* file is named exactly `tuned.conf`

Reload and re-check:

```bash id="de2c9z"
sudo systemctl restart tuned
tuned-adm list
```

---

## ✅ Issue 4: `tuned-adm profile <name>` applies, but sysctl values don’t change

### **Symptoms**

* `tuned-adm active` shows the profile
* But expected sysctl values remain unchanged

### **Likely Causes**

* tuned.conf syntax error
* sysctl parameters not supported on this kernel
* profile includes settings overridden by other layers

### **Fix**

1. Verify tuned profile info:

```bash id="ny2n1p"
tuned-adm profile_info <profile>
```

2. Validate sysctl values directly:

```bash id="78d6k1"
sysctl vm.swappiness
sysctl net.core.rmem_max
```

3. Restart tuned to re-apply:

```bash id="9ohc2j"
sudo systemctl restart tuned
```

4. Check tuned logs for parsing errors:

```bash id="6xq3hf"
sudo journalctl -u tuned --since "30 minutes ago" -l
```

---

## ✅ Issue 5: Custom profile tuning.conf causes tuned to fail

### **Symptoms**

* `systemctl status tuned` becomes `failed`
* Logs show profile parsing error

### **Likely Cause**

Invalid profile syntax or unsupported parameters.

### **Fix**

1. Temporarily switch to a known-safe profile:

```bash id="6kwlca"
sudo tuned-adm profile balanced
```

2. Fix profile syntax:

```bash id="l4z9dc"
sudo nano /etc/tuned/<profile>/tuned.conf
```

3. Restart tuned:

```bash id="x9dv5m"
sudo systemctl restart tuned
```

---

## ✅ Issue 6: Ansible playbook fails due to inventory or connection issues

### **Symptoms**

* `unreachable` or SSH/auth errors

### **Likely Causes**

* inventory host incorrect
* SSH keys missing (for remote nodes)
* wrong connection method

### **Fix (Local lab target)**

Use local connection:

```ini
localhost ansible_connection=local
```

Run:

```bash id="k33d2w"
ansible-playbook -i inventory/hosts playbooks/deploy-tuned-profiles.yml
```

---

## ✅ Issue 7: Ansible role runs but custom profile does not deploy

### **Symptoms**

* playbook succeeds
* but `/etc/tuned/<profile>/tuned.conf` not created

### **Likely Cause**

Role uses a `when:` condition that skips deployment for built-in profiles.
If `tuned_profile` is set to a built-in profile, template task will skip intentionally.

### **Fix**

Confirm variable:

```bash id="yhm6u1"
cat group_vars/web_servers.yml
```

Confirm files:

```bash id="4mfp6x"
sudo ls -la /etc/tuned/
sudo ls -la /etc/tuned/web-server-optimized/
```

---

## ✅ Issue 8: Playbook fails because template file is missing

### **Symptoms**

* task fails with:

  * `could not find or access 'tuning_report.j2'`

### **Likely Cause**

Referenced template does not exist in the expected path.

### **Fix**

Ensure the template exists:

```bash id="mc6a4e"
ls -la playbooks/tuning_report.j2
```

---

## ✅ Issue 9: CPU governor shows `N/A`

### **Symptoms**

* scripts output:

  * `CPU frequency scaling information not available`
  * or `N/A`

### **Cause**

Common on cloud VMs. cpufreq interfaces may not be exposed to the guest.

### **Fix**

This is expected behavior in many virtualized environments.
You can still validate tuning using sysctl values, load, and benchmarks.

---

## ✅ Issue 10: `dd` benchmarks fail or show slow performance

### **Symptoms**

* `dd` reports very low MB/s
* `oflag=direct` fails

### **Likely Causes**

* storage is throttled by the cloud environment
* direct I/O unsupported by the underlying filesystem/device
* competing workload on shared host

### **Fix**

Try without direct flags (less strict but works everywhere):

```bash id="k2bspc"
dd if=/dev/zero of=/tmp/testfile.bin bs=1M count=256
dd if=/tmp/testfile.bin of=/dev/null bs=1M
rm -f /tmp/testfile.bin
```

---

## ✅ Final Validation Checklist

Run these to confirm profile + automation success:

# tuned health
```
systemctl status tuned
tuned-adm active
tuned-adm list
```

# sysctl confirmation
```
sysctl vm.swappiness vm.dirty_ratio net.core.rmem_max net.core.wmem_max fs.file-max
```

# Ansible verification
```
ansible-playbook -i inventory/hosts playbooks/verify-tuned-performance.yml
```

# Rollback safety test
```
ansible-playbook -i inventory/hosts playbooks/rollback-tuned-profile.yml
tuned-adm active
```

Expected:

* tuned is active
* profile changes reflect in sysctl
* Ansible runs without failures
* rollback returns to `balanced` cleanly

---
