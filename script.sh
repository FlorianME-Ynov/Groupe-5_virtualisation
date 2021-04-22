#! /bin/bash

PreRequired()
{
  sudo apt-get -y install docker docker-compose
}


GetAndInstall()
{
  wget https://github.com/FlorianME-Ynov/Groupe-5_virtualisation/raw/main/reverse_proxy.tar
  curl https://raw.githubusercontent.com/FlorianME-Ynov/Groupe-5_virtualisation/main/docker-compose.yaml --output ./docker-compose.yaml
  wget https://github.com/FlorianME-Ynov/Groupe-5_virtualisation/raw/main/Configs

  if [ ! -d ./multimedia-project ]; then
    mkdir multimedia-project
    cd multimedia-project
    mkdir -p {jacket,jellyfin,radarr,sonarr,transmission,torrents,videos,cloudfare,bazarr,nzbhydra2,organizr,heimdall}
    cd ..
    tar -xf ./Configs -C ./
  fi

  if [ ! -d ./reverse_proxy ]; then
    tar -xf ./reverse_proxy.tar -C ./
    sudo chmod -R 600 ./reverse_proxy/acme.json
  fi
}

ReplaceNames()
{
  #Variables
  reverse_proxy_config="./reverse_proxy/traefik.toml"
  docker_compose_config="./docker-compose.yaml"

  sudo chmod 777 $reverse_proxy_config
  sudo chmod 777 $docker_compose_config

  # Take the search string
  search_name="{name}"
  search_email="{email}"
  search_dns="{dns}"

  # Take the replace string
  echo "Informations LetsEncrypt"
  read -p "Entrez votre nom: " replace_name
  read -p "Entrez votre Email: " replace_email
  read -p "Entrez votre FQDN: " replace_dns

  #Modification des noms
  if [[ $search_name != "" && $replace_name != "" ]]; then
  sed -i "s/$search_name/$replace_name/gi" $reverse_proxy_config
  sed -i "s/$search_name/$replace_name/gi" $docker_compose_config
  fi

  #Modification de l'email 
  if [[ $search_email != "" && $replace_email != "" ]]; then
  sed -i "s/$search_email/$replace_email/gi" $reverse_proxy_config
  fi

  #Modification du DockerCompose avec les nom et FQDN
  if [[ $search_dns != "" && $replace_dns != "" ]]; then
  sed -i "s/$search_dns/$replace_dns/gi" $docker_compose_config
  fi
}

echo "--- Multimedia Server ---"
echo ""
echo "Installation et Reload"
echo "<1> 	Installation Complète"
echo "<2> 	Recharger la configuration initiale"
echo ""
echo "Gestion de containers"
echo "<3> 	Lancer les containers"
echo "<4> 	Arreter les containers"
echo "<5> 	Relancer les containers"
echo ""
echo "Gestion et mise à jour"
echo "<6>   Lancer la supervision"
echo ""
echo "Autres Options"
echo "<q>	q = Quitter"
read choix 
case $choix in 
  1) 
    PreRequired
    GetAndInstall
    ReplaceNames
    sudo docker-compose up -d
    sleep 100
    sudo docker-compose down
    sudo docker-compose up -d
  ;;
  2) 
    sudo tar -xvf ./Configs -C ./
    tar -xf ./reverse_proxy.tar -C ./
    sudo chmod -R 600 ./reverse_proxy/acme.json
    ReplaceNames
    sudo ./script.sh
  ;;

  3) 
    sudo docker-compose up -d
  ;;

  4) 
    sudo docker-compose down
  ;;

  5) 
    sudo docker-compose down
    sudo docker-compose up -d
  ;;

  6) 
    read -p "Zabbix Appliance Server address: " zabbix_app_addr
    sudo docker run -d \
      -p 8000:8000 \
      -p 9000:9000 \
      --name=portainer \
      --restart=always \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data portainer/portainer-ce 
      
    sudo docker run \
      --name=dockbix-agent-xxl \
      --net=host \
      --privileged \
      -v /:/rootfs \
      -v /var/run:/var/run \
      --restart unless-stopped \
      -e ZA_Server=$zabbix_app_addr \
      -d monitoringartist/dockbix-agent-xxl-limited:latest

  ;;
  
  q) exit;;
esac
