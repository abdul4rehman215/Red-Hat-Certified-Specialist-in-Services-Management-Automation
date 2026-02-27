# 🧪 Lab 10: Configuring NFSv4 File Sharing (Server + Client)

## 📌 Lab Summary
This lab demonstrates how to configure **NFSv4** network file sharing using a **CentOS/RHEL 8** NFS server and client. It covers:

- Installing and enabling NFS server services
- Creating export directories and setting permissions/ownership
- Configuring `/etc/exports` including an NFSv4 root (`fsid=0`)
- Opening firewall services required for NFS
- Installing client utilities and mounting exports using NFSv4 paths
- Creating persistent mounts using `/etc/fstab`
- Testing read/write behavior including read-only exports
- Validating ownership/permissions behavior and UID consistency
- Performing performance/stress testing and service reliability testing
- Applying basic tuning options in `/etc/nfs.conf` and mounting with performance options
- Creating and running a verification script for end-to-end validation

This lab was performed in a **college-provided cloud lab environment** and documented for a professional portfolio repository.

---

## 🎯 Objectives
By the end of this lab, I was able to:

- Configure an **NFSv4 server** to export directories
- Configure an **NFSv4 client** to mount and access exports
- Implement basic security and permissions for shared directories
- Validate read/write behaviors across multiple exports
- Troubleshoot common NFS issues (exports, firewall, permissions, stale handles)
- Understand key differences between NFSv3 and NFSv4

---

## ✅ Prerequisites
Before starting this lab, the following knowledge was required:

- Linux filesystem basics
- Linux users/groups and UID/GID understanding
- systemd service management
- networking basics and IP addressing
- basic firewall management (firewalld)
- ability to edit configuration files (nano/vim)

---

## 🧩 Lab Environment
| Component | Details |
|----------|---------|
| OS | CentOS/RHEL 8 |
| Server Hostname | `nfs-server` |
| Client Hostname | `nfs-client` |
| Server IP (example) | `192.168.1.30` |
| Client IP (example) | `192.168.1.40` |
| NFS Version | NFSv4 (observed mount vers=4.2) |
| Key Server Files | `/etc/exports`, `/etc/nfs.conf` |
| Key Ports | 111 (rpcbind), 2049 (nfs), 20048 (mountd) |

---

## 🗂️ Repository Structure (Lab Folder)
```text
lab10-configuring-nfsv4-file-sharing/
├─ README.md
├─ commands.sh
├─ output.txt
├─ interview_qna.md
├─ troubleshooting.md
├─ server/
│  ├─ exports
│  └─ nfs.conf
├─ client/
│  └─ fstab.append
└─ scripts/
   └─ nfs_test.sh
````

---

## ✅ Tasks Overview (What I Performed)

### ✅ Task 1: Configure NFSv4 Server and Export Directories

**Goal:** Deploy a functional NFSv4 server and export shared directories.

**High-Level Actions:**

* Installed NFS server utilities (`nfs-utils`) and dependencies
* Enabled and started services:

  * `nfs-server`
  * `rpcbind`
* Created export directory structure:

  * `/nfs/shared` with subfolders:

    * `documents`
    * `projects`
    * `public`
  * `/nfs/home` for home directory exports
* Set permissions and ownership:

  * shared directories owned by `nfsnobody:nfsnobody` with `755`
  * home directory export owned by `root:root` with `755`
* Created sample files and added content for testing
* Configured exports in `/etc/exports` with:

  * NFSv4 root (`fsid=0`) on `/nfs/shared`
  * RW exports for documents/projects/home
  * RO export for public
* Applied and verified exports:

  * `exportfs -arv`
  * `exportfs -v`
* Configured firewall:

  * allowed services `nfs`, `rpc-bind`, `mountd`
* Verified ports and rpc services:

  * `ss -tulpn`
  * `rpcinfo -p localhost`

---

### ✅ Task 2: Set Up NFS Clients and Mount Exported Directories

**Goal:** Configure a client to discover exports and mount them using NFSv4.

**High-Level Actions:**

* Installed NFS client utilities (`nfs-utils`)
* Enabled and started `rpcbind` on the client
* Created mount points:

  * `/mnt/nfs/shared`
  * `/mnt/nfs/documents`
  * `/mnt/nfs/projects`
  * `/mnt/nfs/public`
  * `/mnt/nfs/home`
* Verified server connectivity:

  * `showmount -e nfs-server`
  * `rpcinfo -p nfs-server`
* Mounted shares using NFSv4:

  * `nfs-server:/` → `/mnt/nfs/shared` (NFSv4 root)
  * `nfs-server:/documents` → `/mnt/nfs/documents`
  * `nfs-server:/projects` → `/mnt/nfs/projects`
  * `nfs-server:/public` → `/mnt/nfs/public` (read-only)
  * `nfs-server:/home` → `/mnt/nfs/home`
* Verified mounts:

  * `df -h | grep nfs`
  * `mount | grep nfs`

---

### ✅ Task 2.5: Configure Persistent Mounts

**Goal:** Ensure shares automatically mount at boot.

**High-Level Actions:**

* Backed up `/etc/fstab`
* Added NFSv4 entries using `_netdev`:

  * RW mounts for shared/documents/projects/home
  * RO mount for public
* Tested persistence safely:

  * unmounted all shares
  * ran `mount -a`
  * confirmed mounts returned in `df -h`

---

### ✅ Task 3: Test File Sharing Functionality (Read/Write/RO)

**Goal:** Confirm correct behavior across read-write and read-only exports.

**Read tests:**

* `cat` sample files from documents/projects/public

**Write tests:**

* created files in RW exports:

  * `/mnt/nfs/documents/client_created.txt`
  * `/mnt/nfs/projects/client_update.txt`
  * `/mnt/nfs/shared/client_directory/info.txt`
* confirmed RO export enforcement:

  * write to `/mnt/nfs/public` failed with `Read-only file system`
* validated server sees client-created files:

  * checked paths on server under `/nfs/shared/...`

---

### ✅ Task 3.3: Ownership, Permissions, and UID Consistency

**Goal:** Validate how NFS handles file ownership across systems.

**High-Level Actions:**

* created permission test file and set:

  * ownership `nfsnobody:nfsnobody`
  * mode `644`
* created same UID user on server and client:

  * `useradd -u 1001 testuser`
* tested writing as non-root user:

  * created `/mnt/nfs/shared/user_test.txt` as `testuser`
* validated ownership appears correctly as `testuser:testuser`

---

### ✅ Task 3.4: Performance and Stress Testing

**Goal:** Measure basic throughput and concurrency behavior.

**High-Level Actions:**

* wrote a 100MB file using `dd`
* copied it and timed operation with `time cp`
* created multiple files concurrently in background
* verified all concurrent writes completed successfully

---

### ✅ Task 3.5: Service Reliability Testing

**Goal:** Validate behavior during server downtime and recovery.

**High-Level Actions:**

* stopped NFS service on server
* client access attempt timed out (expected)
* restarted NFS service
* client access restored successfully

---

### ✅ Advanced Options: Performance Tuning

**Goal:** Apply basic NFS tuning and mount options.

**High-Level Actions:**

* updated `/etc/nfs.conf`:

  * increased `threads`
  * enabled v4.0/v4.1/v4.2
* restarted NFS service
* remounted client with performance flags:

  * `rsize=32768,wsize=32768,hard,intr`

---

### ✅ Lab Validation Script

**Goal:** Provide a simple automated verification of mounts + read/write operations.

* Created `nfs_test.sh` and executed:

  * confirms mounts present
  * reads sample file
  * writes `final_test.txt`
  * creates directory and validates it exists

---

## ✅ Verification & Validation Checklist

The lab was validated using:

* `systemctl status nfs-server` and `rpcbind` (server)
* `exportfs -v` shows configured exports
* `firewall-cmd --list-services` includes `nfs rpc-bind mountd`
* client:

  * `showmount -e nfs-server` shows exports
  * mounts appear in `df -h` and `mount`
  * sample files readable via `cat`
  * RW shares writable and RO share blocks writes
* server confirms client-created files exist
* UID consistency verified using `testuser` with UID 1001

---

## ✅ Result

✅ NFSv4 file sharing successfully configured and verified:

* NFS server exports multiple directories
* Client mounts root and subpaths using NFSv4
* Read-write and read-only behavior confirmed
* Ownership/permissions and UID mapping validated
* Basic performance and reliability testing completed
* Persistent mounts configured using `/etc/fstab`

---

## 💡 Why This Matters

NFSv4 is widely used in enterprise environments for:

* centralized shared storage (home directories, team shares)
* development environments (shared code artifacts)
* virtualized/container platforms needing shared persistent volumes
* backup and recovery workflows
* HPC clusters requiring shared datasets

Understanding NFS configuration and troubleshooting is essential for Linux administration and services automation roles.

---

## ✅ Conclusion

In this lab, I deployed a working NFSv4 file-sharing solution:

* configured server exports + firewall
* configured client mounts + persistence
* validated permissions, read/write, reliability, and performance
* documented real outputs and verification evidence

✅ Lab completed successfully (Server + Client on CentOS/RHEL 8).

---
