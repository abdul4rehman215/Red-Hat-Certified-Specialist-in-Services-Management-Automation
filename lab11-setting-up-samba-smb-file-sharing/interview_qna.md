# 🎤 Lab 11 — Interview Q&A (Samba SMB File Sharing)

## 1) What is Samba and why is it used?
**Answer:** Samba is an open-source implementation of the SMB/CIFS protocol that enables file and print sharing between Linux/Unix systems and Windows clients. It allows Linux servers to act like Windows file servers.

---

## 2) Which two Samba services were enabled in this lab and what do they do?
**Answer:**
- **smb (smbd):** Provides file sharing and authentication over SMB (ports 445/139).
- **nmb (nmbd):** Provides NetBIOS name service and browsing support (legacy discovery, port 137/138).

---

## 3) What are the main ports used by Samba?
**Answer:**
- **TCP 445:** Direct SMB over TCP (modern Windows)
- **TCP 139:** SMB over NetBIOS (legacy)
- **UDP 137/138:** NetBIOS name service / browsing (used when nmbd is enabled)

In this lab, we confirmed listening ports:
- `139` and `445`.

---

## 4) What does `security = user` mean in smb.conf?
**Answer:** It means Samba requires user authentication for protected shares. Users must exist in Samba’s passdb (e.g., tdbsam) and authenticate to access non-guest shares.

---

## 5) What does `map to guest = bad user` do?
**Answer:** If a username is invalid (bad user), Samba maps the session to the **guest account** instead of failing immediately. This is commonly used for public shares where anonymous access is allowed.

---

## 6) What is the purpose of `guest ok = yes`?
**Answer:** It allows unauthenticated (guest) connections to that share. In this lab, `[public]` was configured for guest access.

---

## 7) How did you validate that smb.conf syntax was correct?
**Answer:** Using:
- `testparm`
- `testparm -s`

This loads the configuration and confirms all sections parse correctly.

---

## 8) What is the role of `valid users = @groupname`?
**Answer:** It restricts share access to members of a specified group.
Example from the lab:
- `[private]` → `valid users = @sambausers`
- `[team]` → `valid users = @teamusers`

---

## 9) What is the difference between Linux users and Samba users?
**Answer:** Samba users are mapped to existing Linux accounts but require separate Samba credentials stored in Samba’s passdb.  
In this lab, we created Linux users (`useradd`) and then created Samba passwords with:
- `smbpasswd -a <user>`

---

## 10) How do you list Samba users stored in Samba database?
**Answer:** Using:
```bash
sudo pdbedit -L
````

---

## 11) Why is SELinux configuration important for Samba shares on RHEL?

**Answer:** SELinux can block Samba from reading/writing directories even if Linux permissions are correct. The proper **SELinux type** must be applied (like `samba_share_t`) and required booleans enabled.

---

## 12) What SELinux steps were done in this lab?

**Answer:**

* Enabled booleans:

  * `setsebool -P samba_enable_home_dirs on`
  * `setsebool -P samba_export_all_rw on`
* Applied share context:

  * `semanage fcontext -a -t samba_share_t "/srv/samba(/.*)?"`
  * `restorecon -R /srv/samba/`
    Also: installed `policycoreutils-python-utils` because `semanage` was missing.

---

## 13) How did you test Samba shares from Linux without Windows?

**Answer:**

* List shares:

  * `smbclient -L localhost -U sambauser1`
* Connect to a share:

  * `smbclient //localhost/public -N`
  * `smbclient //localhost/private -U sambauser1`
* Mount with CIFS:

  * `mount -t cifs //localhost/public /mnt/samba-test -o guest,...`

---

## 14) What is the benefit of having separate shares like public/private/team/users?

**Answer:** It models real enterprise access patterns:

* **public:** easy guest access for non-sensitive data
* **private:** restricted access for secure documents
* **team:** group collaboration with shared ownership
* **users:** each user gets a private directory with strict permissions

---

## 15) How do you monitor active Samba sessions and open files?

**Answer:** Using:

* `smbstatus` (sessions + shares)
* `smbstatus -p` (process details)
* `smbstatus -L` (locked files)

---

## 16) What are some common causes of “Permission denied” even when Linux perms look correct?

**Answer:**

* SELinux blocking access (wrong context)
* user not in the required Samba group
* Samba share configured read-only
* filesystem ownership mismatch with `force user` / `force group` behavior

---

## 17) What does `hosts allow` / `hosts deny` achieve?

**Answer:** It restricts which clients can access Samba, adding an additional access control layer at the Samba level (independent of firewall). In this lab:

* allowed `127.` and internal ranges (`192.168.`, `10.`)
* denied everything else.

---

## 18) What’s a safer alternative to “public share with 777” in production?

**Answer:** Use:

* a dedicated group with controlled membership
* setgid directories (`chmod 2770`)
* limit guest access
* enforce ACLs
* enable auditing/logging
  Public shares in production should not usually be world-writable.

---

## 19) Why would you disable SMB1?

**Answer:** SMB1 is insecure and outdated. Modern Samba defaults disable SMB1 for security. In the lab output, we saw:

* `SMB1 disabled -- no workgroup available`

---

## 20) What is the purpose of a maintenance script for Samba?

**Answer:** Operational hygiene:

* validate configuration (catch errors early)
* backup the Samba user database
* help automate repetitive admin tasks
  This supports production readiness and reduces human error.

---
