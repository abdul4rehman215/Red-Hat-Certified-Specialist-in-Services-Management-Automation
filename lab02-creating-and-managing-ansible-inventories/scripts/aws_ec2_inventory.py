#!/usr/bin/env python3
import boto3
import json
import sys

def get_ec2_inventory():
    """
    Generate dynamic inventory from AWS EC2 instances
    """
    inventory = {
        "_meta": {
            "hostvars": {}
        }
    }

    # Initialize EC2 client
    try:
        ec2 = boto3.client("ec2")
        response = ec2.describe_instances()
    except Exception as e:
        print(f"Error connecting to AWS: {e}", file=sys.stderr)
        return inventory

    # Process instances
    for reservation in response.get("Reservations", []):
        for instance in reservation.get("Instances", []):
            if instance.get("State", {}).get("Name") != "running":
                continue

            instance_id = instance.get("InstanceId", "")
            private_ip = instance.get("PrivateIpAddress", "")
            public_ip = instance.get("PublicIpAddress", "")

            # Get instance tags
            tags = {tag["Key"]: tag["Value"] for tag in instance.get("Tags", [])}
            instance_name = tags.get("Name", instance_id)

            # Add to inventory
            inventory["_meta"]["hostvars"][instance_name] = {
                "ansible_host": public_ip or private_ip,
                "ec2_instance_id": instance_id,
                "ec2_instance_type": instance.get("InstanceType", ""),
                "ec2_private_ip": private_ip,
                "ec2_public_ip": public_ip,
                "ec2_state": instance.get("State", {}).get("Name", ""),
                "ec2_tags": tags
            }

            # Group by tags
            for key, value in tags.items():
                group_name = f"{key}_{value}".replace(" ", "_").replace("-", "_").lower()
                if group_name not in inventory:
                    inventory[group_name] = {"hosts": []}
                inventory[group_name]["hosts"].append(instance_name)

            # Group by instance type
            itype = instance.get("InstanceType", "unknown").replace(".", "_")
            instance_type_group = f"type_{itype}"
            if instance_type_group not in inventory:
                inventory[instance_type_group] = {"hosts": []}
            inventory[instance_type_group]["hosts"].append(instance_name)

    return inventory

if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "--list":
        inv = get_ec2_inventory()
        print(json.dumps(inv, indent=2))
    elif len(sys.argv) == 3 and sys.argv[1] == "--host":
        # Return empty dict for host-specific vars (handled in --list)
        print(json.dumps({}))
    else:
        print("Usage: aws_ec2_inventory.py --list")
        print("       aws_ec2_inventory.py --host <hostname>")
        sys.exit(1)
