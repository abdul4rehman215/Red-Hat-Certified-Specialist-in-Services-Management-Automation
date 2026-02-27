# 🛠️ Lab 11 — Troubleshooting Guide (Samba / SMB File Sharing)

> This troubleshooting guide covers the most common Samba problems encountered during installation, share creation, authentication, SELinux enforcement, CIFS mounting, and Windows/Linux client access.

---

## Issue 1: Cannot connect to Samba shares (timeout / connection refused)

### ✅ Symptoms
- `smbclient` fails to connect
- Windows cannot browse `\\SERVER\share`
- Errors like:
  - `Connection refused`
  - `NT_STATUS_HOST_UNREACHABLE`
  - `No route to host`
  - `Connection timed out`

### 🔎 Likely Causes
- Samba services not running
- firewall not allowing Samba
- wrong IP/hostname resolution
- SMB ports not listening

### ✅ Fix Steps

#### 1) Verify Samba services
```bash
sudo systemctl status smb nmb
````

#### 2) Verify firewall services include samba

```bash
sudo firewall-cmd --list-services
```

**Expected (lab evidence):**

```text
cockpit dhcpv6-client samba ssh
```

#### 3) Confirm Samba ports are listening

```bash
sudo netstat -tulpn | grep -E '(139|445)'
```

**Expected (lab evidence):**

```text
tcp        0      0 0.0.0.0:139             0.0.0.0:*               LISTEN      2510/smbd
tcp        0      0 0.0.0.0:445             0.0.0.0:*               LISTEN      2510/smbd
```

#### 4) Restart Samba if needed

```bash
sudo systemctl restart smb nmb
```

---

## Issue 2: Samba config syntax error (service won’t start)

### ✅ Symptoms

* `smb` service fails after restart
* `systemctl status smb` shows failure
* logs show parse issues

### 🔎 Likely Causes

* malformed `/etc/samba/smb.conf`
* duplicate or conflicting parameters

### ✅ Fix Steps

#### 1) Validate config before restart

```bash
sudo testparm
sudo testparm -s
```

If errors appear, correct the config then re-test.

#### 2) View Samba logs

```bash
sudo tail -50 /var/log/samba/log.smbd
sudo tail -50 /var/log/messages
```

---

## Issue 3: Authentication failures (NT_STATUS_LOGON_FAILURE)

### ✅ Symptoms

* `smbclient` prompts for password then fails
* Windows login fails for the share
* error:

  * `NT_STATUS_LOGON_FAILURE`
  * `Access denied`

### 🔎 Likely Causes

* Linux user exists but Samba user not created
* Samba user created but not enabled
* wrong password
* user not in allowed group (`valid users`)
* user has no permission on directory

### ✅ Fix Steps

#### 1) Verify Samba user exists

```bash
sudo pdbedit -L
```

#### 2) (Re)set Samba password

```bash
sudo smbpasswd sambauser1
```

#### 3) Ensure Samba account is enabled

```bash
sudo smbpasswd -e sambauser1
```

#### 4) Verify group membership (for group-restricted shares)

```bash
groups sambauser1
```

**Lab evidence example:**

```text
sambauser1 : sambauser1 sambausers
```

---

## Issue 4: “Permission denied” when writing to a share

### ✅ Symptoms

* Can connect, can list files, but cannot write
* Write fails from Linux mount or Windows copy
* errors:

  * `NT_STATUS_ACCESS_DENIED`
  * `Permission denied`

### 🔎 Likely Causes

* directory permissions wrong
* directory ownership mismatched
* `valid users` blocks user
* SELinux blocking access
* share set to read-only

### ✅ Fix Steps

#### 1) Check share definition in smb.conf

Look at:

* `read only`
* `writable`
* `guest ok`
* `valid users`
* `force user`
* `force group`

#### 2) Check filesystem perms and ownership

```bash
ls -la /srv/samba/
ls -la /srv/samba/public
ls -la /srv/samba/private
ls -la /srv/samba/team
ls -la /srv/samba/users
```

**Lab evidence:**

```text
drwxrwxrwx  2 nobody nobody  48 Feb 27 16:45 public
drwxrwx---  2 root  teamusers 41 Feb 27 16:45 team
drwxrwx---  2 root  sambausers 45 Feb 27 16:45 private
```

#### 3) Check SELinux context

```bash
ls -Z /srv/samba/
```

Expected type should be `samba_share_t`.

#### 4) Apply SELinux context if incorrect

```bash
sudo semanage fcontext -a -t samba_share_t "/srv/samba(/.*)?"
sudo restorecon -R /srv/samba/
```

If `semanage` missing:

```bash
sudo dnf install -y policycoreutils-python-utils
```

---

## Issue 5: SELinux is blocking Samba (AVC denials)

### ✅ Symptoms

* Everything looks correct, but access still denied
* `/var/log/audit/audit.log` shows AVC denials

### ✅ Fix Steps

#### 1) Check recent denials

```bash
sudo ausearch -m avc -ts recent | grep samba
```

#### 2) Confirm booleans are enabled

```bash
sudo getsebool -a | grep samba
```

In this lab we enabled:

```bash
sudo setsebool -P samba_enable_home_dirs on
sudo setsebool -P samba_export_all_rw on
```

---

## Issue 6: CIFS mount fails on Linux (`mount -t cifs`)

### ✅ Symptoms

* `mount error(13): Permission denied`
* `mount error(112): Host is down`
* `No such file or directory`

### 🔎 Likely Causes

* missing `cifs-utils`
* wrong credentials / options
* firewall blocking
* SMB ports blocked

### ✅ Fix Steps

#### 1) Install CIFS tools

```bash
sudo dnf install -y cifs-utils
```

#### 2) For guest public share

```bash
sudo mount -t cifs //SERVER/public /mnt/samba-test -o guest,uid=1000,gid=1000
```

#### 3) For authenticated share

```bash
sudo mount -t cifs //SERVER/private /mnt/samba-test -o username=sambauser1
```

It will prompt for password.

#### 4) Check kernel logs for mount hints

```bash
dmesg | tail -30
```

---

## Issue 7: “SMB1 disabled — no workgroup available”

### ✅ Symptoms

* `smbclient -L` shows:

  * `SMB1 disabled -- no workgroup available`

### ✅ Explanation

This is normal in modern secure Samba setups. SMB1 is insecure and is commonly disabled. Share listing still works.

---

## Issue 8: Windows can’t access share but Linux can

### 🔎 Likely Causes

* Windows firewall blocks outbound SMB
* wrong network profile on Windows (public/private)
* incorrect credentials caching in Windows
* DNS/NetBIOS discovery mismatch

### ✅ Fix Steps

* Test direct UNC path:

  * `\\SERVER_IP\public`
* Clear cached creds in Windows:

  * Credential Manager → remove old Samba creds
* Ensure Windows allows SMB client and outbound 445
* If discovery fails, use IP directly rather than NetBIOS name

---

## ✅ Quick Recovery Checklist

If Samba breaks mid-lab, these commands restore sanity fast:

# Validate configuration
```
sudo testparm -s
```

# Restart services
```
sudo systemctl restart smb nmb
```

# Verify listening ports
```
sudo netstat -tulpn | grep -E '(139|445)'
```

# Verify firewall
```
sudo firewall-cmd --list-services
```

# Verify SELinux contexts
```
ls -Z /srv/samba/ | head
```

# Verify Samba user database
```
sudo pdbedit -L
```

---

## 🔐 Strong Security Note (Lab-Relevant)

* A `777` public share is convenient for labs but **not recommended** for production.
* Prefer:

  * group-based access (`chmod 2770`)
  * controlled membership + ACLs
  * disable guest access unless required
  * keep SMB1 disabled
  * monitor logs (`/var/log/samba/`)
  * enforce SELinux contexts and avoid permissive workarounds

---
