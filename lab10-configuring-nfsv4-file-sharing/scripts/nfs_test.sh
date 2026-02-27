#!/bin/bash
echo "=== NFS Functionality Test ==="

# Test 1: Check mounts
echo "1. Checking NFS mounts:"
df -h | grep nfs4

# Test 2: Test read access
echo "2. Testing read access:"
cat /mnt/nfs/documents/sample_document.txt

# Test 3: Test write access
echo "3. Testing write access:"
echo "Final test $(date)" | sudo tee /mnt/nfs/shared/final_test.txt
cat /mnt/nfs/shared/final_test.txt

# Test 4: Test directory creation
echo "4. Testing directory operations:"
sudo mkdir -p /mnt/nfs/shared/test_dir
ls -la /mnt/nfs/shared/ | grep test_dir

echo "=== All tests completed ==="
