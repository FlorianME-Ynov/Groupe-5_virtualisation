#! /bin/bash

wget https://github.com/FlorianME-Ynov/Groupe-5_virtualisation/raw/main/reverse_proxy.tar
curl https://raw.githubusercontent.com/FlorianME-Ynov/Groupe-5_virtualisation/main/docker-compose.yaml --output ./docker-compose.yaml
wget https://github.com/FlorianME-Ynov/Groupe-5_virtualisation/raw/main/Configs

DIR_Projet="./multimedia-project/"
if [ -d "$DIR_Projet" ]; then
else
  tar -xf ./Configs -C ./
  exit 1
fi

DIR_proxy="./reverse_proxy/"
if [ -d "$DIR_proxy" ]; then
else
  tar -xf ./reverse_proxy.tar -C ./
  exit 1
fi  


#Variables
reverse_proxy_config="./reverse_proxy/traefik.toml"
docker_compose_config="./docker-compose.yaml"

# Take the search string
search_name="{name}"
search_email="{email}"
search_dns="{dns}"

# Take the replace string
read -p "Entrez votre nom: " replace_name
read -p "Entrez votre Email: " replace_email
read -p "Entrez votre FQDN: " replace_dns

#Modification des noms
if [[ $search_name != "" && $replace_name != "" ]]; then
sed -i "s/$search/$replace/gi" $reverse_proxy_config
sed -i "s/$search/$replace/gi" $docker_compose_config
fi

#Modification de l'email 
if [[ $search_email != "" && $replace_email != "" ]]; then
sed -i "s/$search/$replace/gi" $reverse_proxy_config
fi

#Modification du DockerCompose avec les nom et FQDN
if [[ $search_dns != "" && $replace_dns != "" ]]; then
sed -i "s/$search/$replace/gi" $docker_compose_config
fi

echo "--- Multimedia Server ---"
echo ""
echo "Installation et Reload"
echo "<1> 	Installation Complète"
echo "<2> 	Recharger la configuration initiale"
echo ""
echo "Gestion de containers"
echo "<3> 	Lancer les containers"
echo "<4> 	Arreter les containers"cd ..
echo "<5> 	Relancer les containers"
echo ""
echo "Gestion et mise à jour"
echo "<6>   Lancer la supervision"
echo ""
echo "Autres Options"
echo "<q>	q = Quitter"
read choix 
case $choix in 
  1) sudo apt-get -y install docker docker-compose

    curl https://raw.githubusercontent.com/FlorianME-Ynov/Groupe-5_virtualisation/main/docker-compose.yaml --output ./docker-compose.yaml
    wget https://github.com/FlorianME-Ynov/Groupe-5_virtualisation/raw/main/Configs

    mkdir multimedia-project
    cd multimedia-project
    mkdir -p {jacket,jellyfin,radarr,sonarr,transmission,torrents,videos,cloudfare,bazarr,nzbhydra2,organizr,heimdall}
    cd ..
    tar -xf ./Configs -C ./
    sudo docker-compose up -d
  ;;
  2) sudo tar -xvf ./Configs -C ./
  ;;

  3) sudo docker-compose up -d
  ;;

  4) sudo docker-compose down
  ;;

  5) sudo docker-compose down
     sudo docker-compose up -d
  ;;

  6) sudo docker run -d \
      -p 8000:8000 \
      -p 9000:9000 \
      --name=portainer \
      --restart=always \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data portainer/portainer-ce 

    sudo docker run -d \
      --name watchtower \
      -v /var/run/docker.sock:/var/run/docker.sock \
      containrrr/watchtower
  ;;
  
  q) exit;;
esac

