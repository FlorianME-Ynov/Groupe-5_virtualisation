#! /bin/bash

wget https://raw.githubusercontent.com/FlorianME-Ynov/Groupe-5_virtualisation/main/script.sh
curl https://raw.githubusercontent.com/FlorianME-Ynov/Groupe-5_virtualisation/main/docker-compose.yaml --output ./docker-compose.yaml
wget https://github.com/FlorianME-Ynov/Groupe-5_virtualisation/raw/main/Configs

chmod 777 script.sh
sudo ./script.sh
