# 🛠️ Lab 09 — Troubleshooting Guide (Postfix Email Sending: Relay + SASL + TLS)

> This troubleshooting guide covers the most common Postfix problems when configuring **email sending**, especially when using an **external relay host** (SMTP submission on port 587) with **SASL authentication** and **TLS encryption**.

---

## Issue 1: Postfix service fails to start

### ✅ Symptoms
- `systemctl status postfix` shows **failed**
- Postfix master process not running
- Port 25 not listening

### 🔎 Possible Causes
- Broken configuration in `/etc/postfix/main.cf`
- Incorrect permissions/ownership on Postfix directories
- Syntax issues introduced during edits

### ✅ Fix Steps

#### 1) Validate Postfix configuration syntax
```bash
sudo postfix check
````

**Expected Output (Lab Example):**

```text id="v5s4e0"
(no output - configuration check passed)
```

#### 2) Restart service after validation

```bash
sudo systemctl restart postfix
sudo systemctl status postfix
```

#### 3) Confirm Postfix is listening on port 25

```bash id="3q8z4s"
sudo netstat -tlnp | grep :25
```

**Expected Output (Lab Example):**

```text id="n4w4h5"
tcp        0      0 0.0.0.0:25              0.0.0.0:*               LISTEN      4123/master
```

---

## Issue 2: Email stuck in queue / deferred delivery

### ✅ Symptoms

* `postqueue -p` shows messages still present
* Logs show `status=deferred`
* Delivery attempts fail repeatedly

### 🔎 Possible Causes

* Outbound connection blocked to relay server (very common in cloud labs)
* Wrong relay host port or DNS resolution problem
* Relay requires authentication and SASL is missing/misconfigured

### ✅ Fix Steps

#### 1) Inspect queue state

```bash
sudo postqueue -p
```

**Lab Example Queue Output:**

```text id="g8s3r0"
-Queue ID-  --Size-- ----Arrival Time---- -Sender/Recipient-------
9A1B2C3D4E      824 Tue Feb 27 14:42:09  sender@example.com
                                         recipient@example.com

A7B8C9D0E1      678 Tue Feb 27 14:41:57  root@mailserver.example.com
                                         recipient@example.com

-- 2 Kbytes in 2 Requests.
```

#### 2) Check mail logs for delivery error reason

```bash
sudo tail -n 50 /var/log/postfix.log
```

**Lab Example Log Evidence (relay timeout):**

```text id="x4j7x8"
Feb 27 14:41:59 mailserver postfix/smtp[4204]: connect to smtp.gmail.com[142.250.190.109]:587: Connection timed out
Feb 27 14:41:59 mailserver postfix/smtp[4204]: ... status=deferred (connect to smtp.gmail.com...:587: Connection timed out)
```

#### 3) Confirm the lab allows outbound SMTP submission

Many training clouds block outbound SMTP ports (25/587). If blocked:

* Postfix is correct
* Mail is queued
* Delivery cannot complete externally

✅ Practical verification:

```bash
nc -vz smtp.gmail.com 587
```

If it times out, the environment is likely blocking outbound traffic.

#### 4) Try flushing the queue (after connectivity is restored)

```bash
sudo postqueue -f
```

If Postfix reload/restart occurred during flush, you may see warnings like:

```text id="2xv7w2"
postqueue: warning: Mail system is down -- accessing queue directly
postqueue: warning: connect to transport private/smtp: No such file or directory
```

Fix:

```bash
sudo systemctl restart postfix
sudo postqueue -f
```

**Lab Example Result:**

```text id="m8a1n3"
Mail queue flushed.
```

---

## Issue 3: SASL authentication failures

### ✅ Symptoms

* Relay rejects sending with auth errors
* Logs show authentication failures
* Mail stays deferred or bounced

### 🔎 Possible Causes

* Wrong username/password (or missing App Password for Gmail)
* `sasl_passwd` file missing or incorrect format
* `.db` map not generated or outdated
* Permissions too open (Postfix may refuse to use the file)

### ✅ Fix Steps

#### 1) Verify SASL settings in Postfix

```bash
sudo postconf -n | grep sasl
```

**Lab Output Example:**

```text id="n9z2m6"
smtp_sasl_auth_enable = yes
smtp_sasl_mechanism_filter = plain, login
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
```

#### 2) Confirm password files exist + permissions

```bash
ls -la /etc/postfix/sasl_passwd*
```

**Lab Output Example:**

```text id="x7d8c1"
-rw------- 1 root root   98 Feb 27 14:28 /etc/postfix/sasl_passwd
-rw------- 1 root root 12288 Feb 27 14:28 /etc/postfix/sasl_passwd.db
```

✅ Required: `sasl_passwd` must be `600`

#### 3) Rebuild map after any changes

```bash
sudo postmap /etc/postfix/sasl_passwd
sudo systemctl reload postfix
```

#### 4) Search logs for auth failures

```bash
sudo grep -i "authentication failed" /var/log/postfix.log
```

**Lab Output Example:**

```text id="u0f7t5"
(no matches found)
```

---

## Issue 4: TLS handshake problems / STARTTLS failures

### ✅ Symptoms

* TLS tests fail using `openssl s_client`
* Logs indicate STARTTLS or handshake issues
* Delivery fails if `smtp_tls_security_level = encrypt`

### 🔎 Possible Causes

* Outbound SMTP blocked (most common in labs)
* CA file missing or wrong path
* TLS protocols restricted too aggressively (rare)
* Relay uses different requirements

### ✅ Fix Steps

#### 1) Confirm TLS settings applied

```bash
sudo postconf -n | grep -i tls
```

#### 2) Verify CA bundle exists

```bash
ls -la /etc/ssl/certs/ca-bundle.crt
```

**Lab Output Example:**

```text id="s2p6j0"
-rw-r--r-- 1 root root 219144 Feb 10  2026 /etc/ssl/certs/ca-bundle.crt
```

#### 3) Test STARTTLS connectivity (may fail if blocked)

```bash
openssl s_client -connect smtp.gmail.com:587 -starttls smtp -verify_return_error
```

**Lab Output Example (timeout / blocked):**

```text id="u6e3p7"
connect:errno=110
```

✅ Interpretation: In this lab, TLS failure aligned with relay connection timeouts in the logs (network restriction, not config logic).

---

## Issue 5: `postqueue -f` shows transport errors

### ✅ Symptoms

* `postqueue -f` shows warnings about mail system down
* Errors like missing `private/smtp`

### 🔎 Possible Causes

* Postfix was reloaded/stopped during queue flush
* master daemon not running at that moment

### ✅ Fix Steps

```bash
sudo systemctl restart postfix
sudo postqueue -f
```

**Lab Result Example:**

```text id="o2y6t9"
Mail queue flushed.
```

---

## Issue 6: Need to clean the mail queue (lab cleanup)

### ✅ When this matters

If you generated test mail during the lab and want to clean up queued messages.

### ✅ Commands

#### Remove a specific queue ID

```bash
sudo postsuper -d QUEUE_ID
```

**Lab Example:**

```text id="f7w0k2"
postsuper: Deleted: 1 message
```

#### Clear entire queue (use with caution)

```bash
sudo postsuper -d ALL
```

**Lab Example:**

```text id="y0j4m8"
postsuper: Deleted: 1 message
```

---

## ✅ Quick Validation Checklist

Use this after any change:

* [ ] `sudo postfix check` passes
* [ ] `systemctl is-active postfix` returns `active`
* [ ] `netstat -tlnp | grep :25` shows listening master
* [ ] `postconf -n | grep sasl` confirms SASL enabled (if relaying)
* [ ] `ls -la /etc/postfix/sasl_passwd*` shows `.db` exists and permissions are strict
* [ ] `postqueue -p` shows expected queue state
* [ ] `/var/log/postfix.log` shows clear error reason if delivery fails (timeout/auth/TLS)

---

## 🧪 Included Validation Script (from this lab)

This lab created a simple automated checker at:

* `/usr/local/bin/postfix_test.sh`

Run:

```bash
sudo /usr/local/bin/postfix_test.sh
```

It checks:

* service active
* port 25 listening
* syntax check
* TLS enabled flags
* SASL enabled flag
* queue status

---
