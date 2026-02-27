#!/bin/bash
echo "=== MariaDB Connection Test Script ==="
echo

# Test root connection
echo "Testing root connection..."
mysql -u root -p -e "SELECT 'Root connection successful' as Status;"
echo

# Test webapp_user connection
echo "Testing webapp_user connection..."
mysql -u webapp_user -pWebApp2024! -e "USE webapp_db; SELECT COUNT(*) as user_count FROM users;"
echo

# Test report_user connection
echo "Testing report_user connection..."
mysql -u report_user -pReport2024! -e "USE webapp_db; SELECT 'Read-only access working' as Status;"
echo

# Test inventory_user connection
echo "Testing inventory_user connection..."
mysql -u inventory_user -pInventory2024! -e "USE inventory_db; SELECT COUNT(*) as product_count FROM products;"
echo

echo "=== Connection tests completed ==="
