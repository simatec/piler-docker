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

echo
echo "${greenBold}${HLINE_SMALL}"
echo "Check if patches are available"
echo "${greenBold}${HLINE_SMALL}${normal}"
echo

#######################################################################################

# config load
. ./piler.conf

# Check Version
compare_versions() {
    local version1=$1
    local version2=$2
    local ver1=$(echo "$version1" | awk -F. '{ printf("%03d%03d%03d", $1, $2, $3); }')
    local ver2=$(echo "$version2" | awk -F. '{ printf("%03d%03d%03d", $1, $2, $3); }')

    if [[ "$ver1" -ge "$ver2" ]]; then
        return 0
    else
        return 1
    fi
}

##################### Patch for Update to Piler v1.4.5 or higher ######################
# Check the manticore.conf to see if the entry "listen = 127.0.0.1:9307:mysql_readonly" is present.
# If the entry does not exist, set the entry in the manticore.conf

required_version="1.4.5"

if compare_versions "$PILER_VERSION" "$required_version"; then
    file="/var/lib/docker/volumes/piler-docker_piler_etc/_data/manticore.conf"
    patchNum="pilerPatch001"

    search_entry="127.0.0.1:9307:"
    new_entry="${entry}\tlisten\t\t\t= 127.0.0.1:9307:mysql_readonly"

    if [ -f $file ]; then
    #  Check the manticore.conf to see if the entry "listen = 127.0.0.1:9307:mysql_readonly" is present
        if ! grep -qF "$search_entry" "$file"; then
            # If the entry does not exist, set the entry in the manticore.conf
            sed -i "/listen/!b; :a; {n; /listen/!ba}; a $new_entry" "$file"
            sed -i "s/\<$patchNum\>//g" "$file"

            if grep -q '\btlisten\b' "$file"; then
              sed -i 's/\btlisten\b/listen/g' "$file"
            fi

            echo "Patch manticore.conf with new entry: listen = 127.0.0.1:9307:mysql_readonly"
        else
            echo "Patch already executed. No action required"
        fi
    else
        echo "The file manticore.conf does not exist. The patch cannot be executed"
    fi
fi
#######################################################################################

exit 0