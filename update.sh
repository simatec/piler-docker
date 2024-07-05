#!/bin/bash

# Colors
if [ -z ${BASH_SOURCE} ]; then
  blue=`echo "\e[1m\e[34m"`
  green=`echo "\e[1m\e[32m"`
  greenBold=`echo "\e[1m\e[1;32m"`
  redBold=`echo "\e[1m\e[1;31m"`
  red=`echo "\e[1m\e[31m"`
  purple=`echo "\e[1m\e[35m"`
  bold=`echo "\e[1m"`
  normal=`echo "\e[0m"`
else
  blue=`echo -e "\e[1m\e[34m"`
  green=`echo -e "\e[1m\e[32m"`
  greenBold=`echo -e "\e[1m\e[1;32m"`
  redBold=`echo -e "\e[1m\e[1;31m"`
  purple=`echo -e "\e[1m\e[35m"`
  bold=`echo -e "\e[1m"`
  normal=`echo -en "\e[0m"`
fi

HLINE="================================================================"
HLINE_SMALL="================================="

BLA_metro=( 0.2 '    ' '=   ' '==  ' '=== ' ' ===' '  ==' '   =' )

BLA::play_loading_animation_loop() {
  while true ; do
    for frame in "${BLA_active_loading_animation[@]}" ; do
      printf "\r%s" "${frame}"
      sleep "${BLA_loading_animation_frame_interval}"
    done
  done
}

BLA::start_loading_animation() {
  BLA_active_loading_animation=( "${@}" )
  BLA_loading_animation_frame_interval="${BLA_active_loading_animation[0]}"
  unset "BLA_active_loading_animation[0]"
  tput civis # Hide the terminal cursor
  BLA::play_loading_animation_loop &
  BLA_loading_animation_pid="${!}"
}

BLA::stop_loading_animation() {
  kill "${BLA_loading_animation_pid}" &> /dev/null
  printf "\n"
  tput cnorm # Restore the terminal cursor
}

#######################################################################################
function finish_info {
  echo
  echo "${greenBold}${HLINE}"
  echo "${greenBold}             Piler Update completed successfully"
  echo "${greenBold}${HLINE}${normal}"
  echo
  echo
  echo "${greenBold}${HLINE}"

  if [ "$USE_LETSENCRYPT" = "yes" ]; then
    echo "${greenBold}you can start in your Browser with:"
    echo "${greenBold}https://${PILER_DOMAIN}"
  else
    echo "${greenBold}you can start in your Browser with:"
    echo "${greenBold}http://${PILER_DOMAIN} or http://local-ip"
  fi

  echo "${greenBold}${HLINE}${normal}"

  echo
  echo "${blue}${HLINE}"
  echo "${blue}You can remove the old unused containers on your system!"
  echo "${blue}Execute the following command: docker system prune"
  echo "${blue}${HLINE}${normal}"
  echo
  exit 0
}

function header_info {
clear

echo "${greenBold}"
cat <<"EOF"
        _ _             _   _           _       _
  _ __ (_) | ___ _ __  | | | |_ __   __| | __ _| |_ ___
 | '_ \| | |/ _ \ '__| | | | | '_ \ / _` |/ _` | __/ _ \
 | |_) | | |  __/ |    | |_| | |_) | (_| | (_| | ||  __/
 | .__/|_|_|\___|_|     \___/| .__/ \__,_|\__,_|\__\___|
 |_|                         |_|

EOF
echo "${normal}"
}
header_info

#######################################################################################

# App Check
for bin in curl docker git; do
  if [[ -z $(which ${bin}) ]]; then echo "${redBold}Cannot find ${bin}, exiting...${normal}"; exit 1; fi
done

# Docker-Compose Check
if docker compose > /dev/null 2>&1; then
    if docker compose version --short | grep "^2." > /dev/null 2>&1; then
      COMPOSE_VERSION=native
      echo -e "${purple}Found Docker Compose Plugin (native).${normal}"
      echo -e "${purple}Setting the DOCKER_COMPOSE_VERSION Variable to native${normal}"
      sleep 2
      echo -e "${purple}Notice: You´ll have to update this Compose Version via your Package Manager manually!${normal}"
    else
      echo -e "${redBold}Cannot find Docker Compose with a Version Higher than 2.X.X.${normal}"
      exit 1
    fi
elif docker-compose > /dev/null 2>&1; then
  if ! [[ $(alias docker-compose 2> /dev/null) ]] ; then
    if docker-compose version --short | grep "^2." > /dev/null 2>&1; then
      COMPOSE_VERSION=standalone
      echo -e "${purple}Found Docker Compose Standalone.${normal}"
      echo -e "${purple}Setting the DOCKER_COMPOSE_VERSION Variable to standalone${normal}"
      sleep 2
    else
      echo -e "${redBold}Cannot find Docker Compose with a Version Higher than 2.X.X.${normal}"
      exit 1
    fi
  fi

else
  echo -e "${redBold}Cannot find Docker Compose.${normal}"
  exit 1
fi

#######################################################################################

while true; do
    read -ep "Do you want to perform the update?? (y/n): " yn
    case $yn in
        [Yy]* ) echo "${greenBold}********* Update started... Please wait... *********${normal}"; break;;
        [Nn]* ) echo -e "${redBold}    The update is canceled!${normal}"; exit;;
        * ) echo -e "${redBold} Please confirm with y or n.${normal}";;
    esac
done

installPth=`pwd`
configPth="$installPth/config"
etcPth="/var/lib/docker/volumes/piler-docker_piler_etc/_data"
buildPth="$installPth/build"

if [ -f $installPth/docker-compose.yml ]; then
  rm $installPth/docker-compose.yml
fi

# Download yml update
echo
echo "${greenBold}${HLINE}"
echo "${greenBold}                 Download Update files for Piler"
echo "${greenBold}${HLINE}${normal}"
echo

# Update Files
for ymlUpdate in piler-default.yml piler-ssl.yml; do
  echo
  echo "${purple}${HLINE}${HLINE_SMALL}"
  echo "${purple}****** Download Update $ymlUpdate ******"
  #curl -o $configPth/$ymlUpdate https://raw.githubusercontent.com/simatec/piler-docker/main/config/$ymlUpdate
  wget https://raw.githubusercontent.com/simatec/piler-docker/main/config/$ymlUpdate -O $configPth/$ymlUpdate
  echo "${purple}${HLINE}${HLINE_SMALL}${normal}"
  echo
done

for fileUpdate in install-piler.sh LICENSE piler.conf.example patch.sh; do
  echo
  echo "${purple}${HLINE}${HLINE_SMALL}"
  echo "${purple}****** Download Update $fileUpdate ******"
  #curl -o $installPth/$fileUpdate https://raw.githubusercontent.com/simatec/piler-docker/main/$fileUpdate
  wget https://raw.githubusercontent.com/simatec/piler-docker/main/$fileUpdate -O $installPth/$fileUpdate
  echo "${purple}${HLINE}${HLINE_SMALL}${normal}"
  echo
done

for buildUpdate in start.sh build.sh Dockerfile build.conf; do
  echo
  echo "${purple}${HLINE}${HLINE_SMALL}"
  echo "${purple}****** Download Update $buildUpdate ******"
  #curl -o $buildPth/$buildUpdate https://raw.githubusercontent.com/simatec/piler-docker/main/build/$buildUpdate
  wget https://raw.githubusercontent.com/simatec/piler-docker/main/build/$buildUpdate -O $buildPth/$buildUpdate
  echo "${purple}${HLINE}${HLINE_SMALL}${normal}"
  echo
done

# build config load
. $buildPth/build.conf

# set Piler Version
sed -i 's/PILER_VERSION=.*/PILER_VERSION="'$PILER_VERSION'"/g' ./piler.conf

# set Maria-DB Version
sed -i 's/MARIA_DB_VERSION=.*/MARIA_DB_VERSION="'$MARIA_DB_VERSION'"/g' ./piler.conf

# config load
. ./piler.conf

if [ ! -f $installPth/.env ]; then
  ln -s ./piler.conf .env
fi

# old docker stop
cd $installPth

if [ $COMPOSE_VERSION = native ]; then
  docker compose down
else
  docker-compose down
fi

# create Network
if docker network inspect pilernet > /dev/null 2>&1; then
    echo "Network pilernet is available"
else
    docker network create pilernet
    echo "Network pilernet created"
fi

# Backup Config
if [ ! -d $installPth/backup ]; then
  mkdir -p $installPth/backup
fi

cp -rf $etcPth/* $installPth/backup/

# Added Manticore
if [ ! -f $etcPth/MANTICORE ]; then
  touch $etcPth/MANTICORE
fi

# Copy docker-compose.yml
if [ "$USE_LETSENCRYPT" = "yes" ]; then
  cp $configPth/piler-ssl.yml $installPth/docker-compose.yml
else
  cp $configPth/piler-default.yml $installPth/docker-compose.yml
fi
# Check for Patches before Update
bash $installPth/patch.sh
BLA::start_loading_animation "${BLA_metro[@]}"
sleep 5
BLA::stop_loading_animation

# start Update Container
echo
echo "${greenBold}${HLINE}"
echo "${greenBold}                 Update Container for Piler"
echo "${greenBold}${HLINE}${normal}"
echo

if [ "$USE_LETSENCRYPT" = "yes" ]; then
    if ! docker network ls | grep -o "nginx-proxy"; then
      docker network create nginx-proxy

      echo
      echo "${blue}${HLINE}"
      echo "${blue}                       docker network created"
      echo "${blue}${HLINE}${normal}"
      echo
    fi
fi

if [ $COMPOSE_VERSION = native ]; then
  docker compose up --force-recreate --build -d
else
  docker-compose up --force-recreate --build -d
fi

echo
echo "${greenBold}${HLINE}"
echo "${greenBold}                 Reindex Piler"
echo "${greenBold}${HLINE}${normal}"
echo

while true; do
    read -ep "Do you want to perform the Reindex?? (y/n): " yn
    case $yn in
        [Yy]* ) echo "${greenBold}********* Reindex started... Please wait... *********${normal}"; break;;
        [Nn]* ) echo -e "${redBold}    Update without Reindex!${normal}"; finish_info;;
        * ) echo -e "${redBold} Please confirm with y or n.${normal}";;
    esac
done

BLA::start_loading_animation "${BLA_metro[@]}"
sleep 15
docker exec -u piler -w /var/tmp piler reindex -a
BLA::stop_loading_animation
finish_info
