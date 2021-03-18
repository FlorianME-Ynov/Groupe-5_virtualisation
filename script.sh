#! /bin/bash
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
  1) sudo apt-get -y install docker docker-compose
    sudo docker-compose down
    mkdir multimedia-project
    cd multimedia-project
    mkdir -p {jacket,jellyfin,radarr,sonarr,transmission,torrents,videos,cloudfare,bazarr,nzbhydra2,organizr,heimdall}
    cd ..
    wget https://github.com/FlorianME-Ynov/Groupe-5_virtualisation/blob/7e32149e47f577ec2a04febbe7a8d464a83d9fa8/docker-compose.yaml
    tar -xf ./Configs -C ./
    sudo docker-compose up -d
    sudo docker run -d \
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
