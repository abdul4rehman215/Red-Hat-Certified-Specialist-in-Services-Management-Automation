# 🎤 Lab 10 — Interview Q&A (Configuring NFSv4 File Sharing)

## 1) What is NFS and what problem does it solve?
**Answer:** NFS (Network File System) allows systems to share directories/files across a network as if they were local storage. It simplifies centralized storage, collaboration, and shared access across multiple Linux machines.

---

## 2) What are the major differences between NFSv3 and NFSv4?
**Answer:**
- **NFSv3**: more RPC services/ports (mountd, portmapper), stateless protocol, typically more firewall complexity.
- **NFSv4**: more integrated, supports better security models, uses a **single well-known port (2049)** for core NFS traffic, supports **pseudo-filesystem** and stronger authentication methods (like Kerberos).

---

## 3) What is the purpose of `fsid=0` in `/etc/exports`?
**Answer:** `fsid=0` defines the **NFSv4 root export** (pseudo-root). In this lab `/nfs/shared` was the NFSv4 root, allowing client mounts like:
- `nfs-server:/` → maps to `/nfs/shared`
- `nfs-server:/documents` → maps to `/nfs/shared/documents`

---

## 4) Which packages are required to configure NFS on RHEL/CentOS?
**Answer:** The main package used is:
- `nfs-utils`
It includes client and server utilities like `exportfs`, `showmount`, and services like `rpc.nfsd`, `rpc.mountd`.

---

## 5) Which services were enabled/started on the NFS server?
**Answer:**
- `nfs-server`
- `rpcbind`
These support exporting directories and handling RPC/NFS service registration.

---

## 6) What commands show active NFS exports on the server?
**Answer:**
- `exportfs -v` (shows export options)
- `exportfs -arv` (re-exports and prints what is being exported)

---

## 7) How did you verify the client could discover exports?
**Answer:**
- `showmount -e nfs-server` lists exported directories.
- `rpcinfo -p nfs-server` confirms RPC services and ports are available.

---

## 8) Which firewall services were enabled on the server in this lab?
**Answer:** Using firewalld, these services were added:
- `nfs`
- `rpc-bind`
- `mountd`

Then verified with:
- `firewall-cmd --list-services`

---

## 9) How do you mount an NFSv4 export?
**Answer:** With:
```bash
mount -t nfs4 nfs-server:/ /mnt/nfs/shared
````

and subpaths:

```bash
mount -t nfs4 nfs-server:/documents /mnt/nfs/documents
```

---

## 10) How did you make NFS mounts persistent across reboot?

**Answer:** Added entries to `/etc/fstab` using `_netdev` so the mount waits for network:

```text
nfs-server:/ /mnt/nfs/shared nfs4 defaults,_netdev 0 0
```

Then tested using:

* `umount ...`
* `mount -a`

---

## 11) How did you confirm read-only exports work correctly?

**Answer:** `/nfs/shared/public` was exported read-only and mounted read-only on the client. Attempting to write produced:

* `Read-only file system`
  This confirmed correct RO behavior.

---

## 12) Why is UID/GID consistency important in NFS?

**Answer:** NFS commonly maps file ownership by numeric UID/GID. If the same user has different IDs on server/client, ownership appears wrong. In this lab `testuser` was created with the same UID (`1001`) on both systems to validate correct mapping.

---

## 13) What does `no_root_squash` do and why is it risky?

**Answer:** It allows root on the client to act as root on exported files (no squashing to `nfsnobody`). This is risky in production because it can allow privileged writes to server data if a client is compromised. It’s often used only for controlled lab demos or special trusted environments.

---

## 14) How did you test NFS performance in this lab?

**Answer:** By writing and copying large files:

* `dd if=/dev/zero ... count=100`
* `time cp ...`
  Also tested concurrent writes using background `tee` loops.

---

## 15) What happens if the NFS server goes down while the client is accessing files?

**Answer:** Client operations can hang or timeout depending on mount options. In this lab:

* server was stopped
* client `ls` timed out (expected)
* after restarting server, access returned

This demonstrates real-world reliability behavior.

---
