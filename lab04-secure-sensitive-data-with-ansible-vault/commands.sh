#!/bin/bash
# Lab 04: Secure Sensitive Data with Ansible Vault
# Commands Executed During Lab (Sequential, Clean)
# Environment: CentOS/RHEL (Cloud Lab Environment)
# Ansible: 4.x (pre-installed)
# User: centos
# Terminal: -bash-4.2$

# ------------------------------------------------------------
# Task 1: Create an Ansible Vault to Secure Passwords
# ------------------------------------------------------------

mkdir ~/ansible-vault-lab
cd ~/ansible-vault-lab
pwd

# Create encrypted secrets file (interactive editor opens)
ansible-vault create secrets.yml

# Verify file is encrypted (should display vault header + ciphertext)
cat secrets.yml

# Create vault password file (optional, recommended for automation)
echo "mySecurePassword123" > .vault_password
chmod 600 .vault_password
ls -la .vault_password

# ------------------------------------------------------------
# Task 2: Encrypt and Decrypt Files with ansible-vault
# ------------------------------------------------------------

# Create plaintext file (lab used cat <<EOF; created via editor for clean logs)
nano database_config.yml
cat database_config.yml

# Encrypt an existing file (interactive prompt)
ansible-vault encrypt database_config.yml
cat database_config.yml

# View encrypted content without permanent decrypt
ansible-vault view database_config.yml

# Edit encrypted file and add monitoring section
ansible-vault edit database_config.yml
ansible-vault view database_config.yml

# Decrypt a copy (safe practice)
cp database_config.yml database_config_backup.yml
ansible-vault decrypt database_config_backup.yml
cat database_config_backup.yml

# Rekey vault file (kept same password for lab consistency)
ansible-vault rekey secrets.yml

# Use vault password file to avoid interactive prompt
ansible-vault view secrets.yml --vault-password-file .vault_password
ansible-vault edit secrets.yml --vault-password-file .vault_password

# ------------------------------------------------------------
# Task 3: Use Encrypted Variables in Playbooks Securely
# ------------------------------------------------------------

# Inventory (created via editor; content identical)
nano inventory.ini
cat inventory.ini

# Playbook using encrypted vars_files
nano secure_deployment.yml
cat secure_deployment.yml

# Run playbook (prompt for vault password)
ansible-playbook -i inventory.ini secure_deployment.yml --ask-vault-pass

# Run playbook using password file (non-interactive vault decrypt)
ansible-playbook -i inventory.ini secure_deployment.yml --vault-password-file .vault_password

# Verify secure file creation and permissions
ls -la /tmp/app_database.conf /tmp/api_config.env
cat /tmp/app_database.conf
echo "---"
cat /tmp/api_config.env

# Mixed variables playbook (plain + vault vars_files)
nano mixed_variables.yml
cat mixed_variables.yml
ansible-playbook mixed_variables.yml --vault-password-file .vault_password

# ------------------------------------------------------------
# Advanced: Multiple Vault IDs (Different Environments)
# ------------------------------------------------------------

# Create prod vault password file
echo "ProductionVaultPass123" > .vault_password_prod
chmod 600 .vault_password_prod
ls -la .vault_password_prod

# Create prod secrets file encrypted with prod vault id
ansible-vault create --vault-id prod@.vault_password_prod prod_secrets.yml
ansible-vault view prod_secrets.yml --vault-id prod@.vault_password_prod

# Multi-vault playbook
nano multi_vault_playbook.yml
cat multi_vault_playbook.yml

# Run with multiple vault ids (default + prod)
ansible-playbook multi_vault_playbook.yml --vault-id default@.vault_password --vault-id prod@.vault_password_prod

# ------------------------------------------------------------
# Troubleshooting / Best Practices Commands
# ------------------------------------------------------------

# Permission checks
ls -la
chmod 755 ~/ansible-vault-lab

# Vault integrity checks
file secrets.yml
head -1 secrets.yml

# Editor preference
export EDITOR=nano
export EDITOR=vim
ansible-vault edit secrets.yml

# .gitignore hardening for vault passwords
echo ".vault_password*" >> .gitignore
echo "*.vault_pass" >> .gitignore
cat .gitignore

# ------------------------------------------------------------
# Cleanup (Optional / Lab Hygiene)
# ------------------------------------------------------------

rm -f /tmp/app_database.conf
rm -f /tmp/api_config.env
rm -f /tmp/complete_app_config.env
rm -f /tmp/multi_env_config.env

cd ~
rm -rf ~/ansible-vault-lab
