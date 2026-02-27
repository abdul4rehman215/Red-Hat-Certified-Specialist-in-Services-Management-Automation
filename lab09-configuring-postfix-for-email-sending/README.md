# 🧪 Lab 09: Configuring Postfix for Email Sending (Relay + SASL + TLS)

## 📌 Lab Summary
This lab focuses on installing and configuring **Postfix** as a Mail Transfer Agent (MTA) for **sending emails** on **CentOS/RHEL 8**. The lab includes:

- Installing Postfix and mail utilities
- Building a baseline Postfix configuration (`main.cf`)
- Configuring hostname/domain identity for proper email headers
- Configuring an external SMTP relay host (Gmail example)
- Securing outbound mail with SASL authentication and TLS encryption
- Generating self-signed certificates for inbound TLS testing
- Verifying mail queue behavior and inspecting logs
- Implementing security hardening (rate limiting + header checks)
- Creating monitoring/testing scripts to validate configuration

> ✅ Note (realistic lab behavior): Many cloud lab environments block outbound SMTP traffic (ports **587/25**) for abuse prevention.  
> In this run, outbound relay connectivity timed out, so mail remained **deferred in queue** even though Postfix configuration and service state were correct.

This lab was performed in a **college-provided cloud lab environment** and documented for a professional portfolio repository.

---

## 🎯 Objectives
By the end of this lab, I was able to:

- Install and configure Postfix for sending emails
- Set up SMTP relay host configuration and SASL authentication
- Implement TLS encryption for outgoing and incoming SMTP traffic
- Test mail flow using `mail` and `sendmail`
- Inspect queue state and troubleshoot delivery issues
- Apply security best practices for mail servers:
  - rate limits
  - header sanitization
  - TLS protocol restrictions
  - proper credential file permissions

---

## ✅ Prerequisites
Before starting this lab, the following knowledge was required:

- Linux CLI basics
- Text editor usage (nano/vim)
- Networking basics (DNS + TCP/IP)
- System administration fundamentals (systemd, permissions)
- Root/sudo privileges

---

## 🧩 Lab Environment
| Component | Details |
|----------|---------|
| OS | CentOS/RHEL 8 |
| MTA | Postfix |
| Tools | mailx, telnet, nc, openssl |
| Key Config | `/etc/postfix/main.cf` |
| Queue Tools | `postqueue`, `postsuper` |
| Logs | `/var/log/postfix.log` |

---

## 🗂️ Repository Structure (Lab Folder)
```text
lab09-configuring-postfix-for-email-sending/
├─ README.md
├─ commands.sh
├─ output.txt
├─ interview_qna.md
├─ troubleshooting.md
├─ configs/
│  ├─ main.cf
│  └─ header_checks
└─ scripts/
   ├─ check_mail_queue.sh
   └─ postfix_test.sh
````

> ⚠️ Security note for repo: relay credentials MUST NOT be committed.
> Any example credentials must be placeholders and real credentials belong in ignored files only.

---

## ✅ Tasks Overview (What I Performed)

### ✅ Task 1: Install and Configure Postfix for Email Sending

**Goal:** Install Postfix, build a baseline mail-sending configuration, and confirm service health.

**High-Level Actions:**

* Updated system and installed:

  * `postfix`, `mailx`
  * utilities: `telnet`, `nc`
* Backed up `/etc/postfix/main.cf`
* Created a baseline `main.cf` with key settings:

  * network interfaces and protocol
  * mailbox handling (Maildir)
  * message and mailbox size limits
  * queue lifetime tuning
  * dedicated logfile (`/var/log/postfix.log`)
* Set hostname and domain identity:

  * `mailserver.example.com`
  * `example.com`
* Prepared spool directories and permissions

---

### ✅ Task 2: Manage Relay Hosts and Authentication (SASL)

**Goal:** Configure Postfix to relay outbound emails through an external SMTP provider securely.

**High-Level Actions:**

* Set relay host:

  * `[smtp.gmail.com]:587`
* Enabled SASL authentication:

  * `smtp_sasl_auth_enable = yes`
  * configured password maps
  * restricted SASL security options
* Created `/etc/postfix/sasl_passwd` and hash DB via `postmap`
* Applied strict credential permissions (`chmod 600`)
* Installed SASL mechanisms:

  * `cyrus-sasl-plain`, `cyrus-sasl-md5`
* Added mechanism filter:

  * `plain, login`
* Configured networks and SMTP sender/recipient restrictions:

  * `mynetworks`
  * `smtpd_sender_restrictions`
  * `smtpd_recipient_restrictions`

---

### ✅ Task 3: Secure Mail Traffic Using TLS Encryption

**Goal:** Ensure mail traffic is encrypted where possible and limit insecure protocol versions.

**High-Level Actions:**

* Outgoing TLS configuration (client side):

  * `smtp_use_tls = yes`
  * `smtp_tls_security_level = encrypt`
  * CA bundle verification (`smtp_tls_CAfile`)
  * session cache database
  * TLS logging enabled
  * disabled old protocols (SSLv2/SSLv3/TLSv1/TLSv1.1)
* Generated optional self-signed certs (lab/testing):

  * `/etc/postfix/certs/postfix.key`
  * `/etc/postfix/certs/postfix.crt`
* Inbound TLS configuration (server side):

  * `smtpd_use_tls = yes`
  * `smtpd_tls_security_level = may`
  * session cache database + loglevel

---

### ✅ Task 4: Start Services and Test Configuration

**Goal:** Start Postfix, verify listening behavior, send test emails, and inspect queue/logs.

**High-Level Actions:**

* Started + enabled Postfix
* Verified Postfix listening on port 25
* Tested email submission:

  * using `mail` command
  * using `sendmail` with prepared message file
* Checked mail queue:

  * `postqueue -p`
* Inspected mail logs:

  * `/var/log/postfix.log`
* Verified TLS settings using `postconf -n | grep tls`
* Verified certificate file permissions

> ✅ Observed behavior (expected in many labs): relay connection timed out and messages were deferred because outbound SMTP connectivity is restricted in the lab environment.

---

### ✅ Task 5: Advanced Configuration and Security Hardening

**Goal:** Reduce abuse risk, improve privacy, and validate full config.

**High-Level Actions:**

* Rate limiting to reduce abuse:

  * connection count/rate limits
  * message/recipient rate limits
* Header checks:

  * sanitize Received headers for internal IPs
  * remove X-Originating-IP / X-Mailer / User-Agent exposure
* Validated configuration:

  * `postfix check`
  * reload postfix
* Created monitoring script:

  * queue + recent log tail
* Created full test script for validation:

  * service active
  * port listening
  * syntax check
  * TLS check
  * SASL check
  * queue status

---

## ✅ Verification & Validation Checklist

Used the following checks to validate setup:

* `systemctl status postfix` → **active (running)**
* `netstat -tlnp | grep :25` shows Postfix listening
* `postfix check` passes
* `postconf -n | grep tls` confirms TLS settings applied
* `/etc/postfix/sasl_passwd` and `.db` created; permissions set to `600`
* `postqueue -p` displays queue state and message IDs
* `/var/log/postfix.log` shows pickup/cleanup/qmgr/smtp activity
* monitoring scripts run successfully and report status

---

## ✅ Result

✅ Postfix installed and configured successfully for sending mail with:

* relay host config
* SASL authentication framework
* TLS encryption configuration (client + server)
* security hardening controls (rate limiting, header checks)
* monitoring/testing scripts for operational verification

✅ Mail messages were successfully accepted into the queue and processed by Postfix.
⚠️ External relay delivery was deferred due to outbound SMTP restrictions in this environment (common in cloud labs).

---

## 💡 Why This Matters

Email infrastructure is a high-value security target. Correct configuration helps:

* prevent credential leaks and header information exposure
* enforce encryption using TLS
* reduce open relay / abuse risks via restrictions and rate limits
* provide audit trails through logs and queue monitoring
* support reliable alerting systems and automated notifications

---

## 🌍 Real-World Applications

This lab maps directly to real-world tasks such as:

* configuring mail relays for monitoring/alerting tools (Zabbix, Nagios, SOC alerts)
* sending application notifications through external SMTP providers securely
* securing mail infrastructure for compliance and privacy
* troubleshooting mail delivery and queue performance
* implementing baseline hardening for internal SMTP services

---

## ✅ Conclusion

In this lab, I configured Postfix on CentOS/RHEL 8 as a secure email-sending MTA using an external relay:

* installed Postfix and testing tools
* configured identity (hostname/domain)
* enabled relay + SASL authentication
* enforced TLS encryption and safe protocol policies
* validated with mail/sendmail tests, logs, and queue inspection
* added security hardening and created monitoring/testing scripts

✅ Lab completed successfully (CentOS/RHEL 8 cloud environment).

---
