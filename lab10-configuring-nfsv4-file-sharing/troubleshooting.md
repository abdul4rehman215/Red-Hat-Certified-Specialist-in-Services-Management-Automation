# 🛠️ Lab 10 — Troubleshooting Guide (NFSv4 File Sharing: Server + Client)

> This guide covers common NFSv4 issues encountered during server export setup, client mounting, permissions, and reliability testing.

---

## Issue 1: Client cannot see exports (`showmount -e` fails)

### ✅ Symptoms
- `showmount -e nfs-server` fails
- Errors like:
  - `clnt_create: RPC: Port mapper failure`
  - `No route to host`
  - `Connection timed out`

### 🔎 Possible Causes
- `rpcbind` not running on server
- firewall not allowing RPC/NFS services
- DNS/hostname resolution issue for `nfs-server`
- network connectivity issue

### ✅ Fix Steps

#### 1) Confirm network connectivity (client)
```bash
ping -c 2 nfs-server
````

**Lab evidence:**

```text id="tqewjz"
PING nfs-server (192.168.1.30) 56(84) bytes of data.
64 bytes from 192.168.1.30: icmp_seq=1 ttl=64 time=0.621 ms
64 bytes from 192.168.1.30: icmp_seq=2 ttl=64 time=0.584 ms
```

#### 2) Verify rpcbind is running (server + client)

```bash id="l7h4uz"
sudo systemctl status rpcbind
```

#### 3) Confirm RPC/NFS services are visible (server)

```bash id="q8k5wf"
sudo rpcinfo -p localhost
```

#### 4) Confirm firewall services are enabled (server)

```bash id="o8z9xx"
sudo firewall-cmd --list-services
```

Expected to include:

* `nfs`
* `rpc-bind`
* `mountd`

#### 5) If hostname resolution fails, use IP directly (client)

```bash id="g7h8r0"
sudo showmount -e 192.168.1.30
```

---

## Issue 2: Mount fails with “access denied” or “No such file or directory”

### ✅ Symptoms

* `mount.nfs4: access denied by server`
* `mount.nfs4: No such file or directory`

### 🔎 Possible Causes

* export path mismatch (NFSv4 pseudo root confusion)
* exports not applied (`exportfs` not reloaded)
* `/etc/exports` incorrect options or syntax
* wrong server hostname/IP

### ✅ Fix Steps

#### 1) Verify exports on server

```bash id="2l0v7u"
sudo exportfs -v
```

#### 2) Re-export everything

```bash id="lq5rzj"
sudo exportfs -arv
```

#### 3) Validate NFSv4 root export (`fsid=0`)

In this lab:

* `/nfs/shared` is the v4 root (`fsid=0`)
  Client mount mapping becomes:
* `nfs-server:/`  → `/nfs/shared`
* `nfs-server:/documents` → `/nfs/shared/documents`

So the correct mount commands are:

```bash id="q0v6d0"
sudo mount -t nfs4 nfs-server:/ /mnt/nfs/shared
sudo mount -t nfs4 nfs-server:/documents /mnt/nfs/documents
```

#### 4) Confirm NFS is listening (server)

```bash id="0tp5zs"
sudo ss -tulpn | grep -E ':(111|2049|20048)'
```

---

## Issue 3: Mount works, but permissions are “Permission denied”

### ✅ Symptoms

* Can mount share but cannot read/write
* `Permission denied` on file creation or directory listing

### 🔎 Possible Causes

* server directory permissions/ownership incorrect
* export options too restrictive (e.g., ro export)
* client user UID/GID mismatch (ownership mapping issue)
* root squashed (when `no_root_squash` not set)

### ✅ Fix Steps

#### 1) Check server-side directory permissions

```bash id="u0o0ap"
ls -la /nfs/shared/
ls -la /nfs/shared/documents/
```

#### 2) Verify export options (server)

```bash id="t8iy5m"
cat /etc/exports
sudo exportfs -v
```

#### 3) Confirm RO vs RW mount behavior

* `public` is exported **ro** in this lab:

  * write attempts should fail with `Read-only file system`
    This is expected behavior (not an error).

#### 4) Validate UID consistency (important!)

If a user has different UID on server vs client, ownership appears wrong.
Fix by creating consistent UIDs:

```bash id="d6jmgt"
sudo useradd -u 1001 testuser
```

---

## Issue 4: “Stale file handle” errors

### ✅ Symptoms

* `Stale file handle` when accessing mounted directories

### 🔎 Possible Causes

* exports changed while client still mounted
* server restarted and export structure changed
* client cached old file handles

### ✅ Fix Steps (client)

```bash id="3n2w8f"
sudo umount /mnt/nfs/shared
sudo mount -t nfs4 nfs-server:/ /mnt/nfs/shared
```

Also re-export on server:

```bash id="xv8epp"
sudo exportfs -arv
```

---

## Issue 5: `mount -a` fails after editing `/etc/fstab`

### ✅ Symptoms

* `mount -a` returns errors
* mounts missing after reboot
* boot delays due to network mounts

### 🔎 Possible Causes

* incorrect fstab syntax
* server not reachable at boot time
* missing `_netdev` option

### ✅ Fix Steps

#### 1) Validate `/etc/fstab` entries

Example used in this lab:

```text id="1f94qt"
nfs-server:/ /mnt/nfs/shared nfs4 defaults,_netdev 0 0
nfs-server:/documents /mnt/nfs/documents nfs4 defaults,_netdev 0 0
nfs-server:/projects /mnt/nfs/projects nfs4 defaults,_netdev 0 0
nfs-server:/public /mnt/nfs/public nfs4 ro,defaults,_netdev 0 0
nfs-server:/home /mnt/nfs/home nfs4 defaults,_netdev 0 0
```

#### 2) Test cleanly

```bash id="x0ct7h"
sudo umount /mnt/nfs/shared
sudo umount /mnt/nfs/documents
sudo umount /mnt/nfs/projects
sudo umount /mnt/nfs/public
sudo umount /mnt/nfs/home

sudo mount -a
df -h | grep nfs
```

---

## Issue 6: NFS performance is slow

### ✅ Symptoms

* Large file copies are slow
* High latency, inconsistent throughput

### 🔎 Possible Causes

* default rsize/wsize too high/low depending on network
* too few nfsd threads on server
* heavy contention due to many clients
* underlying storage performance limits

### ✅ Fix Steps

#### 1) Tune server threads and versions (server)

```bash id="1v16xf"
sudo tee -a /etc/nfs.conf > /dev/null << 'EOF'
[nfsd]
threads=16
vers4.0=y
vers4.1=y
vers4.2=y
[mountd]
threads=16
EOF

sudo systemctl restart nfs-server
```

#### 2) Mount with performance options (client)

```bash id="a8ykqq"
sudo umount /mnt/nfs/shared
sudo mount -t nfs4 -o rsize=32768,wsize=32768,hard,intr nfs-server:/ /mnt/nfs/shared
```

---

## Issue 7: Client hangs when server goes down

### ✅ Symptoms

* `ls` or file operations hang
* timeouts occur

### 🔎 Cause

This is expected behavior depending on mount options. In this lab, when the server stopped, client access timed out (expected), then worked again after restart.

### ✅ Mitigation Tips

* Use `soft` mounts carefully (risk data corruption)
* Use `hard` mounts for reliability, but plan for timeouts
* Consider `timeo` and `retrans` tuning
* Use HA NFS in production (clustered storage)

---

## ✅ Quick Validation Checklist

After any fix, confirm:

* [ ] Server: `systemctl status nfs-server` and `rpcbind`
* [ ] Server: `exportfs -v` shows correct exports
* [ ] Server: `firewall-cmd --list-services` includes nfs + rpc-bind + mountd
* [ ] Client: `showmount -e nfs-server` lists exports
* [ ] Client: mounts visible in `df -h | grep nfs`
* [ ] RW shares allow writes, RO share blocks writes
* [ ] UID consistency verified (same UID user on both sides)

---

## 🧪 Included Validation Script (from this lab)

This lab created a test script at:

* `/tmp/nfs_test.sh`

Run:

```bash id="08fzf0"
sudo /tmp/nfs_test.sh
```

It validates:

* mounts exist
* read access works
* write access works
* directory operations work

---
