#!/bin/bash
# Samba maintenance script

# Rotate logs
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
