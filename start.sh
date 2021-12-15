#!/bin/bash

set -e

GREEN='\e[32m'
BOLD='\e[1m'
BLUE='\e[34m'
END='\e[0m'

echo -e "${BOLD}${BLUE}Preparing...${END}"
if [[ -z $(which jq) ]]
then
    sudo apt update
    sudo apt install jq -y
fi

echo -e "${BOLD}${BLUE}Generate new ssh-key...${END}"

ssh-keygen -q -t rsa -b 4096 -f ~/.ssh/yandex-cloud -N ""


echo -e "${BOLD}${BLUE}Start Terraform...${END}"

cd ./Terraform
terraform init
terraform plan
terraform apply -auto-approve
BASTION_IP=$(terraform output -json bastion_extIP | jq -j)

echo -e "\n${BOLD}${GREEN}[INFORM]:${END} bastion_host IP set to ${BOLD}$BASTION_IP${END}\n"

echo -e "${BOLD}${BLUE}Copy ssh-key to bastion host...${END}"

cat ~/.ssh/id_rsa.pub | ssh -i ~/.ssh/yandex-cloud ubuntu@${BASTION_IP} 'cat >> .ssh/authorized_keys'
scp ~/.ssh/yandex-cloud ubuntu@${BASTION_IP}:~/.ssh/id_rsa
scp ~/.ssh/yandex-cloud.pub ubuntu@${BASTION_IP}:~/.ssh/id_rsa.pub

echo -e "${BOLD}${BLUE}Start Ansible...${END}"
cd ../Ansible
ansible-playbook start-playbook.yml -e bastion_host=$BASTION_IP
