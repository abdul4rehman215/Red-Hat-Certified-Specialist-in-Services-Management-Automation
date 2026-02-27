#!/bin/bash
# Create Apache test HTML page for SELinux troubleshooting lab

set -euo pipefail

TARGET="/custom/web/content/index.html"

sudo mkdir -p /custom/web/content

sudo tee "$TARGET" >/dev/null <<'EOF'
<!DOCTYPE html>
<html>
<head>
 <title>SELinux Test Page</title>
</head>
<body>
 <h1>Welcome to SELinux Troubleshooting Lab</h1>
 <p>If you can see this page, SELinux policies are working correctly!</p>
</body>
</html>
EOF

sudo chown -R apache:apache /custom/web/content
sudo chmod -R 755 /custom/web/content

echo "Created: $TARGET"
