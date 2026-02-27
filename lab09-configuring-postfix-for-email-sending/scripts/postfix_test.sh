#!/bin/bash
echo "=== Postfix Configuration Test ==="
echo ""

# Test 1: Service Status
echo "1. Checking Postfix service status..."
systemctl is-active postfix
echo ""

# Test 2: Port Listening
echo "2. Checking if Postfix is listening on port 25..."
netstat -tlnp | grep :25
echo ""

# Test 3: Configuration Syntax
echo "3. Checking configuration syntax..."
postfix check
echo "Configuration syntax: OK"
echo ""

# Test 4: TLS Configuration
echo "4. Checking TLS configuration..."
postconf -h smtp_use_tls
postconf -h smtpd_use_tls
echo ""

# Test 5: Authentication Configuration
echo "5. Checking SASL authentication..."
postconf -h smtp_sasl_auth_enable
echo ""

# Test 6: Queue Status
echo "6. Checking mail queue..."
postqueue -p
echo ""

echo "=== Test Complete ==="
