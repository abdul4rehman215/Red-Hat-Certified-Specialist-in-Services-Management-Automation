#!/bin/bash
# Create PHP DB test page inside custom Apache document root

set -euo pipefail

TARGET="/custom/web/content/dbtest.php"

sudo tee "$TARGET" >/dev/null <<'EOF'
<?php
$connection = new mysqli('localhost', 'root', '', '');
if ($connection->connect_error) {
 die('Connection failed: ' . $connection->connect_error);
}
echo '<h2>Database Connection Successful!</h2>';
echo '<p>SELinux is properly configured for web-database access.</p>';
$connection->close();
?>
EOF

sudo chown apache:apache "$TARGET"
sudo chmod 0644 "$TARGET"

echo "Created: $TARGET"
