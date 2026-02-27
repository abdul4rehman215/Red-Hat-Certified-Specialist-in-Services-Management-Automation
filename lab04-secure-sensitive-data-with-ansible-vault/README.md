# 🧪 Lab 04: Secure Sensitive Data with Ansible Vault

> **Track:** Red Hat Certified Specialist in Services Management & Automation (Exam Labs)  
> **Lab Focus:** Encrypting secrets with `ansible-vault`, using vault password files safely, integrating encrypted vars into playbooks, and applying secure Git hygiene.

---

## 🧰 Lab Environment

| Item | Value |
|---|---|
| OS | CentOS/RHEL (Cloud Lab Environment) |
| Ansible | 4.x (pre-installed) |
| User | `centos` |
| Terminal | `-bash-4.2$` |
| Workdir | `~/ansible-vault-lab` |

> **Important (Portfolio Safety):**  
> This lab contains **sensitive-data examples**. In this GitHub version, vault passwords and real secrets are treated as *training placeholders* and protected using `.gitignore`. Never commit real passwords/keys.

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand why securing sensitive automation data is critical
- Create and manage **Ansible Vault** encrypted files
- Use core vault commands: `create`, `encrypt`, `decrypt`, `view`, `edit`, `rekey`
- Integrate encrypted variable files into playbooks safely
- Use **vault password files** and **vault IDs** for multi-environment workflows
- Apply best practices for Git + secrets handling

---

## ✅ Prerequisites

- Linux CLI fundamentals
- Ansible basics (playbooks, variables, tasks)
- YAML syntax familiarity
- File permissions understanding (`chmod`, ownership)
- Basic text editor usage (`vim`/`nano`)

---

## 📁 Repository Structure (Lab Folder)

```text
lab04-secure-sensitive-data-with-ansible-vault/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── .gitignore
    ├── inventory.ini
    ├── secure_deployment.yml
    ├── mixed_variables.yml
    ├── multi_vault_playbook.yml
    ├── secrets.yml
    ├── database_config.yml
    ├── database_config_backup.yml
    ├── prod_secrets.yml
    ├── .vault_password.example
    └── .vault_password_prod.example
````

> **Notes**
>
> * `secrets.yml`, `database_config.yml`, `prod_secrets.yml` are committed **encrypted** (vault format).
> * Real vault password files are **never committed**. Only `*.example` placeholders exist in the repo.
> * Cleanup commands are included in `commands.sh` and `output.txt` to reflect real workflow.

---

## 🧩 Lab Tasks Overview (What was done)

### 🔐 Task 1: Create an Ansible Vault to Secure Passwords

* Created a dedicated workspace: `~/ansible-vault-lab`
* Created an encrypted secrets file:

  * `ansible-vault create secrets.yml`
* Verified vault encryption via `cat secrets.yml`
* Created a local vault password file for non-interactive runs:

  * `.vault_password` with `chmod 600`
* Added vault password patterns to `.gitignore`

✅ Result: Sensitive variables are stored encrypted and protected from accidental Git commits.

---

### 🔁 Task 2: Encrypt, View, Edit, Decrypt, and Rekey Vault Files

* Created a plaintext YAML file (`database_config.yml`) then encrypted it:

  * `ansible-vault encrypt database_config.yml`
* Viewed encrypted content safely:

  * `ansible-vault view database_config.yml`
* Edited encrypted content:

  * `ansible-vault edit database_config.yml` (added monitoring secrets)
* Decrypted a copy safely:

  * `cp database_config.yml database_config_backup.yml`
  * `ansible-vault decrypt database_config_backup.yml`
* Rekeyed a vault file:

  * `ansible-vault rekey secrets.yml` (kept same password for lab consistency)

✅ Result: Full lifecycle of vault operations practiced with safe workflows.

---

### 🧩 Task 3: Use Encrypted Variables in Playbooks Securely

* Created a local inventory (`inventory.ini`) using `ansible_connection=local`
* Created `secure_deployment.yml` that loads encrypted vars via `vars_files`
* Ran playbook with:

  * `--ask-vault-pass`
  * `--vault-password-file .vault_password`
* Generated config files with secure permissions (`0600`) under `/tmp/`
* Verified files exist + permissions + content rendering

✅ Result: Encrypted vars integrated into automation without exposing passwords in plaintext source files.

---

### 🧪 Advanced: Multiple Vault IDs (Multi-Environment Secrets)

* Created production vault password file locally:

  * `.vault_password_prod` with `chmod 600`
* Created a separate vault file using a vault ID:

  * `ansible-vault create --vault-id prod@.vault_password_prod prod_secrets.yml`
* Created `multi_vault_playbook.yml` that consumes:

  * default vault + prod vault
* Executed with both vault IDs:

  * `--vault-id default@.vault_password --vault-id prod@.vault_password_prod`

✅ Result: Environment separation achieved without mixing secrets.

---

## ✅ Validation (What was verified)

* Vault files show encrypted header:

  * `$ANSIBLE_VAULT;1.1;AES256`
* Playbooks successfully decrypt at runtime and create:

  * `/tmp/app_database.conf`
  * `/tmp/api_config.env`
  * `/tmp/complete_app_config.env`
  * `/tmp/multi_env_config.env`
* Secure file permissions confirmed:

  * `-rw-------` (0600)

---

## 🧠 What I Learned

* How to keep secrets out of Git and still run automation reliably
* Vault command workflows for real operations (create/edit/view/rekey)
* How to use password files safely (and why they must be ignored in Git)
* Why multi-vault setups matter for real orgs (dev/prod separation)
* How to generate secure config artifacts with correct filesystem permissions

---

## 🌍 Why This Matters (Real-World Relevance)

* Prevents credential leaks in code repositories and CI/CD logs
* Supports compliance and auditability
* Enables secure automation at scale (teams + pipelines)
* Makes automation “production-grade” by design

---

## ✅ Result

* Vault files created and managed successfully
* Encrypted variables used securely inside playbooks
* Password files protected using strict permissions + `.gitignore`
* Multi-vault ID workflow demonstrated for multiple environments

---
