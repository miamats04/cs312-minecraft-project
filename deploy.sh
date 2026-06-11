#!/bin/bash

# initialize terraform
echo "Initializing Terraform"
terraform init
terraform apply -auto-approve

# get the minecraft instance IP from output.tf
echo "Getting minecraft instance IP from output.tf"
INSTANCE_IP=$(terraform output -raw minecraft_ip)

# create inventory.ini file with the instance IP and ssh file
echo "Creating inventory.ini file"
cat <<EOF > inventory.ini
[minecraft]
$INSTANCE_IP ansible_user=ubuntu ansible_ssh_private_key_file=./minecraft_key.pem
EOF

sleep 45

# run the ansible playbook
echo "Running Ansible playbook"
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml

# verify that the Mincraft port is open using nmap:

echo "Minecraft Server Address: $INSTANCE_IP:25565"
echo "Verify with: nmap -sV -Pn -p T:25565 $INSTANCE_IP"


exit 0