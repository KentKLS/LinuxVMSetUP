#!/usr/bin/sh

vm_name="test-v1"

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
--initrd-inject /home/quentinsirjean/test1/preseed.cfg \
--noreboot 

sudo virsh start "$vm_name"
sleep 30

vm_macAddr=$(virsh dumpxml "$vm_name" | grep "mac address" | awk -F\' '{ print $2}')
vm_ipv4=$(arp -an | grep "$vm_macAddr" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')


scp /home/quentinsirjean/test1/installDep.sh root@$vm_ipv4:/home/
ssh -o "StrictHostKeyChecking=no" root@$vm_ipv4 "cd /home/ && ./installDep.sh"
gnome-terminal -- bash -c "ssh root@$vm_ipv4; exec bash"

fi
