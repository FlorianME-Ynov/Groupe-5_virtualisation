sudo apt-get -y install docker docker-compose
sudo wget https://github.com/FlorianME-Ynov/Groupe-5_virtualisation/blob/main/docker-compose.yaml
mkdir multimedia-project
cd multimedia-project
sudo wget https://github.com/FlorianME-Ynov/Groupe-5_virtualisation/blob/main/Configs
mkdir -p {jacket,jellyfin,radarr,sonarr,transmission,torrents,videos,cloudfare,bazarr,nzbhydra2,organizr,heimdall}
cd ..
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
