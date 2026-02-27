# 🎤 Interview Q&A — Lab 04: Secure Sensitive Data with Ansible Vault

> Focus: Why Vault is needed, how it works, commands, password files, vault IDs, secure playbook patterns, and Git hygiene.

---

## 1) Why is securing sensitive data important in automation?
**Answer:**  
Automation often includes credentials (DB passwords, API keys, SSH secrets). If stored in plain text, they can leak via Git commits, logs, CI artifacts, or shared playbooks. Securing secrets is critical for compliance, reducing breach risk, and maintaining professional security standards.

---

## 2) What is Ansible Vault?
**Answer:**  
Ansible Vault encrypts sensitive files or variables so they can safely live alongside playbooks. Encrypted content can be decrypted only when running Ansible with the correct vault password (or vault-id key).

---

## 3) What does an encrypted vault file look like?
**Answer:**  
Vault files start with a header like:
```

$ANSIBLE_VAULT;1.1;AES256

````
Followed by encrypted ciphertext lines.

---

## 4) What is the difference between `ansible-vault create` and `ansible-vault encrypt`?
**Answer:**  
- `ansible-vault create <file>`: creates a new encrypted file from scratch using an editor.  
- `ansible-vault encrypt <file>`: encrypts an existing plaintext file.

---

## 5) How can you view encrypted content without decrypting it permanently?
**Answer:**  
Use:
```bash
ansible-vault view <file>
````

This decrypts temporarily for viewing only and keeps the file encrypted on disk.

---

## 6) How do you edit an encrypted vault file safely?

**Answer:**
Use:

```bash
ansible-vault edit <file>
```

It opens the file in an editor and re-encrypts it automatically on save/exit.

---

## 7) What does `ansible-vault decrypt` do and why should it be used carefully?

**Answer:**
It permanently decrypts the file into plaintext. This is risky because secrets can be exposed on disk or accidentally committed. Best practice is to decrypt only a copy if needed (as done in the lab).

---

## 8) What is `ansible-vault rekey` used for?

**Answer:**
`rekey` changes the vault password used to encrypt a vault file. This supports password rotation and recovery from compromised credentials.

---

## 9) What is a vault password file and why is it useful?

**Answer:**
A vault password file provides the vault password non-interactively:

```bash
--vault-password-file .vault_password
```

Useful for automation/CI pipelines, but it must be protected (`chmod 600`) and **never committed** to Git.

---

## 10) How do you load vault-encrypted variables into a playbook?

**Answer:**
Use `vars_files`:

```yaml
vars_files:
  - secrets.yml
  - database_config.yml
```

Then run with `--ask-vault-pass` or `--vault-password-file`.

---

## 11) What are vault IDs and why are they used?

**Answer:**
Vault IDs allow multiple vault passwords for different environments (dev/prod):

```bash
--vault-id default@.vault_password --vault-id prod@.vault_password_prod
```

This supports clean separation of secrets by environment and reduces operational risk.

---

## 12) What is a secure way to “debug” playbooks that use secrets?

**Answer:**
Never print secrets directly. Debug should confirm configuration without exposing values, for example:

* show host/port/user (safe)
* do not print passwords/tokens/keys
  In the lab, the playbook printed a masked message like “Production DB Password is configured”.

---

## 13) What Linux permissions should vault password files and generated secret configs have?

**Answer:**

* vault password files: `chmod 600`
* generated secret configs: `mode: '0600'`
  This reduces access to owner-only.

---

## 14) How do you prevent vault password files from being committed to Git?

**Answer:**
Add patterns to `.gitignore`:

```gitignore
.vault_password*
*.vault_pass
```

And only keep `*.example` placeholders in the repo if needed.

---

## 15) What happens if you forget the vault password?

**Answer:**
You cannot recover it. You must treat vault passwords like encryption keys:

* store securely in a password manager / secret manager
* use vault IDs and documented secure processes
* keep protected backups where appropriate

---
