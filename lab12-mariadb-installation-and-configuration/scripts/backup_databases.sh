#!/bin/bash
BACKUP_DIR="/var/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
sudo mkdir -p $BACKUP_DIR

# Backup all databases
sudo mysqldump -u backup_user -pBackup2024! --all-databases > $BACKUP_DIR/all_databases_$DATE.sql

# Backup specific databases
sudo mysqldump -u backup_user -pBackup2024! webapp_db > $BACKUP_DIR/webapp_db_$DATE.sql
sudo mysqldump -u backup_user -pBackup2024! inventory_db > $BACKUP_DIR/inventory_db_$DATE.sql

echo "Backup completed: $DATE"
