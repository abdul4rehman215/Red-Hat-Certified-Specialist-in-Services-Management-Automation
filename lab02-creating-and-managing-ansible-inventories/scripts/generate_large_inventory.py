#!/usr/bin/env python3
import sys

def generate_inventory(num_hosts=100):
    """Generate a large inventory file for testing"""

    print("[webservers]")
    for i in range(1, num_hosts // 2 + 1):
        print(f"web{i:03d} ansible_host=10.0.1.{i % 254 + 1}")

    print("\n[databases]")
    for i in range(1, num_hosts // 4 + 1):
        print(f"db{i:03d} ansible_host=10.0.2.{i % 254 + 1}")

    print("\n[monitoring]")
    for i in range(1, num_hosts // 4 + 1):
        print(f"monitor{i:03d} ansible_host=10.0.3.{i % 254 + 1}")

    print("\n[production:children]")
    print("webservers")
    print("databases")
    print("monitoring")

    print("\n[production:vars]")
    print("ansible_user=testuser")
    print("ansible_ssh_private_key_file=/home/ansible/.ssh/test_key")

if __name__ == "__main__":
    num_hosts = int(sys.argv[1]) if len(sys.argv) > 1 else 100
    generate_inventory(num_hosts)
