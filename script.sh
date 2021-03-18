GREEN='\033[0;32m'
NORMAL='\033[0m' # No Color
BOLD=$(tput bold) #text en gras
RED='\033[0;31m'
ping -c 1 8.8.8.8 &> /dev/null

#Mise en place de garde fou en fonction de l'accès réseau et check si l'user=ROOT
if [[ $? -ne 0 ]];
then
    echo -e "${RED}${BOLD}ERROR this VM can't reach internet the script can't be lauch${NORMAL}"
else
#Début du script, demande d'informations :
if [ $(id -u) -eq 0 ]; then
echo "${GREEN}${BOLD}Le script v${NORMAL}"
else
        echo -e "${RED}${BOLD}Only root may add a user to the system.${NORMAL}"
        exit 2
fi

#Récupération de l'@ ip
IP=$(hostname -I)
haproxysupervision=${IP:0:14}/haproxy?stats

#Installatin de docker : 
apt update
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

var1=$( cat /etc/issue )
if [[ $var1 == *"Debian"* ]];
then
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
echo $var1
else
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
fi
apt update
apt install docker-ce -y


#Installation Docker Compose : 
curl -L https://github.com/docker/compose/releases/download/1.25.3/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


#Mise en place des fichiers :
mkdir /opt/docker2 -m777 -v
touch /opt/docker2/docker-compose.yml
mkdir -p /opt/docker2/nginx/{nginx1,nginx2,nginx3,nginx4} /opt/docker2/haproxy -m777 -v
touch /opt/docker2/nginx/nginx1/index.html && touch /opt/docker2/nginx/nginx2/index.html && touch /opt/docker2/nginx/nginx3/index.html && touch /opt/docker2/nginx/nginx4/index.html && touch /opt/docker2/haproxy/haproxy.cfg
chown $USER:$USER -R /opt/docker2/

#Mise en place du docker-compose :
cat << EOF |sudo tee -a /opt/docker2/docker-compose.yml
version: "2.1"
services:

####
#Nginx
####
  webserver1:
    image: nginx:alpine
    container_name: nginx1
    restart: always
    tty: true
    ports:
      - "8081:80"
    volumes:
      - ./nginx/nginx1:/usr/share/nginx/html

  webserver2:
    image: nginx:alpine
    container_name: nginx2
    restart: always
    tty: true
    ports:
      - "8082:80"
    volumes:
      - ./nginx/nginx2:/usr/share/nginx/html

  webserver3:
    image: nginx:alpine
    container_name: nginx3
    restart: always
    tty: true
    ports:
      - "8083:80"
    volumes:
      - ./nginx/nginx3:/usr/share/nginx/html

  webserver4:
    image: nginx:alpine
    container_name: nginx4
    restart: always
    tty: true
    ports:
      - "8084:80"
    volumes:
      - ./nginx/nginx4:/usr/share/nginx/html


####
#Haproxy
####
  haproxy:
    image: haproxy
    container_name: haproxy
    restart: always
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - ./haproxy:/usr/local/etc/haproxy/haproxy.cfg
EOF




#Paramétrage fichier de conf :
truncate -s 0 /opt/docker2/nginx/nginx1/index.html
cat << EOF |sudo tee -a /opt/docker2/nginx/nginx1/index.html
je suis le nginx1
EOF


truncate -s 0 /opt/docker2/nginx/nginx2/index.html
cat << EOF |sudo tee -a /opt/docker2/nginx/nginx2/index.html
je suis le nginx2
EOF

truncate -s 0 /opt/docker2/nginx/nginx3/index.html
cat << EOF |sudo tee -a /opt/docker2/nginx/nginx3/index.html
je suis le nginx3
EOF

truncate -s 0 /opt/docker2/nginx/nginx4/index.html
cat << EOF |sudo tee -a /opt/docker2/nginx/nginx4/index.html
je suis le nginx4
EOF

truncate -s 0 /opt/docker2/haproxy/haproxy.cfg
cat << EOF |sudo tee -a /opt/docker2/haproxy/haproxy.cfg
global
        # log /dev/log    local0
        # log /dev/log    local1 notice
        # chroot /var/lib/haproxy
        # stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats timeout 30s
        user haproxy
        group haproxy
        daemon

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        option forwardfor
        option http-server-close
        stats enable
        stats hide-version
        stats refresh 30s
        stats show-node
        stats auth administrateur:passroot
        stats uri  /haproxy?stats


###
# FRONTEND HTTP
###
frontend ft_http
        mode http
        bind *:80
        # reqadd X-Forwarded-Proto:\ http

        acl host_nginx hdr(host) -i ${IP:0:14}
        use_backend bk_nginx if host_nginx




###
# BACKEND
###

backend bk_nginx
        mode http
        balance roundrobin
        server nginx1 nginx1:80 check
        server nginx2 nginx2:80 check
        server nginx3 nginx3:80 check
        server nginx4 nginx4:80 check
EOF



#Lancement du docker-compose
docker-compose -f /opt/docker2/docker-compose.yml up -d


echo ""
echo ""
echo -e "${GREEN}${BOLD}Le script s'est terminé.${NORMAL}"
echo ""
echo -e "${GREEN}${BOLD}Vous pouvez accéder à l'URL http://"${IP:0:14}" pour se connecter aux serveurs WEB et http://"${haproxysupervision// /}" pour l'interface Haproxy (user : administration / mot de passe : passroot${NORMAL}"
echo ""
fi
