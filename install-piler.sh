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
etcPth="/var/lib/docker/volumes/piler-docker_piler_etc/_data"

# Load config
. ./piler.conf

if [ ! -f $installPth/.env ]; then
    ln -s ./piler.conf .env
fi

if [ -f $installPth/docker-compose.yml ]; then
    rm $installPth/docker-compose.yml
fi

if [ "$USE_LETSENCRYPT" = "yes" ]; then
    cp $configPth/piler-ssl.yml $installPth/docker-compose.yml
else
    cp $configPth/piler-default.yml $installPth/docker-compose.yml
fi

while true; do
    read -ep "Postfix must be uninstalled prior to installation. Do you want to uninstall Postfix now? (y/n): " yn
    case $yn in
        [Yy]* ) apt purge postfix -y; break;;
        [Nn]* ) echo -e "${redBold}    The installation process is aborted because Postfix has not been uninstalled.!! ${normal}"; exit;;
        * ) echo -e "${red} Please confirm with y or n.";;
    esac
done

# old docker stop
cd $installPth
docker-compose down

# docker start
echo
echo "${greenBold}${HLINE}"
echo "${greenBold}                 start docker-compose for Piler"
echo "${greenBold}${HLINE}${normal}"
echo

cd $installPth

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

docker-compose up -d

echo "${blue}********* Piler started... Please wait... *********"

BLA::start_loading_animation "${BLA_metro[@]}"
sleep 20
BLA::stop_loading_animation

echo
echo "${blue}${HLINE}"
echo "${blue}             backup the File config-site.php"
echo "${blue}${HLINE}${normal}"
echo

if [ ! -f $etcPth/config-site.php.bak ]; then
    cp $etcPth/config-site.php $etcPth/config-site.php.bak
else
    rm $etcPth/config-site.php
    cp $etcPth/config-site.php.bak $etcPth/config-site.php
fi

echo
echo "${blue}${HLINE}"
echo "${blue}                       set User settings ..."
echo "${blue}${HLINE}${normal}"
echo

cat >> $etcPth/config-site.php <<EOF

// Smarthost
\$config['SMARTHOST'] = '$SMARTHOST';
\$config['SMARTHOST_PORT'] = '25';

// CUSTOM
\$config['PROVIDED_BY'] = '$PILER_DOMAIN';
\$config['SUPPORT_LINK'] = 'mailto:$SUPPORT_MAIL';
\$config['COMPATIBILITY'] = '';

// fancy features.
\$config['ENABLE_INSTANT_SEARCH'] = 1;
\$config['ENABLE_TABLE_RESIZE'] = 1;

\$config['ENABLE_DELETE'] = 1;
\$config['ENABLE_ON_THE_FLY_VERIFICATION'] = 1;

// general settings.
\$config['TIMEZONE'] = '$TIME_ZONE';

// authentication
// Enable authentication against an imap server
\$config['ENABLE_IMAP_AUTH'] = 1;
\$config['RESTORE_OVER_IMAP'] = 1;
\$config['IMAP_RESTORE_FOLDER_INBOX'] = 'INBOX';
\$config['IMAP_RESTORE_FOLDER_SENT'] = 'Sent';
\$config['IMAP_HOST'] = '$IMAP_SERVER';
\$config['IMAP_PORT'] =  993;
\$config['IMAP_SSL'] = true;

// authentication against an ldap directory (disabled by default)
//\$config['ENABLE_LDAP_AUTH'] = 1;
//\$config['LDAP_HOST'] = '$SMARTHOST';
//\$config['LDAP_PORT'] = 389;
//\$config['LDAP_HELPER_DN'] = 'cn=administrator,cn=users,dc=mydomain,dc=local';
//\$config['LDAP_HELPER_PASSWORD'] = 'myxxxxpasswd';
//\$config['LDAP_MAIL_ATTR'] = 'mail';
//\$config['LDAP_AUDITOR_MEMBER_DN'] = '';
//\$config['LDAP_ADMIN_MEMBER_DN'] = '';
//\$config['LDAP_BASE_DN'] = 'ou=Benutzer,dc=krs,dc=local';

// authentication against an Uninvention based ldap directory 
//\$config['ENABLE_LDAP_AUTH'] = 1;
//\$config['LDAP_HOST'] = '$SMARTHOST';
//\$config['LDAP_PORT'] = 7389;
//\$config['LDAP_HELPER_DN'] = 'uid=ldap-search-user,cn=users,dc=mydomain,dc=local';
//\$config['LDAP_HELPER_PASSWORD'] = 'myxxxxpasswd';
//\$config['LDAP_AUDITOR_MEMBER_DN'] = '';
//\$config['LDAP_ADMIN_MEMBER_DN'] = '';
//\$config['LDAP_BASE_DN'] = 'cn=users,dc=mydomain,dc=local';
//\$config['LDAP_MAIL_ATTR'] = 'mailPrimaryAddress';
//\$config['LDAP_ACCOUNT_OBJECTCLASS'] = 'person';
//\$config['LDAP_DISTRIBUTIONLIST_OBJECTCLASS'] = 'person';
//\$config['LDAP_DISTRIBUTIONLIST_ATTR'] = 'mailAlternativeAddress';

// special settings.
//\$config['MEMCACHED_ENABLED'] = 1;
\$config['SPHINX_STRICT_SCHEMA'] = 1; // required for Sphinx see https://bitbucket.org/jsuto/piler/issues/1085/sphinx-331.
EOF

if [ "$USE_MAILCOW" = true ]; then

echo
echo "${blue}${HLINE}"
echo "set Mailcow Api-Key config"
echo "${blue}${HLINE}${normal}"
echo

cat >> $etcPth/config-site.php <<EOF

// Mailcow API
\$config['MAILCOW_API_KEY'] = '$MAILCOW_APIKEY';
\$config['MAILCOW_SET_REALNAME'] = true;
\$config['CUSTOM_EMAIL_QUERY_FUNCTION'] = 'query_mailcow_for_email_access';
\$config['MAILCOW_HOST'] = '$MAILCOW_HOST'; // default $config['IMAP_HOST']
include('auth-mailcow.php');
EOF

curl -o $etcPth/auth-mailcow.php https://raw.githubusercontent.com/patschi/mailpiler-mailcow-integration/master/auth-mailcow.php
fi

# add config settings

if [ ! -f $etcPth/piler.conf.bak ]; then
    cp $etcPth/piler.conf $etcPth/piler.conf.bak
else
    rm $etcPth/piler.conf
    cp $etcPth/piler.conf.bak $etcPth/piler.conf
fi

sed -i "s/default_retention_days=.*/default_retention_days=$DEFAULT_RETENTION_DAYS/" $etcPth/piler.conf
sed -i "s/update_counters_to_memcached=.*/update_counters_to_memcached=1/" $etcPth/piler.conf

cat >> $etcPth/piler.conf <<EOF
queuedir=/var/piler/store
EOF

# piler restart
echo
echo "${blue}${HLINE}"
echo "${blue}                  restart piler ..."
echo "${blue}${HLINE}${normal}"
echo

cd $installPth
docker-compose restart piler

echo
echo "${greenBold}${HLINE}"
echo "${greenBold}             Piler install completed successfully"
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
