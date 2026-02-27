#!/bin/bash
# Lab 09 - Configuring Postfix for Email Sending
# Commands Executed During Lab (Sequential / Paste-Ready)

# -----------------------------
# Task 1.1 - Install Postfix Package
# -----------------------------
sudo dnf update -y
sudo dnf install -y postfix mailx
sudo dnf install -y telnet nc

# -----------------------------
# Task 1.2 - Initial Postfix Configuration
# -----------------------------
sudo systemctl stop postfix
sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.backup

sudo tee /etc/postfix/main.cf > /dev/null << 'EOF'
# Basic Postfix Configuration for Email Sending
compatibility_level = 2
# Network settings
inet_interfaces = all
inet_protocols = ipv4
mydestination = $myhostname, localhost.$mydomain, localhost
myorigin = $mydomain
# Basic mail handling
home_mailbox = Maildir/
mailbox_command =
# Message size limits
message_size_limit = 10240000
mailbox_size_limit = 1024000000
# Queue settings
maximal_queue_lifetime = 1d
bounce_queue_lifetime = 1d
# Logging
maillog_file = /var/log/postfix.log
EOF

# -----------------------------
# Task 1.3 - Set Hostname and Domain
# -----------------------------
sudo hostnamectl set-hostname mailserver.example.com

sudo postconf -e "myhostname = $(hostname -f)"
sudo postconf -e "mydomain = example.com"

sudo postconf -n | grep -E "(myhostname|mydomain)"

# -----------------------------
# Task 1.4 - Configure Basic Mail Directories
# -----------------------------
sudo mkdir -p /var/spool/mail
sudo chmod 1777 /var/spool/mail

sudo mkdir -p /var/spool/postfix
sudo chown -R postfix:postfix /var/spool/postfix

# -----------------------------
# Task 2.1 - Configure SMTP Relay Host
# -----------------------------
sudo postconf -e "relayhost = [smtp.gmail.com]:587"

sudo postconf -e "smtp_sasl_auth_enable = yes"
sudo postconf -e "smtp_sasl_security_options = noanonymous"
sudo postconf -e "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"

# -----------------------------
# Task 2.2 - Create Authentication Credentials
# -----------------------------
sudo tee /etc/postfix/sasl_passwd > /dev/null << 'EOF'
# Format: [hostname]:port username:password
[smtp.gmail.com]:587 your-email@gmail.com:your-app-password
EOF

sudo chmod 600 /etc/postfix/sasl_passwd
sudo postmap /etc/postfix/sasl_passwd
ls -la /etc/postfix/sasl_passwd*

# -----------------------------
# Task 2.3 - Configure SASL Authentication
# -----------------------------
sudo dnf install -y cyrus-sasl-plain cyrus-sasl-md5
sudo postconf -e "smtp_sasl_mechanism_filter = plain, login"

# -----------------------------
# Task 2.4 - Configure Network Maps and Access Control
# -----------------------------
sudo postconf -e "mynetworks = 127.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16, 172.16.0.0/12"

sudo postconf -e "smtpd_sender_restrictions = permit_mynetworks, reject_unknown_sender_domain"
sudo postconf -e "smtpd_recipient_restrictions = permit_mynetworks, reject_unauth_destination"

# -----------------------------
# Task 3.1 - Enable TLS for SMTP Client (Outgoing)
# -----------------------------
sudo postconf -e "smtp_use_tls = yes"
sudo postconf -e "smtp_tls_security_level = encrypt"

sudo postconf -e "smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt"
sudo postconf -e "smtp_tls_session_cache_database = btree:/var/lib/postfix/smtp_scache"

# -----------------------------
# Task 3.2 - Configure TLS Logging and Debugging
# -----------------------------
sudo postconf -e "smtp_tls_loglevel = 1"
sudo postconf -e "smtp_tls_note_starttls_offer = yes"

sudo postconf -e "smtp_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1"
sudo postconf -e "smtp_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1"

# -----------------------------
# Task 3.3 - Generate Self-Signed Certificates (Optional)
# -----------------------------
sudo mkdir -p /etc/postfix/certs
sudo openssl genrsa -out /etc/postfix/certs/postfix.key 2048
sudo openssl req -new -key /etc/postfix/certs/postfix.key -out /etc/postfix/certs/postfix.csr -subj "/C=US/ST=State/L=City/O=Organization/CN=$(hostname -f)"
sudo openssl x509 -req -days 365 -in /etc/postfix/certs/postfix.csr -signkey /etc/postfix/certs/postfix.key -out /etc/postfix/certs/postfix.crt

sudo chmod 600 /etc/postfix/certs/postfix.key
sudo chmod 644 /etc/postfix/certs/postfix.crt

sudo postconf -e "smtpd_tls_cert_file = /etc/postfix/certs/postfix.crt"
sudo postconf -e "smtpd_tls_key_file = /etc/postfix/certs/postfix.key"

# -----------------------------
# Task 3.4 - Enable TLS for Incoming Connections
# -----------------------------
sudo postconf -e "smtpd_use_tls = yes"
sudo postconf -e "smtpd_tls_security_level = may"

sudo postconf -e "smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_scache"
sudo postconf -e "smtpd_tls_loglevel = 1"
sudo postconf -e "smtpd_tls_auth_only = no"

# -----------------------------
# Task 4.1 - Start and Enable Postfix Service
# -----------------------------
sudo systemctl start postfix
sudo systemctl enable postfix
sudo systemctl status postfix

sudo netstat -tlnp | grep :25

# -----------------------------
# Task 4.2 - Test Email Sending Functionality
# -----------------------------
echo "This is a test email from Postfix configuration lab." | mail -s "Test Email from Lab 9" recipient@example.com

sudo tee /tmp/test_email.txt > /dev/null << 'EOF'
To: recipient@example.com
From: sender@example.com
Subject: Postfix Test Email

This is a test email to verify Postfix configuration.
The email was sent from Lab 9: Configuring Postfix for Email Sending.

Best regards,
Lab Administrator
EOF

sudo sendmail recipient@example.com < /tmp/test_email.txt

sudo postqueue -p
sudo tail -n 15 /var/log/postfix.log

# -----------------------------
# Task 4.3 - Verify TLS Configuration
# -----------------------------
echo "QUIT" | openssl s_client -connect smtp.gmail.com:587 -starttls smtp
sudo postconf -n | grep tls
ls -la /etc/postfix/certs/

# -----------------------------
# Task 4.4 - Monitoring Script for Queue/Logs
# -----------------------------
sudo tee /usr/local/bin/check_mail_queue.sh > /dev/null << 'EOF'
#!/bin/bash
echo "=== Mail Queue Status ==="
postqueue -p
echo ""
echo "=== Recent Mail Log Entries ==="
tail -20 /var/log/postfix.log
EOF

sudo chmod +x /usr/local/bin/check_mail_queue.sh
sudo /usr/local/bin/check_mail_queue.sh

# -----------------------------
# Task 5.1 - Configure Rate Limiting
# -----------------------------
sudo postconf -e "smtpd_client_connection_count_limit = 10"
sudo postconf -e "smtpd_client_connection_rate_limit = 30"
sudo postconf -e "smtpd_client_message_rate_limit = 100"
sudo postconf -e "smtpd_client_recipient_rate_limit = 200"

# -----------------------------
# Task 5.2 - Configure Header Checks
# -----------------------------
sudo tee /etc/postfix/header_checks > /dev/null << 'EOF'
# Remove sensitive information from headers
/^Received: from .*\[(192\.168\.|10\.|172\.1[6-9]\.|172\.2[0-9]\.|172\.3[0-1]\.)/
 REPLACE Received: from localhost
/^X-Originating-IP:/ IGNORE
/^X-Mailer:/ IGNORE
/^User-Agent:/ IGNORE
EOF

sudo postconf -e "header_checks = regexp:/etc/postfix/header_checks"
sudo postmap /etc/postfix/header_checks

# -----------------------------
# Task 5.3 - Final Configuration Review
# -----------------------------
sudo postconf -n > /tmp/postfix_config.txt
sudo postfix check
sudo systemctl reload postfix

echo "=== Postfix Configuration Summary ==="
echo "Hostname: $(postconf -h myhostname)"
echo "Domain: $(postconf -h mydomain)"
echo "Relay Host: $(postconf -h relayhost)"
echo "TLS Enabled: $(postconf -h smtp_use_tls)"
echo "SASL Auth: $(postconf -h smtp_sasl_auth_enable)"

# -----------------------------
# Troubleshooting Commands Used
# -----------------------------
sudo postconf -n | grep sasl
ls -la /etc/postfix/sasl_passwd*
sudo grep -i "authentication failed" /var/log/postfix.log

openssl s_client -connect smtp.gmail.com:587 -starttls smtp -verify_return_error
sudo postconf -n | grep -i tls | head -15
ls -la /etc/ssl/certs/ca-bundle.crt

sudo postqueue -p
sudo postqueue -f

sudo systemctl restart postfix
sudo postqueue -f

sudo postsuper -d 9A1B2C3D4E
sudo postsuper -d ALL

# -----------------------------
# Comprehensive Test Script
# -----------------------------
sudo tee /usr/local/bin/postfix_test.sh > /dev/null << 'EOF'
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
EOF

sudo chmod +x /usr/local/bin/postfix_test.sh
sudo /usr/local/bin/postfix_test.sh
