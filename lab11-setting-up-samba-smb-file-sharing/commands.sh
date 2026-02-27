#!/bin/bash
# Lab 11 - Setting Up Samba (SMB) for File Sharing
# Commands Executed During Lab (Sequential / Paste-Ready)
#
# NOTE:
# - This lab was executed on a single CentOS/RHEL 8 host (Samba Server).
# - Commands are preserved in the same flow as performed.

# ==================================================
# TASK 1: Install and Configure Samba Server
# ==================================================

# -----------------------------
# Subtask 1.1: Install Samba Packages
# -----------------------------
sudo dnf update -y
sudo dnf install -y samba samba-client samba-common
sudo dnf install -y cifs-utils

# -----------------------------
# Subtask 1.2: Start and Enable Samba Services
# -----------------------------
sudo systemctl start smb nmb
sudo systemctl enable smb nmb

sudo systemctl status smb | head -15
sudo systemctl status nmb | head -12

# -----------------------------
# Subtask 1.3: Configure Firewall Rules
# -----------------------------
sudo firewall-cmd --permanent --add-service=samba
sudo firewall-cmd --reload
sudo firewall-cmd --list-services

# -----------------------------
# Subtask 1.4: Backup Original Configuration
# -----------------------------
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup
sudo cat /etc/samba/smb.conf | head -40

# ==================================================
# TASK 2: Create Shares for Windows and Linux Clients
# ==================================================

# -----------------------------
# Subtask 2.1: Create Directory Structure
# -----------------------------
sudo mkdir -p /srv/samba/public
sudo mkdir -p /srv/samba/private
sudo mkdir -p /srv/samba/team
sudo mkdir -p /srv/samba/users

# -----------------------------
# Subtask 2.2: Set Directory Permissions
# -----------------------------
sudo chmod 777 /srv/samba/public
sudo chmod 750 /srv/samba/private
sudo chmod 770 /srv/samba/team
sudo chmod 755 /srv/samba/users
sudo chown nobody:nobody /srv/samba/public

# -----------------------------
# Subtask 2.3: Configure SELinux Context
# -----------------------------
sudo setsebool -P samba_enable_home_dirs on
sudo setsebool -P samba_export_all_rw on

# semanage is provided by policycoreutils-python-utils on RHEL8
# If semanage isn't found, install required package and retry
sudo semanage fcontext -a -t samba_share_t "/srv/samba(/.*)?"

# If the above fails with "command not found", run:
sudo dnf install -y policycoreutils-python-utils
sudo semanage fcontext -a -t samba_share_t "/srv/samba(/.*)?"
sudo restorecon -R /srv/samba/

# -----------------------------
# Subtask 2.4: Create Main Samba Configuration
# -----------------------------
sudo tee /etc/samba/smb.conf > /dev/null << 'EOF'
[global]
 # Server identification
 workgroup = WORKGROUP
 server string = Samba Server %v
 netbios name = SAMBASERVER

 # Security settings
 security = user
 map to guest = bad user
 guest account = nobody

 # Logging
 log file = /var/log/samba/log.%m
 max log size = 1000
 log level = 1

 # Network settings
 hosts allow = 127. 192.168. 10.
 hosts deny = ALL

 # Performance tuning
 socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072

 # Disable printing by default
 load printers = no
 printing = bsd
 printcap name = /dev/null
 disable spoolss = yes

# Public share - accessible to everyone
[public]
 comment = Public File Share
 path = /srv/samba/public
 browseable = yes
 writable = yes
 guest ok = yes
 read only = no
 force user = nobody
 force group = nobody
 create mask = 0664
 directory mask = 0775

# Private share - requires authentication
[private]
 comment = Private File Share
 path = /srv/samba/private
 browseable = yes
 writable = yes
 guest ok = no
 read only = no
 valid users = @sambausers
 create mask = 0664
 directory mask = 0775

# Team share - for group collaboration
[team]
 comment = Team Collaboration Share
 path = /srv/samba/team
 browseable = yes
 writable = yes
 guest ok = no
 read only = no
 valid users = @teamusers
 force group = teamusers
 create mask = 0664
 directory mask = 0775

# Individual user directories
[users]
 comment = User Home Directories
 path = /srv/samba/users/%S
 browseable = no
 writable = yes
 guest ok = no
 read only = no
 valid users = %S
 create mask = 0600
 directory mask = 0700
EOF

# -----------------------------
# Subtask 2.5: Test Configuration Syntax
# -----------------------------
sudo testparm
sudo testparm -v | head -40

# ==================================================
# TASK 3: Set Up User-Based Access Control for File Shares
# ==================================================

# -----------------------------
# Subtask 3.1: Create System Groups
# -----------------------------
sudo groupadd sambausers
sudo groupadd teamusers
getent group sambausers teamusers

# -----------------------------
# Subtask 3.2: Create System Users + Add to Groups
# -----------------------------
sudo useradd -M -s /sbin/nologin sambauser1
sudo useradd -M -s /sbin/nologin sambauser2
sudo useradd -M -s /sbin/nologin teamuser1
sudo useradd -M -s /sbin/nologin teamuser2

sudo usermod -a -G sambausers sambauser1
sudo usermod -a -G sambausers sambauser2
sudo usermod -a -G teamusers teamuser1
sudo usermod -a -G teamusers teamuser2

# -----------------------------
# Subtask 3.3: Create Samba User Accounts
# (Interactive password prompts)
# -----------------------------
sudo smbpasswd -a sambauser1
sudo smbpasswd -a sambauser2
sudo smbpasswd -a teamuser1
sudo smbpasswd -a teamuser2

sudo smbpasswd -e sambauser1
sudo smbpasswd -e sambauser2
sudo smbpasswd -e teamuser1
sudo smbpasswd -e teamuser2

sudo pdbedit -L

# -----------------------------
# Subtask 3.4: Create User Home Directories Under /srv/samba/users
# -----------------------------
sudo mkdir -p /srv/samba/users/sambauser1
sudo mkdir -p /srv/samba/users/sambauser2
sudo mkdir -p /srv/samba/users/teamuser1
sudo mkdir -p /srv/samba/users/teamuser2

sudo chown sambauser1:sambausers /srv/samba/users/sambauser1
sudo chown sambauser2:sambausers /srv/samba/users/sambauser2
sudo chown teamuser1:teamusers /srv/samba/users/teamuser1
sudo chown teamuser2:teamusers /srv/samba/users/teamuser2

sudo chmod 700 /srv/samba/users/sambauser1
sudo chmod 700 /srv/samba/users/sambauser2
sudo chmod 700 /srv/samba/users/teamuser1
sudo chmod 700 /srv/samba/users/teamuser2

# -----------------------------
# Subtask 3.5: Ownership for Group Shares
# -----------------------------
sudo chown root:sambausers /srv/samba/private
sudo chown root:teamusers /srv/samba/team
sudo chmod 770 /srv/samba/private
sudo chmod 770 /srv/samba/team

# -----------------------------
# Subtask 3.6: Restart Samba Services + Verify Listening Ports
# -----------------------------
sudo systemctl restart smb nmb
sudo systemctl status smb | head -12
sudo systemctl status nmb | head -10
sudo netstat -tulpn | grep -E '(139|445)'

# ==================================================
# TASK 4: Testing and Verification
# ==================================================

# -----------------------------
# Subtask 4.1: Test from Linux (CLI)
# -----------------------------
smbclient -L localhost -U sambauser1
smbclient //localhost/public -N
smbclient //localhost/private -U sambauser1

# Mount public share via CIFS and write a file
sudo mkdir -p /mnt/samba-test
sudo mount -t cifs //localhost/public /mnt/samba-test -o guest,uid=1000,gid=1000
echo "Test file from Linux" | sudo tee /mnt/samba-test/linux-test.txt
sudo umount /mnt/samba-test

# -----------------------------
# Subtask 4.2: Create Test Files on Server Shares
# -----------------------------
sudo touch /srv/samba/public/public-test.txt
echo "This is a public test file" | sudo tee /srv/samba/public/public-test.txt

sudo touch /srv/samba/private/private-test.txt
echo "This is a private test file" | sudo tee /srv/samba/private/private-test.txt
sudo chown root:sambausers /srv/samba/private/private-test.txt

sudo touch /srv/samba/team/team-test.txt
echo "This is a team test file" | sudo tee /srv/samba/team/team-test.txt
sudo chown root:teamusers /srv/samba/team/team-test.txt

# -----------------------------
# Subtask 4.3: Verify User Access Controls
# (Password supplied inline as placeholder as shown in lab text)
# -----------------------------
sudo -u sambauser1 smbclient //localhost/users -U sambauser1%password << 'EOF'
ls
put /etc/hostname sambauser1-test.txt
ls
quit
EOF

ls -la /srv/samba/users/sambauser1/

# ==================================================
# TASK 5: Advanced Configuration and Monitoring
# ==================================================

# -----------------------------
# Subtask 5.1: Configure Logging
# -----------------------------
sudo mkdir -p /var/log/samba
sudo tee -a /etc/samba/smb.conf > /dev/null << 'EOF'
# Enhanced logging configuration
[global]
 log level = 2 auth:3 sam:3
 max log size = 5000
 log file = /var/log/samba/log.%m
 debug timestamp = yes
EOF

sudo systemctl restart smb nmb

# Validate after changes
sudo testparm -s

# -----------------------------
# Subtask 5.2: Monitor Samba Activity
# -----------------------------
sudo smbstatus
sudo smbstatus -p
sudo smbstatus -L
sudo tail -f /var/log/samba/log.smbd

# -----------------------------
# Subtask 5.3: Performance Optimization
# -----------------------------
sudo tee -a /etc/samba/smb.conf > /dev/null << 'EOF'
# Performance optimization
[global]
 # TCP settings
 socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072

 # SMB protocol optimization
 server min protocol = SMB2
 server max protocol = SMB3

 # Async I/O
 aio read size = 16384
 aio write size = 16384

 # Oplocks for better performance
 oplocks = yes
 level2 oplocks = yes
EOF

sudo systemctl restart smb nmb
sudo testparm -s

# ==================================================
# Security Hardening + Maintenance Script
# ==================================================

# -----------------------------
# Subtask 6.1: Security Hardening
# -----------------------------
sudo tee -a /etc/samba/smb.conf > /dev/null << 'EOF'
# Security hardening
[global]
 # Restrict SMB versions
 server min protocol = SMB2
 server max protocol = SMB3

 # Disable unnecessary features
 disable netbios = yes
 smb ports = 445

 # Enhanced security
 ntlm auth = no
 restrict anonymous = 2

 # Logging security events
 log level = 1 auth:3 winbind:2
EOF

sudo systemctl restart smb nmb
sudo systemctl status smb | head -8

# -----------------------------
# Subtask 6.2: Maintenance Script
# -----------------------------
sudo tee /usr/local/bin/samba-maintenance.sh > /dev/null << 'EOF'
#!/bin/bash
# Samba maintenance script

# Rotate logs (example placeholder action)
find /var/log/samba -name "*.log" -size +10M -exec logrotate {} \;

# Check configuration
testparm -s > /dev/null 2>&1
if [ $? -ne 0 ]; then
 echo "Samba configuration error detected!"
 exit 1
fi

# Backup user database
cp /var/lib/samba/private/passdb.tdb /var/lib/samba/private/passdb.tdb.backup

echo "Samba maintenance completed successfully"
EOF

sudo chmod +x /usr/local/bin/samba-maintenance.sh
sudo /usr/local/bin/samba-maintenance.sh
