#!/bin/bash

chmod +x traefik/install.sh

pushd traefik
./install.sh
popd

domaineTraefik=""
loginTraefik=""
passTraefik=""
domainePortainer=""

if [ -z "$1" ]
then
      read -p "Indicate your domain for monitor traefik: " domaineTraefik
      read -p "Indicate login for monitor traefik: " loginTraefik
      read -p "Indicate password for monitor traefik: " passTraefik
      read -p "Indicate your domain for portainer: " domainePortainer
else
      domaineTraefik=$1
      loginTraefik=$2
      passTraefik=$3
      domainePortainer=$4
      echo 'all domain  are ok'
fi

sed -i 's/xxx.xxx/'$domaineTraefik'/g' traefik/conf/traefik_dynamic.toml

htpasswd -b -c ./password $loginTraefik $passTraefik

chmod +x replaceInFile.sh
EncryptedPassword=$( cat ./password)
echo $EncryptedPassword

#./replaceInFile.sh traefik/conf/traefik_dynamic.toml login:passcrypt $EncryptedPassword 
sed -i '/admin/c\"'$EncryptedPassword'"' traefik/conf/traefik_dynamic.toml

rm ./password

sed -i '/URL_PORTAINER/c\URL_PORTAINER = '$domainePortainer'' portainer/.env
mkdir -p portainer/data

docker-compose -f traefik/docker-compose.yml --env-file traefik/.env up -d
docker-compose -f portainer/docker-compose.yml --env-file portainer/.env up -d
