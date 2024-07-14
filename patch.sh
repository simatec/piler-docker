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
    new_entry="${patchNum}\tlisten\t\t\t= 127.0.0.1:9307:mysql_readonly"

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

################################ Patch config-site-php ################################
configSite="/var/lib/docker/volumes/piler-docker_piler_etc/_data/config-site.php"
etcPth="/var/lib/docker/volumes/piler-docker_piler_etc/_data"

if ! grep -qF "### Begin added by Piler-Installer ###" "$configSite"; then
cat >> $configSite <<EOF

// ### Begin added by Piler-Installer ###
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
// ### end added by Piler-Installer ###
EOF

echo "Patch config-site.php with your Settings"
fi


if [ "$USE_IMAPAUTH" = true ]; then
cat >> $configSite <<EOF

// authentication
// Enable authentication against an imap server
\$config['ENABLE_IMAP_AUTH'] = 1;
\$config['RESTORE_OVER_IMAP'] = 1;
\$config['IMAP_RESTORE_FOLDER_INBOX'] = 'INBOX';
\$config['IMAP_RESTORE_FOLDER_SENT'] = 'Sent';
\$config['IMAP_HOST'] = '$IMAP_SERVER';
\$config['IMAP_PORT'] =  993;
\$config['IMAP_SSL'] = true;
EOF
fi


if [ "$USE_MAILCOW" = true ]; then

if ! grep -qF "// Mailcow API" "$configSite"; then
cat >> $configSite <<EOF

// ### Begin added by Piler-Installer ###
// Mailcow API
\$config['MAILCOW_API_KEY'] = '$MAILCOW_APIKEY';
\$config['MAILCOW_SET_REALNAME'] = true;
\$config['CUSTOM_EMAIL_QUERY_FUNCTION'] = 'query_mailcow_for_email_access';
\$config['MAILCOW_HOST'] = '$MAILCOW_HOST'; // default $config['IMAP_HOST']
include('auth-mailcow.php');
// ### end added by Piler-Installer ###
EOF
fi

wget https://raw.githubusercontent.com/patschi/mailpiler-mailcow-integration/master/auth-mailcow.php -O $etcPth/auth-mailcow.php
fi

echo "Patch Mailcow Api-Key config"

#######################################################################################


exit 0