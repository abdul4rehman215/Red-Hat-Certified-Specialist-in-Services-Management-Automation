#!/bin/bash
# Lab 10 - Configuring NFSv4 File Sharing
# Commands Executed During Lab (Sequential / Paste-Ready)
#
# NOTE:
# - Some commands are executed on the NFS Server, some on the NFS Client.
# - Kept exactly as performed in the lab flow.

# ==================================================
# TASK 1 - NFS SERVER CONFIGURATION (Server: nfs-server)
# ==================================================

# -----------------------------
# Subtask 1.1 - Install and Enable NFS Services (SERVER)
# -----------------------------
sudo dnf update -y
sudo dnf install -y nfs-utils

sudo systemctl enable nfs-server
sudo systemctl start nfs-server

sudo systemctl enable rpcbind
sudo systemctl start rpcbind

sudo systemctl status nfs-server | head -15
sudo systemctl status rpcbind | head -12

# -----------------------------
# Subtask 1.2 - Create Export Directories (SERVER)
# -----------------------------
sudo mkdir -p /nfs/shared
sudo mkdir -p /nfs/shared/documents
sudo mkdir -p /nfs/shared/projects
sudo mkdir -p /nfs/shared/public
sudo mkdir -p /nfs/home

sudo chown -R nfsnobody:nfsnobody /nfs/shared
sudo chmod -R 755 /nfs/shared
sudo chown root:root /nfs/home
sudo chmod 755 /nfs/home

# Create sample files
sudo touch /nfs/shared/documents/sample_document.txt
sudo touch /nfs/shared/projects/project_readme.txt
sudo touch /nfs/shared/public/public_info.txt

echo "This is a sample document for NFS testing" | sudo tee /nfs/shared/documents/sample_document.txt
echo "Project information and guidelines" | sudo tee /nfs/shared/projects/project_readme.txt
echo "Public information accessible to all users" | sudo tee /nfs/shared/public/public_info.txt

sudo chown -R nfsnobody:nfsnobody /nfs/shared/*

# -----------------------------
# Subtask 1.3 - Configure NFS Exports (SERVER)
# -----------------------------
sudo cp /etc/exports /etc/exports.backup 2>/dev/null || true

sudo tee /etc/exports > /dev/null << 'EOF'
# NFS Exports Configuration
# Format: directory client(options)
# Shared directories - accessible by all clients in the network
/nfs/shared *(rw,sync,no_root_squash,no_subtree_check,fsid=0)
/nfs/shared/documents *(rw,sync,no_root_squash,no_subtree_check)
/nfs/shared/projects *(rw,sync,no_root_squash,no_subtree_check)
/nfs/shared/public *(ro,sync,no_root_squash,no_subtree_check)
# Home directories - read-write access
/nfs/home *(rw,sync,no_root_squash,no_subtree_check)
EOF

sudo exportfs -arv
sudo exportfs -v

# -----------------------------
# Subtask 1.4 - Configure Firewall for NFS (SERVER)
# -----------------------------
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=rpc-bind
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --reload
sudo firewall-cmd --list-services

sudo ss -tulpn | grep -E ':(111|2049|20048)'
sudo rpcinfo -p localhost

# ==================================================
# TASK 2 - NFS CLIENT CONFIGURATION (Client: nfs-client)
# ==================================================

# -----------------------------
# Subtask 2.1 - Install NFS Client Utilities (CLIENT)
# -----------------------------
sudo dnf update -y
sudo dnf install -y nfs-utils

sudo systemctl enable rpcbind
sudo systemctl start rpcbind

# -----------------------------
# Subtask 2.2 - Create Mount Points (CLIENT)
# -----------------------------
sudo mkdir -p /mnt/nfs/shared
sudo mkdir -p /mnt/nfs/documents
sudo mkdir -p /mnt/nfs/projects
sudo mkdir -p /mnt/nfs/public
sudo mkdir -p /mnt/nfs/home
sudo chmod 755 /mnt/nfs/*

# -----------------------------
# Subtask 2.3 - Test NFS Server Connectivity (CLIENT)
# -----------------------------
sudo showmount -e nfs-server
sudo rpcinfo -p nfs-server | head -15

# -----------------------------
# Subtask 2.4 - Mount NFS Shares (CLIENT)
# -----------------------------
sudo mount -t nfs4 nfs-server:/ /mnt/nfs/shared
sudo mount -t nfs4 nfs-server:/documents /mnt/nfs/documents
sudo mount -t nfs4 nfs-server:/projects /mnt/nfs/projects
sudo mount -t nfs4 nfs-server:/public /mnt/nfs/public
sudo mount -t nfs4 nfs-server:/home /mnt/nfs/home

df -h | grep nfs
mount | grep nfs

ls -la /mnt/nfs/shared/
ls -la /mnt/nfs/documents/
ls -la /mnt/nfs/projects/
ls -la /mnt/nfs/public/

# -----------------------------
# Subtask 2.5 - Configure Persistent Mounts (CLIENT)
# -----------------------------
sudo cp /etc/fstab /etc/fstab.backup

sudo tee -a /etc/fstab > /dev/null << 'EOF'
# NFS Mounts
nfs-server:/ /mnt/nfs/shared nfs4 defaults,_netdev 0 0
nfs-server:/documents /mnt/nfs/documents nfs4 defaults,_netdev 0 0
nfs-server:/projects /mnt/nfs/projects nfs4 defaults,_netdev 0 0
nfs-server:/public /mnt/nfs/public nfs4 ro,defaults,_netdev 0 0
nfs-server:/home /mnt/nfs/home nfs4 defaults,_netdev 0 0
EOF

sudo umount /mnt/nfs/shared
sudo umount /mnt/nfs/documents
sudo umount /mnt/nfs/projects
sudo umount /mnt/nfs/public
sudo umount /mnt/nfs/home

sudo mount -a
df -h | grep nfs

# ==================================================
# TASK 3 - TEST FILE SHARING (Client + Server)
# ==================================================

# -----------------------------
# Subtask 3.1 - Read Operations (CLIENT)
# -----------------------------
cat /mnt/nfs/documents/sample_document.txt
cat /mnt/nfs/projects/project_readme.txt
cat /mnt/nfs/public/public_info.txt

ls -la /mnt/nfs/shared/
ls -la /mnt/nfs/documents/
ls -la /mnt/nfs/projects/

# -----------------------------
# Subtask 3.2 - Write Operations (CLIENT)
# -----------------------------
echo "This file was created from the NFS client" | sudo tee /mnt/nfs/documents/client_created.txt
echo "Project update from client system" | sudo tee /mnt/nfs/projects/client_update.txt
echo "This should fail" | sudo tee /mnt/nfs/public/readonly_test.txt 2>&1 || echo "Write operation failed as expected (read-only mount)"

sudo mkdir -p /mnt/nfs/shared/client_directory
echo "Directory created by client" | sudo tee /mnt/nfs/shared/client_directory/info.txt

# Verify created files on SERVER
ls -la /nfs/shared/documents/
ls -la /nfs/shared/projects/
ls -la /nfs/shared/client_directory/
cat /nfs/shared/documents/client_created.txt
cat /nfs/shared/projects/client_update.txt

# -----------------------------
# Subtask 3.3 - Permissions and Ownership Tests
# -----------------------------
sudo touch /mnt/nfs/shared/permission_test.txt
sudo chmod 644 /mnt/nfs/shared/permission_test.txt
sudo chown nfsnobody:nfsnobody /mnt/nfs/shared/permission_test.txt
ls -la /mnt/nfs/shared/permission_test.txt

# Create test user on SERVER and CLIENT (interactive passwd)
sudo useradd -u 1001 testuser
sudo passwd testuser

# On client: test access as the user
sudo su - testuser -c "echo 'User test file' > /mnt/nfs/shared/user_test.txt"
sudo su - testuser -c "ls -la /mnt/nfs/shared/user_test.txt"

# -----------------------------
# Subtask 3.4 - Performance & Stress Testing (CLIENT)
# -----------------------------
sudo dd if=/dev/zero of=/mnt/nfs/shared/large_test_file bs=1M count=100
time sudo cp /mnt/nfs/shared/large_test_file /mnt/nfs/shared/large_test_copy
ls -lh /mnt/nfs/shared/large_test*

for i in {1..5}; do
 echo "Concurrent file $i" | sudo tee /mnt/nfs/shared/concurrent_$i.txt &
done
wait
ls -la /mnt/nfs/shared/concurrent_*

# -----------------------------
# Subtask 3.5 - Reliability Test (SERVER + CLIENT)
# -----------------------------
# SERVER
sudo systemctl stop nfs-server

# CLIENT
timeout 10s ls /mnt/nfs/shared/ || echo "Operation timed out as expected"

# SERVER
sudo systemctl start nfs-server

# CLIENT
ls /mnt/nfs/shared/

# ==================================================
# Troubleshooting Connectivity Checks (CLIENT)
# ==================================================
ping -c 2 nfs-server
telnet nfs-server 2049

# ==================================================
# Advanced / Optional: Performance Tuning
# ==================================================

# SERVER - tune nfs threads and versions
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

# CLIENT - mount with performance options
sudo umount /mnt/nfs/shared
sudo mount -t nfs4 -o rsize=32768,wsize=32768,hard,intr nfs-server:/ /mnt/nfs/shared

# ==================================================
# Final Validation Script (CLIENT)
# ==================================================
sudo tee /tmp/nfs_test.sh > /dev/null << 'EOF'
#!/bin/bash
echo "=== NFS Functionality Test ==="
# Test 1: Check mounts
echo "1. Checking NFS mounts:"
df -h | grep nfs4
# Test 2: Test read access
echo "2. Testing read access:"
cat /mnt/nfs/documents/sample_document.txt
# Test 3: Test write access
echo "3. Testing write access:"
echo "Final test $(date)" | sudo tee /mnt/nfs/shared/final_test.txt
cat /mnt/nfs/shared/final_test.txt
# Test 4: Test directory creation
echo "4. Testing directory operations:"
sudo mkdir -p /mnt/nfs/shared/test_dir
ls -la /mnt/nfs/shared/ | grep test_dir
echo "=== All tests completed ==="
EOF

sudo chmod +x /tmp/nfs_test.sh
sudo /tmp/nfs_test.sh

# Performance verification + cleanup (CLIENT)
time sudo dd if=/dev/zero of=/mnt/nfs/shared/speed_test bs=1M count=50
sudo rm -f /mnt/nfs/shared/speed_test
sudo rm -f /mnt/nfs/shared/large_test*
sudo rm -f /mnt/nfs/shared/large_test_copy
