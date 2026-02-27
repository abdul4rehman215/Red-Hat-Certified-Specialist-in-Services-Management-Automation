#!/bin/bash
# Lab 02: Creating and Managing Ansible Inventories
# Commands Executed During Lab (Sequential, Clean)

# ------------------------------------------------------------
# Task 1: Creating Static Inventory Files with Multiple Host Groups
# ------------------------------------------------------------

cd /home/ansible
mkdir lab2-inventories
cd lab2-inventories
pwd

# Create basic INI inventory
nano basic_inventory.ini

# Validate inventory structure
ansible-inventory -i basic_inventory.ini --list

# ------------------------------------------------------------
# Task 1.2: Advanced Inventory with Variables (INI)
# ------------------------------------------------------------

nano production_inventory.ini

# Test advanced inventory
ansible-inventory -i production_inventory.ini --list
ansible-inventory -i production_inventory.ini --list --limit webservers
ansible-inventory -i production_inventory.ini --list --yaml

# ------------------------------------------------------------
# Task 1.3: YAML Inventory Format
# ------------------------------------------------------------

nano inventory.yml

# Validate YAML inventory
ansible-inventory -i inventory.yml --list
ansible-inventory -i inventory.yml --host web01
ansible-inventory -i inventory.yml --graph

# ------------------------------------------------------------
# Task 2: Implementing Dynamic Inventories for Cloud Providers
# ------------------------------------------------------------

# Subtask 2.1: AWS dynamic inventory (custom script)
pip3 install boto3 botocore
python3 -c "import boto3; print('boto3 installed successfully')"

mkdir -p ~/.aws
nano ~/.aws/credentials
nano ~/.aws/config

nano aws_ec2_inventory.py
chmod +x aws_ec2_inventory.py

./aws_ec2_inventory.py --list
ansible-inventory -i aws_ec2_inventory.py --list

# Subtask 2.2: Ansible AWS EC2 plugin inventory
nano aws_ec2.yml

ansible-galaxy collection install amazon.aws
ansible-inventory -i aws_ec2.yml --list
ansible-inventory -i aws_ec2.yml --graph

# ------------------------------------------------------------
# Subtask 2.3: Hybrid inventory (directory-based)
# ------------------------------------------------------------

mkdir -p inventories/production
cd inventories/production
pwd

nano static_hosts.ini

# Copy AWS plugin inventory into directory
cp ../../aws_ec2.yml ./
ls -l

# Test combined inventory directory
cd ..
pwd

ansible-inventory -i production/ --list
ansible-inventory -i production/ --graph
ansible-inventory -i production/ --list --limit 'env_production'
ansible-inventory -i production/ --list --limit 'onpremise'

# ------------------------------------------------------------
# Task 3: Testing Inventory Setups Using Ansible Commands
# ------------------------------------------------------------

# Subtask 3.1: Ping tests with different inventory formats
ansible all -i production_inventory.ini -m ping
ansible webservers -i production_inventory.ini -m ping
ansible all -i inventory.yml -m ping

# Subtask 3.1: Gather facts / store as JSON
ansible all -i production_inventory.ini -m setup --tree /tmp/facts
ls -l /tmp/facts | head

ansible webservers -i production_inventory.ini -m setup -a "filter=ansible_os_family"
ansible databases -i production_inventory.ini -m shell -a "df -h"

# ------------------------------------------------------------
# Subtask 3.2: Inventory validation playbook
# ------------------------------------------------------------

nano validate_inventory.yml

ansible-playbook -i production_inventory.ini validate_inventory.yml
ansible-playbook -i inventory.yml validate_inventory.yml
ansible-playbook -i production_inventory.ini validate_inventory.yml -v

# ------------------------------------------------------------
# Subtask 3.3: Inventory troubleshooting and debugging
# ------------------------------------------------------------

# Install jq if missing
command -v jq
sudo yum install -y jq

# Validate inventory render and formatting
ansible-inventory -i production_inventory.ini --list --yaml | python3 -m yaml.tool

# Inspect hostvars, groups, duplicates
ansible-inventory -i production_inventory.ini --host web01
ansible-inventory -i production_inventory.ini --graph
ansible-inventory -i production_inventory.ini --list | jq '.["_meta"]["hostvars"] | keys'

# Create and test debugging script
nano debug_inventory.sh
chmod +x debug_inventory.sh

./debug_inventory.sh production_inventory.ini
./debug_inventory.sh inventory.yml

# ------------------------------------------------------------
# Subtask 3.4: Performance testing with large inventories
# ------------------------------------------------------------

nano generate_large_inventory.py
chmod +x generate_large_inventory.py

./generate_large_inventory.py 500 > large_inventory.ini
wc -l large_inventory.ini

time ansible-inventory -i large_inventory.ini --list > /dev/null
time ansible-inventory -i large_inventory.ini --list --yaml > /dev/null

# ------------------------------------------------------------
# Troubleshooting / Deep Debug Commands
# ------------------------------------------------------------

# Verbose ping with inventory parse info (trim via head during capture)
ansible all -i production_inventory.ini -m ping -vvv | head -n 35

# AWS troubleshooting checks
aws sts get-caller-identity
python3 -c "import boto3; print(boto3.client('ec2').describe_instances()['Reservations'][0].keys())"
ansible-inventory -i aws_ec2.yml --list --export | head -n 25

# YAML syntax check
python3 -c "import yaml; yaml.safe_load(open('inventory.yml')); print('YAML OK')"

# Variable precedence / host var inspection
ansible-inventory -i production_inventory.ini --host web03
