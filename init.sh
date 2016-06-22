#!/usr/bin/env bash
#
#   DEFAULTS VAR
#
domain='api.everyc4you.dev'
projectname="${PWD##*/}"''
database='everyc4you'


projectpath="/home/vagrant/Code/${projectname}"


#
#   COLORS
#
RED='\033[0;31m'
BLUE='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
GRAY='\033[0;90m'



#
#   INPUTS WITH DEFAULT VARS
#
printf "Quelle est votre URL de dev ? ${GRAY}[$domain]${NC}\n"
read input_domain
printf "Quelle est votre chemin de projet ? ${GRAY}[$projectpath]${NC}\n"
read input_projectpath
printf "Quelle est votre base de donnée ? ${GRAY}[$database]${NC}\n"
read input_database


if [ "$input_domain" != "" ]; then
    domain=$input_domain
fi

if [ "$input_projectpath" != "" ]; then
    projectpath=$input_projectpath
fi

if [ "$input_database" != "" ]; then
    database=$input_database
fi


vhost="\n    - map: ${domain}\n      to: ${projectpath}/public"


while true; do
    printf "Domaine : ${BLUE}$domain${NC}\n"
    printf "Chemin projet :  ${BLUE}$projectpath${NC}\n"
    printf "Database :  ${BLUE}$database${NC}\n"
    read -p "Est-ce bon ? (y/n)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) printf "${RED}Réponse invalide${NC} (y/n)\n";;
    esac
done


#
#   PROJECT INSTALL
#

cp .env.dev .env


cd ~/.homestead
cp Homestead.yaml Homestead.yaml.bak

if grep -q "$domain" ~/.homestead/Homestead.yaml
then
	printf "${RED}ERROR${NC} - ${BLUE}$domain${NC} already in Homestead.yaml\n"
else
	awk -v vhost="${vhost}" '{if ($1 ~ /^sites:/) print $0, vhost; else print $0}' Homestead.yaml > Homestead_new.yaml
	cp Homestead_new.yaml Homestead.yaml
	printf "${GREEN}SUCCESS${NC} - Added ${BLUE}$domain${NC} to Homestead.yaml\n"
fi

if grep -q "\- $database" ~/.homestead/Homestead.yaml
then
	printf "${RED}ERROR${NC} - Database ${BLUE}$database${NC} already in Homestead.yaml\n"
else
	cp Homestead.yaml Homestead.yaml.bak
	awk -v database="\n    - ${database}" '{if ($1 ~ /^databases:/) print $0, database; else print $0}' Homestead.yaml > Homestead_new.yaml
	cp Homestead_new.yaml Homestead.yaml
	printf "${GREEN}SUCCESS${NC} - Added database ${BLUE}$database${NC} to Homestead.yaml\n"
fi


if grep -q "$domain" /etc/hosts
then 
	printf "${RED}ERROR${NC} - ${BLUE}$domain${NC} already in hosts\n"
else
	sudo bash -c "echo '192.168.10.10 $domain' >> /etc/hosts"
	printf "${GREEN}SUCCESS${NC} - Added ${BLUE}$domain${NC} to hosts\n"
fi

cd ~/Sites/Homestead/
vagrant provision




ssh vagrant@192.168.10.10 << EOF
    cd ${projectpath}
    composer install
    php artisan migrate:reset
    php artisan migrate --seed
EOF



