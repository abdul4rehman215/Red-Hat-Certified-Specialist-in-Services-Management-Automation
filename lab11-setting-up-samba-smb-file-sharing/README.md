# 🧪 Lab 11: Setting Up Samba (SMB) for File Sharing (CentOS/RHEL 8)

## 📌 Lab Summary
This lab demonstrates how to deploy and configure a **Samba (SMB)** file server on **CentOS/RHEL 8** for **cross-platform file sharing** between Linux and Windows clients. The lab covers:

- Installing Samba server + client tooling
- Enabling and validating `smb` and `nmb` services
- Opening firewall rules for Samba
- Creating multiple share types:
  - **Public** (guest access)
  - **Private** (authenticated, group-based)
  - **Team** (collaboration, group-based)
  - **Users** (per-user directories with strict permissions)
- Implementing user-based access control using Linux groups and Samba user database
- Applying SELinux booleans + Samba share contexts (`samba_share_t`)
- Verifying configuration syntax using `testparm`
- Testing access using:
  - `smbclient` (CLI)
  - mounting SMB share via `mount -t cifs`
- Monitoring active sessions using `smbstatus`
- Adding logging, performance tuning, and security-hardening examples
- Creating a simple maintenance script for validation and backup

This lab was performed in a **college-provided cloud lab environment** and documented as part of a professional GitHub portfolio.

---

## 🎯 Objectives
By the end of this lab, I was able to:

- Install and configure a Samba server on Linux
- Create and manage SMB shares for cross-platform access
- Implement user-based access control for sensitive shares
- Configure both guest-access and authenticated shares
- Test Samba shares from Linux (smbclient and CIFS mounting)
- Apply SELinux contexts required for Samba access
- Troubleshoot connectivity, authentication, and permission issues

---

## ✅ Prerequisites
Before starting, the following knowledge was required:

- Linux CLI basics and service management (systemctl)
- Linux file permissions and ownership
- Linux user/group management
- Networking fundamentals (IP, ports, firewall)
- Basic understanding of Windows file sharing concepts (SMB/CIFS)
- Text editor familiarity (nano/vim)

---

## 🧩 Lab Environment
| Component | Details |
|----------|---------|
| OS | CentOS/RHEL 8 |
| Samba Services | `smb` (smbd), `nmb` (nmbd) |
| Firewall | firewalld (`--add-service=samba`) |
| SELinux | Enforcing supported (configured contexts + booleans) |
| Tools Used | `smbclient`, `testparm`, `smbpasswd`, `pdbedit`, `smbstatus`, `mount.cifs` |
| Prompt Style | `-bash-4.2$` |

---

## 🗂️ Repository Structure (Lab Folder)
```text
lab11-setting-up-samba-smb-file-sharing/
├─ README.md
├─ commands.sh
├─ output.txt
├─ interview_qna.md
├─ troubleshooting.md
├─ configs/
│  ├─ smb.conf
│  └─ smb.conf.backup.note.txt
└─ scripts/
   └─ samba-maintenance.sh
````

---

## ✅ Tasks Overview (What I Performed)

### ✅ Task 1: Install and Configure Samba Server

**Goal:** Install Samba packages, enable services, and prepare the host for SMB access.

**High-Level Actions:**

* Updated system packages (`dnf update -y`)
* Installed Samba packages:

  * `samba`
  * `samba-client`
  * `samba-common`
* Installed CIFS utilities for mounting/testing:

  * `cifs-utils`
* Started + enabled services:

  * `smb`
  * `nmb`
* Opened firewall rule:

  * `firewall-cmd --permanent --add-service=samba`
* Backed up default Samba config:

  * `/etc/samba/smb.conf` → `/etc/samba/smb.conf.backup`
* Reviewed default config to understand baseline structure

---

### ✅ Task 2: Create Shares for Windows and Linux Clients

**Goal:** Build a realistic multi-share Samba server layout.

**Shares created in this lab:**

* **[public]** → anonymous guest access (RW)
* **[private]** → authenticated access for group `@sambausers`
* **[team]** → authenticated group collaboration share `@teamusers`
* **[users]** → per-user folder access under `/srv/samba/users/%S`

**High-Level Actions:**

* Created directories:

  * `/srv/samba/public`
  * `/srv/samba/private`
  * `/srv/samba/team`
  * `/srv/samba/users`
* Configured permissions:

  * public: `777` and owned by `nobody:nobody`
  * private/team: restrictive group access (`770`)
  * users base dir: `755` (each user folder later `700`)
* Configured SELinux for Samba:

  * enabled booleans:

    * `samba_enable_home_dirs on`
    * `samba_export_all_rw on`
  * set contexts:

    * `semanage fcontext -a -t samba_share_t "/srv/samba(/.*)?"`
    * `restorecon -R /srv/samba/`
  * installed missing tool:

    * `policycoreutils-python-utils` (to get `semanage`)
* Replaced Samba configuration with a structured `smb.conf` using:

  * guest mapping
  * logging setup
  * host allow/deny
  * share definitions for public/private/team/users
* Verified syntax using:

  * `testparm`
  * `testparm -v`

---

### ✅ Task 3: User-Based Access Control

**Goal:** Create Linux groups/users and map them to Samba users for share restrictions.

**High-Level Actions:**

* Created Linux groups:

  * `sambausers`
  * `teamusers`
* Created system users (nologin, no home):

  * `sambauser1`
  * `sambauser2`
  * `teamuser1`
  * `teamuser2`
* Assigned groups:

  * sambausers → sambauser1, sambauser2
  * teamusers → teamuser1, teamuser2
* Added users to Samba database:

  * `smbpasswd -a <user>`
  * enabled them with `smbpasswd -e <user>`
* Verified Samba users with:

  * `pdbedit -L`
* Created per-user directories under `/srv/samba/users/<username>`:

  * set ownership to match user and group
  * locked down permissions with `chmod 700`
* Set ownership on shared group folders:

  * private share owned by `root:sambausers`
  * team share owned by `root:teamusers`
  * both shares set to `770`

---

### ✅ Task 4: Testing and Verification

**Goal:** Confirm shares work and access controls behave correctly.

**High-Level Actions:**

* Listed shares:

  * `smbclient -L localhost -U sambauser1`
* Tested guest access:

  * `smbclient //localhost/public -N`
* Tested authenticated share:

  * `smbclient //localhost/private -U sambauser1`
* Mounted SMB share using CIFS:

  * `mount -t cifs //localhost/public /mnt/samba-test -o guest,uid=1000,gid=1000`
* Verified write access:

  * created `linux-test.txt` via mounted share
* Created test files directly on server:

  * public-test.txt, private-test.txt, team-test.txt
* Verified user directory access by uploading a file using smbclient:

  * placed `sambauser1-test.txt` in the user’s directory
* Confirmed Samba listens on ports:

  * `139` and `445`

---

### ✅ Task 5: Advanced Configuration and Monitoring

**Goal:** Introduce realistic operational steps used in production.

**High-Level Actions:**

* Created `/var/log/samba` directory
* Increased logging and validated:

  * `testparm -s`
* Monitored sessions and activity:

  * `smbstatus`
  * `smbstatus -p`
  * `smbstatus -L`
* Added performance tuning examples:

  * protocol min/max SMB2/SMB3
  * aio read/write size
  * oplocks
* Added security hardening examples:

  * disable NetBIOS
  * restrict SMB ports to 445
  * disable NTLM auth
  * restrict anonymous behavior
* Created a maintenance script:

  * validates smb.conf
  * backs up user database
  * prints completion status

---

## ✅ Verification Checklist (What Proved It Worked)

* `systemctl status smb` and `systemctl status nmb` → running
* firewall includes samba service:

  * `firewall-cmd --list-services`
* config validated:

  * `testparm` and `testparm -s`
* share listing works:

  * `smbclient -L localhost`
* guest share accessible:

  * `smbclient //localhost/public -N`
* authenticated access works:

  * `smbclient //localhost/private -U sambauser1`
* CIFS mount works and write tested:

  * created file via `/mnt/samba-test`
* Samba listening ports confirmed:

  * `netstat -tulpn | grep -E '(139|445)'`
* per-user directory access verified:

  * file uploaded successfully and visible on server

---

## 💡 Why This Matters

Samba is critical in mixed environments where Linux systems must share files with Windows clients. These skills apply directly to:

* enterprise file sharing and collaboration
* enforcing role-based access to shared resources
* maintaining cross-platform compatibility
* troubleshooting authentication and permissions issues
* security hardening and monitoring of SMB services

---

## ✅ Conclusion

In this lab, I built a working Samba SMB file server with multiple real-world share types, implemented user/group-based access control, integrated SELinux support, validated configuration integrity, tested access from Linux using smbclient and CIFS mounts, and added monitoring and hardening steps suitable for production-style environments.

✅ Lab completed successfully (CentOS/RHEL 8 cloud environment).

---
