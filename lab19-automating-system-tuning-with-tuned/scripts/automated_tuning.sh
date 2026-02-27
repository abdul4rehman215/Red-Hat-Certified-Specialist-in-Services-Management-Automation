#!/bin/bash
# Automated tuned Profile Management Script
# This script can be scheduled via cron for regular tuning updates

ANSIBLE_DIR="$HOME/ansible-tuned-automation"
LOG_FILE="/var/log/automated_tuning.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Starting automated tuning process" >> $LOG_FILE

cd $ANSIBLE_DIR

# Run the deployment playbook
ansible-playbook -i inventory/hosts playbooks/deploy-tuned-profiles.yml >> $LOG_FILE 2>&1

if [ $? -eq 0 ]; then
 echo "[$DATE] Tuning deployment completed successfully" >> $LOG_FILE

 # Run verification
 ansible-playbook -i inventory/hosts playbooks/verify-tuned-performance.yml >> $LOG_FILE 2>&1

 echo "[$DATE] Verification completed" >> $LOG_FILE
else
 echo "[$DATE] Tuning deployment failed" >> $LOG_FILE
 exit 1
fi

echo "[$DATE] Automated tuning process completed" >> $LOG_FILE
