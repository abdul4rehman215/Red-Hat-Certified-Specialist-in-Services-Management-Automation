# 🛠️ Troubleshooting Guide — Lab 04: Secure Sensitive Data with Ansible Vault

> This file documents common Vault-related issues and the exact commands used to diagnose and resolve them.

---

## 1) Forgot Vault Password (Most Common and Most Serious)

### ✅ Symptoms
- Cannot decrypt or view vault files
- Playbooks fail when loading encrypted vars

### 🔍 Reality Check
There is **no password recovery** for Ansible Vault. If the password is lost, encrypted data is effectively unrecoverable.

### ✅ Prevention
- Store vault passwords in a secure password manager
- Use separate vault IDs per environment
- Maintain secure documentation of key ownership/access
- Avoid “single-person knowledge” for critical secrets in teams

---

## 2) Permission Denied When Creating or Writing Files

### ✅ Symptoms
- Errors like `Permission denied` when creating `.vault_password`, vault files, or output files in `/tmp`

### 🔍 Common Causes
- Incorrect directory permissions
- Wrong ownership or restrictive parent directory perms

### ✅ Fix / Validation (used in lab)
```bash id="9w0fjw"
ls -la
chmod 755 ~/ansible-vault-lab
````

---

## 3) Vault File Appears Corrupted / Won’t Decrypt

### ✅ Symptoms

* `ansible-vault view` fails
* Errors about invalid vault format
* File content doesn’t look like ciphertext

### 🔍 Common Causes

* File edited manually and formatting damaged
* Partial copy/paste truncation
* Wrong file actually being used

### ✅ Fix / Validation (used in lab)

```bash id="w6b8me"
file secrets.yml
head -1 secrets.yml
```

Expected first line:

````text
$ANSIBLE_VAULT;1.1;AES256
``` id="prp9gk"

---

## 4) Vault Password File Not Working

### ✅ Symptoms
- Still prompts for vault password
- “Decryption failed” even though password should be correct

### 🔍 Common Causes
- Wrong path or filename
- Password file has extra spaces/newlines
- File permissions too open or blocked by policy

### ✅ Fix / Validation
```bash id="wba6mt"
# check file permissions (should be 600)
ls -la .vault_password

# ensure file contains only the password (no extra output)
cat .vault_password

# re-run with explicit password file path
ansible-vault view secrets.yml --vault-password-file .vault_password
````

---

## 5) Playbook Fails to Load `vars_files`

### ✅ Symptoms

* Error like “could not find or access secrets.yml”
* Playbook fails before tasks run

### 🔍 Common Causes

* Wrong working directory
* Relative path mismatch
* File is not actually encrypted, or is encrypted with a different vault-id/pass

### ✅ Fix / Validation

```bash id="e5bw1r"
pwd
ls -la

# confirm inventory and vars_files exist
ls -la secrets.yml database_config.yml

# confirm vault file header exists
head -1 secrets.yml
head -1 database_config.yml
```

---

## 6) Multiple Vault IDs Fail (Default + Prod)

### ✅ Symptoms

* “Decryption failed”
* One vault file decrypts but the other fails

### 🔍 Common Causes

* Wrong vault ID mapping
* Prod secrets encrypted with different password than `.vault_password_prod`
* Running command with missing `--vault-id` for one of the vaults

### ✅ Fix / Validation (used in lab)

```bash id="fbcg6k"
# validate prod password file perms
ls -la .vault_password_prod

# view prod file using correct vault id mapping
ansible-vault view prod_secrets.yml --vault-id prod@.vault_password_prod

# run playbook with both vault IDs
ansible-playbook multi_vault_playbook.yml \
  --vault-id default@.vault_password \
  --vault-id prod@.vault_password_prod
```

---

## 7) Editor Problems (Vault Opens in an Unfamiliar Editor)

### ✅ Symptoms

* `ansible-vault create/edit` opens an editor you don’t want
* Difficulty saving/exiting

### ✅ Fix (used in lab)

```bash id="do9x2b"
export EDITOR=nano
# or
export EDITOR=vim

ansible-vault edit secrets.yml
```

---

## 8) Accidentally Committed Vault Password File to Git

### ✅ Symptoms

* `.vault_password` shows up in `git status`
* Password file pushed to remote repository (high severity)

### ✅ Fix / Prevention (best practice used in lab)

```bash id="s5f6ty"
echo ".vault_password*" >> .gitignore
echo "*.vault_pass" >> .gitignore
cat .gitignore
```

### ✅ If Already Committed

* Remove it from Git history (requires history rewrite) and rotate vault password immediately:

```bash
ansible-vault rekey secrets.yml
```

Then replace credentials if they were real.

---

## 9) Generated Config Files in `/tmp` Have Wrong Permissions

### ✅ Symptoms

* Files created but are readable by others
* Compliance issue: secrets on disk too permissive

### ✅ Fix

Ensure playbooks set:

* `mode: '0600'`

### ✅ Verify (used in lab)

```bash id="h61x4t"
ls -la /tmp/app_database.conf /tmp/api_config.env
```

Expected:

* `-rw-------`

---

## ✅ Quick Recovery Checklist

# 1) Confirm vault files exist and look valid
```
ls -la
head -1 secrets.yml
head -1 database_config.yml
```

# 2) Confirm password file perms
```
ls -la .vault_password
ls -la .vault_password_prod
```

# 3) Test decrypt/view quickly
```
ansible-vault view secrets.yml --vault-password-file .vault_password
ansible-vault view prod_secrets.yml --vault-id prod@.vault_password_prod
```

# 4) Run playbook (single vault)
```
ansible-playbook -i inventory.ini secure_deployment.yml --vault-password-file .vault_password
```

# 5) Run playbook (multi vault)
```
ansible-playbook multi_vault_playbook.yml \
  --vault-id default@.vault_password \
  --vault-id prod@.vault_password_prod
```

---
