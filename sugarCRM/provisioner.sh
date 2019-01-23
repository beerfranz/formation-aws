#!/bin/bash


pass=$(sudo grep -Po "Setting Bitnami application password to '\K.*'" /var/log/syslog | sed -e "s/'//g")

echo "Mot de passe : ${pass}"
