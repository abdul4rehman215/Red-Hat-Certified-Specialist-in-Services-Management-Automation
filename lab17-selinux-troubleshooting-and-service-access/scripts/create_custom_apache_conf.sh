#!/bin/bash
# Create Apache vhost config for custom DocumentRoot on port 8080

set -euo pipefail

CONF="/etc/httpd/conf.d/custom-site.conf"

sudo tee "$CONF" >/dev/null <<'EOF'
<VirtualHost *:8080>
 DocumentRoot /custom/web/content
 <Directory "/custom/web/content">
 AllowOverride None
 Require all granted
 </Directory>
</VirtualHost>
Listen 8080
EOF

echo "Created: $CONF"
echo "Restart Apache to apply: sudo systemctl restart httpd"
