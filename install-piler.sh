#!/bin/bash

. ./piler.conf
ln -s ./piler.conf .env

# docker start
echo
echo "==================================="
echo "start docker-compose for Piler"
echo "==================================="
echo

cd /opt/piler-docker
docker-compose up -d

echo
echo "==================================="
echo "backup the File config-site.php"
echo "==================================="
echo

if [ ! -f /var/lib/docker/volumes/piler-docker_piler_etc/_data/config-site.php.bak ]; then
    cp /var/lib/docker/volumes/piler-docker_piler_etc/_data/config-site.php /var/lib/docker/volumes/piler-docker_piler_etc/_data/config-site.php.bak
else
    rm /var/lib/docker/volumes/piler-docker_piler_etc/_data/config-site.php
    cp /var/lib/docker/volumes/piler-docker_piler_etc/_data/config-site.php.bak /var/lib/docker/volumes/piler-docker_piler_etc/_data/config-site.php
fi

echo
echo "==================================="
echo "set User settings ..."
echo "==================================="
echo
cat >> /var/lib/docker/volumes/piler-docker_piler_etc/_data/config-site.php <<EOF

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
EOF

if [ "$USE_MAILCOW" = true ] ; then

echo
echo "==================================="
echo "set Mailcow Api-Key config"
echo "==================================="
echo

cat >> /var/lib/docker/volumes/piler-docker_piler_etc/_data/config-site.php <<EOF

// Mailcow API
\$config['MAILCOW_API_KEY'] = '$MAILCOW_APIKEY';
\$config['MAILCOW_SET_REALNAME'] = true;
\$config['CUSTOM_EMAIL_QUERY_FUNCTION'] = 'query_mailcow_for_email_access';
\$config['MAILCOW_HOST'] = '$MAILCOW_HOST'; // default $config['IMAP_HOST']
include('auth-mailcow.php');
EOF

curl -o /var/lib/docker/volumes/piler-docker_piler_etc/_data/auth-mailcow.php https://raw.githubusercontent.com/patschi/mailpiler-mailcow-integration/master/auth-mailcow.php
fi

# docker restart
echo
echo "==================================="
echo "restart docker-compose ..."
echo "==================================="
echo

cd /opt/piler-docker
docker-compose restart

echo
echo "======================================================================="
echo "Piler install completed successfully"
echo
echo "you can start in your Browser with http://${PILER_DOMAIN}:8080!"
echo "======================================================================="
echo
