#!/bin/bash
INVENTORY_FILE=$1

if [ -z "$INVENTORY_FILE" ]; then
  echo "Usage: $0 <inventory_file>"
  exit 1
fi

echo "=== Inventory Debug Report ==="
echo "Inventory file: $INVENTORY_FILE"
echo "Generated on: $(date)"
echo

echo "=== Inventory Structure ==="
ansible-inventory -i "$INVENTORY_FILE" --graph
echo

echo "=== All Hosts ==="
ansible-inventory -i "$INVENTORY_FILE" --list | jq -r '._meta.hostvars | keys[]' | sort
echo

echo "=== Groups ==="
ansible-inventory -i "$INVENTORY_FILE" --list | jq -r 'keys[]' | grep -v "_meta" | sort
echo

echo "=== Connectivity Test ==="
ansible all -i "$INVENTORY_FILE" -m ping --one-line
echo

echo "=== Host Variables Sample (first host) ==="
FIRST_HOST=$(ansible-inventory -i "$INVENTORY_FILE" --list | jq -r '._meta.hostvars | keys[0]')
if [ "$FIRST_HOST" != "null" ]; then
  ansible-inventory -i "$INVENTORY_FILE" --host "$FIRST_HOST"
fi
