# 🎤 Lab 09 — Interview Q&A (Postfix Email Sending: Relay + SASL + TLS)

## 1) What is Postfix and what role does it play in email delivery?
**Answer:** Postfix is a Mail Transfer Agent (MTA). It is responsible for **accepting outgoing emails**, placing them in a queue, and delivering them to local recipients or relaying them to remote mail servers via SMTP.

---

## 2) What is the difference between Postfix and a full mail server setup?
**Answer:** Postfix alone handles SMTP transfer (sending/relaying). A full mail server usually also includes:
- IMAP/POP (Dovecot) for mailbox access
- spam filtering (SpamAssassin/Rspamd)
- DKIM signing (OpenDKIM)
- anti-virus scanning (ClamAV)
Postfix is the transport component.

---

## 3) What does `relayhost` do in Postfix?
**Answer:** `relayhost` defines an upstream SMTP server that Postfix sends outbound mail through (instead of directly delivering to recipients’ mail servers). This is common for using providers like Gmail, SES, or corporate SMTP relays.

---

## 4) Why is SASL authentication needed when using a relayhost like Gmail?
**Answer:** Most SMTP relays require authentication to prevent abuse. SASL allows Postfix to authenticate using credentials stored securely (e.g., in `sasl_passwd`) so the relay will accept the mail.

---

## 5) What file stores relay authentication credentials in this lab?
**Answer:** `/etc/postfix/sasl_passwd` stores the relay credentials, and `postmap` generates `/etc/postfix/sasl_passwd.db` which Postfix actually reads.

---

## 6) Why must the `sasl_passwd` file permissions be strict?
**Answer:** It contains sensitive credentials. Setting `chmod 600` ensures only root can read it, reducing risk of credential leakage.

---

## 7) What is TLS used for in this Postfix lab?
**Answer:** TLS encrypts SMTP connections:
- **Outgoing TLS** secures Postfix → relay host traffic (e.g., STARTTLS on 587).
- **Incoming TLS** secures client → Postfix traffic if Postfix is receiving SMTP connections.

---

## 8) What does `smtp_tls_security_level = encrypt` mean?
**Answer:** Postfix requires encryption for outbound SMTP connections when possible. If TLS cannot be negotiated, delivery may fail or be deferred depending on relay behavior and connectivity.

---

## 9) Why can emails appear in the queue even if Postfix is “working”?
**Answer:** Postfix can accept mail locally and queue it successfully, but delivery can be delayed due to:
- relay connectivity timeouts
- authentication failures
- DNS issues
- firewall restrictions
The queue shows messages awaiting delivery.

---

## 10) What command shows the mail queue in Postfix?
**Answer:** `postqueue -p` displays queued messages, their IDs, sender/recipient, and status.

---

## 11) Where did you check logs to troubleshoot mail delivery?
**Answer:** In this lab, Postfix logging was directed to `/var/log/postfix.log` (via `maillog_file`). Logs show queue activity and SMTP delivery attempts/errors.

---

## 12) What does “status=deferred” mean in Postfix logs?
**Answer:** The message was **not delivered now**, and Postfix will retry later. In this lab, messages were deferred due to relay connection timeouts.

---

## 13) Why might a cloud lab block outbound SMTP traffic?
**Answer:** Cloud labs often block SMTP ports (25/587) to prevent spam/abuse. This can cause relay connection timeouts even if Postfix configuration is correct.

---

## 14) What are header checks and why are they useful?
**Answer:** Header checks allow Postfix to filter/modify message headers. Here they were used to reduce sensitive header exposure (like internal IPs or user-agent markers), improving privacy and security.

---

## 15) What hardening measures were applied in this lab?
**Answer:** The lab applied:
- TLS protocol restrictions (disable SSLv2/SSLv3/TLSv1/TLSv1.1)
- rate limiting to reduce abuse
- header sanitization
- strict permissions on credential files
- configuration validation via `postfix check`
