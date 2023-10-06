#!/usr/bin/sh

vm_name="test-vm"

if sudo virsh list --all | grep -q "$vm_name"; then
  echo "VM $vm_name already exists. Starting it..."
  sudo virsh start "$vm_name"
else

sudo virt-install \
--name $vm_name \
--ram 2048 \
--vcpus 2 \
--disk size=20 \
--graphics spice \
--console pty,target_type=serial \
--location /home/quentinsirjean/Downloads/debian-12.1.0-amd64-DVD-1.iso \
--initrd-inject /home/quentinsirjean/test1/preseed.cfg
fi