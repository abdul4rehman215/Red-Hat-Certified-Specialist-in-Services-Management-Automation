#!/bin/bash
# Generate a SELinux summary report file for documentation

set -euo pipefail

REPORT="selinux_config_summary.txt"

{
  echo "=== SELinux Configuration Summary ==="
  echo "SELinux Status: $(getenforce)"
  echo "Custom File Contexts:"
  sudo semanage fcontext -l | grep custom || true
  echo "Custom Modules:"
  sudo semodule -l | grep custom || true
  echo "Services Status:"
  systemctl is-active httpd mariadb || true
} > "$REPORT"

cat "$REPORT"
echo "Saved report: $REPORT"
