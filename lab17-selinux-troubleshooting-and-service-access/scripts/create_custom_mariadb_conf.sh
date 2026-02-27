#!/bin/bash
# Configure MariaDB to use a custom datadir and socket under /custom/database/data

set -euo pipefail

CONF="/etc/my.cnf.d/custom.cnf"

sudo mkdir -p /custom/database/data
sudo chown -R mysql:mysql /custom/database/data

sudo tee "$CONF" >/dev/null <<'EOF'
[mysqld]
datadir=/custom/database/data
socket=/custom/database/data/mysql.sock
[client]
socket=/custom/database/data/mysql.sock
EOF

echo "Created: $CONF"
echo "Custom datadir prepared: /custom/database/data"
