#!/bin/bash

# Installation de terraform

wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip

unzip terraform_0.11.11_linux_amd64.zip
rm terraform_0.11.11_linux_amd64.zip

mv terraform /usr/local/bin/

which terraform > /dev/null

if [ $? -eq 0 ]; then
	echo "Terraform installé avec succès"
else
	echo "Echec de l'installation"
	exit 1
fi
