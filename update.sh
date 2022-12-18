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
	puple=`echo -e "\e[1m\e[35m"`
	bold=`echo -e "\e[1m"`
  	normal=`echo -en "\e[0m"`
fi

HLINE="=================================================================="

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

installPth="/opt/piler-docker"
configPth="/opt/piler-docker/config"

# config load
. ./piler.conf

if [ ! -f $installPth/.env ]; then
    ln -s ./piler.conf .env
fi

if [ -f $installPth/docker-compose.yml ]; then
    rm $installPth/docker-compose.yml
fi

# Download yml update
echo
echo "${greenBold}${HLINE}"
echo "${greenBold}                 Download Update files for Piler"
echo "${greenBold}${HLINE}${normal}"
echo

cd $configPth

# Update yml
curl -OL https://raw.githubusercontent.com/simatec/piler-docker/main/config/piler-default.yml
curl -OL https://raw.githubusercontent.com/simatec/piler-docker/main/config/piler-ssl.yml

# old docker stop
cd $installPth

docker-compose down

if [ "$USE_LETSENCRYPT" = "yes" ]; then
    cp $configPth/piler-ssl.yml $installPth/docker-compose.yml
else
    cp $configPth/piler-default.yml $installPth/docker-compose.yml
fi

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

docker-compose up --force-recreate --build -d

echo "${blue}********* Piler started... Please wait... *********"

BLA::start_loading_animation "${BLA_metro[@]}"
sleep 10
BLA::stop_loading_animation

echo
echo "${greenBold}${HLINE}"
echo "${greenBold}             Piler Update completed successfully"
echo "${greenBold}${HLINE}${normal}"
echo
echo
echo "${greenBold}${HLINE}"
if [ "$USE_LETSENCRYPT" = "yes" ]; then
    echo "${greenBold}you can start in your Browser with https://${PILER_DOMAIN}!"
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