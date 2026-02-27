# 🔐 TLS Certificate Generation (Lab Reference)

This lab demonstrated enabling encrypted syslog transport using `rsyslog-gnutls`.

## 1) Install TLS module
```bash
sudo dnf install rsyslog-gnutls -y
```
## 2) Generate test certificates (self-signed, lab only)
```
sudo mkdir -p /etc/rsyslog-certs
```

```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/rsyslog-certs/server-key.pem \
  -out /etc/rsyslog-certs/server-cert.pem
```

## 3) Add TLS listener config

Append the snippet from:
```
server/tls/rsyslog.conf.tls-snippet.conf
```
Then restart:
```
sudo systemctl restart rsyslog
```

## ⚠️ Security Note
Use a real CA + client auth for production environments.


### ✅ `server/tls/.gitignore`

```gitignore id="v8y9r2"
# TLS secrets (do not commit)
server-key.pem
server-cert.pem
*.pem
*.key
*.crt
```
