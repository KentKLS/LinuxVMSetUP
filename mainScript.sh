#!/usr/bin/sh

#Write a variable that will store the name we wanna give to our VM
vm_name="test123"

#if else statement that start the VM if it already exist, else it create it with the set specification
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

#start the newly created VM
sudo virsh start "$vm_name"
#wait 30sec for the VM to start fully (that could be modyfied but it works for now)
sleep 30

#First we get the VM mac address to then get the VM ipv4 address 
vm_macAddr=$(virsh dumpxml "$vm_name" | grep "mac address" | awk -F\' '{ print $2}')
vm_ipv4=$(arp -an | grep "$vm_macAddr" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')

#We use the ipv4 address we got just above to copy a script into the VM home directory
scp -o StrictHostKeyChecking=no /home/quentinsirjean/test1/installDep.sh root@$vm_ipv4:/home/

#We the connect to the VM and execute said script 
ssh -o "StrictHostKeyChecking=no" root@$vm_ipv4 "cd /home/ && ./VMInit.sh"

#We open a new gnome terminal directly connected to the VM so that we can execute whatever we need/want
gnome-terminal -- bash -c "ssh -o "StrictHostKeyChecking=no" root@$vm_ipv4; exec bash"

fi
