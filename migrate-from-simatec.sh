#!/bin/bash

# Migration of an existing simatec/piler-docker installation (Piler 1.4.8)
# to DSTech-IT/mailpiler-with-docker.
#
# The script
#   1. checks the existing installation,
#   2. creates a backup (database dump, install directory, docker volumes)
#      and writes a restore.sh for a rollback,
#   3. switches the update source to DSTech-IT/mailpiler-with-docker,
#   4. runs the regular update (update.sh),
#   5. checks the result.
#
# Usage (as root):
#   cd /opt/piler-docker
#   wget -O migrate-from-simatec.sh https://raw.githubusercontent.com/DSTech-IT/mailpiler-with-docker/main/migrate-from-simatec.sh
#   bash migrate-from-simatec.sh
#
# Optional environment variables:
#   INSTALL_DIR   install directory            (default: current directory)
#   BACKUP_DIR    backup directory             (default: /root/piler-backup-<date>)
#   BACKUP_STORE  "yes" also backs up the mail store volume (can be very large)
#   REPO_RAW_URL  update source                (default: DSTech-IT/mailpiler-with-docker main)

# Colors
blue=`echo -e "\e[1m\e[34m"`
greenBold=`echo -e "\e[1m\e[1;32m"`
redBold=`echo -e "\e[1m\e[1;31m"`
purple=`echo -e "\e[1m\e[35m"`
normal=`echo -en "\e[0m"`

# Update Source
REPO_RAW_URL="${REPO_RAW_URL:-https://raw.githubusercontent.com/DSTech-IT/mailpiler-with-docker/main}"
export REPO_RAW_URL

HLINE="================================================================"

PROJECT="piler-docker"
VOLUME_ROOT="/var/lib/docker/volumes"
BACKUP_VOLUMES="db_data piler_etc piler_cron piler_manticore piler_var_manticore piler_var_imap piler_var_stat"

set -o pipefail

#######################################################################################

die() {
  echo
  echo "${redBold}${HLINE}"
  echo "${redBold}ERROR: $*"
  echo "${redBold}${HLINE}${normal}"
  echo
  exit 1
}

step() {
  echo
  echo "${greenBold}${HLINE}"
  echo "${greenBold}  $*"
  echo "${greenBold}${HLINE}${normal}"
  echo
}

info() {
  echo "${purple}$*${normal}"
}

ask_yn() {
  local answer
  while true; do
    read -ep "$1 (y/n): " answer
    case $answer in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "${redBold}Please confirm with y or n.${normal}";;
    esac
  done
}

compose() {
  if [ "$COMPOSE_VERSION" = native ]; then
    docker compose "$@"
  else
    docker-compose "$@"
  fi
}

#######################################################################################

step "Piler migration: simatec/piler-docker -> DSTech-IT/mailpiler-with-docker"

# Checks
[ "$(id -u)" -eq 0 ] || die "Please run this script as root."

for bin in curl docker git wget tar; do
  command -v ${bin} > /dev/null 2>&1 || die "Cannot find ${bin}."
done

if docker compose version > /dev/null 2>&1 \
  && [ "$(docker compose version --short 2>/dev/null | sed 's/^v//' | cut -d. -f1)" -ge 2 ] 2>/dev/null; then
  COMPOSE_VERSION=native
elif docker-compose version > /dev/null 2>&1 \
  && [ "$(docker-compose version --short 2>/dev/null | sed 's/^v//' | cut -d. -f1)" -ge 2 ] 2>/dev/null; then
  COMPOSE_VERSION=standalone
else
  die "Cannot find Docker Compose with Version 2.X.X or higher."
fi
info "Docker Compose: $(compose version --short 2>/dev/null) ($COMPOSE_VERSION)"

INSTALL_DIR="${INSTALL_DIR:-$(pwd)}"
INSTALL_DIR="$(cd "$INSTALL_DIR" 2>/dev/null && pwd)" || die "Install directory not found."
cd "$INSTALL_DIR" || die "Cannot change to $INSTALL_DIR."

for f in piler.conf .configDone docker-compose.yml install-piler.sh; do
  [ -e "$INSTALL_DIR/$f" ] || die "$INSTALL_DIR/$f not found. Please run the script in the piler-docker install directory (e.g. /opt/piler-docker)."
done

# Load config
. ./piler.conf
OLD_PILER_VERSION="$PILER_VERSION"
OLD_MARIA_DB_VERSION="$MARIA_DB_VERSION"

# Existing volumes must belong to the compose project "piler-docker",
# otherwise the new compose files (fixed project name) would create empty volumes
for v in db_data piler_etc piler_var_store; do
  docker volume inspect "${PROJECT}_${v}" > /dev/null 2>&1 \
    || die "Docker volume ${PROJECT}_${v} not found. The installation does not use the project name '${PROJECT}', migration aborted."
done

if ! grep -q "simatec/piler-docker" "$INSTALL_DIR/install-piler.sh"; then
  info "install-piler.sh does not use simatec/piler-docker as update source."
  info "The installation may already be migrated."
  ask_yn "Continue anyway?" || exit 0
fi

BACKUP_DIR="${BACKUP_DIR:-/root/piler-backup-$(date +%Y%m%d-%H%M%S)}"
case "$BACKUP_DIR/" in
  "$INSTALL_DIR"/*) die "BACKUP_DIR must not be inside $INSTALL_DIR.";;
esac

backupVolumes=""
for v in $BACKUP_VOLUMES; do
  docker volume inspect "${PROJECT}_${v}" > /dev/null 2>&1 && backupVolumes="$backupVolumes ${PROJECT}_${v}"
done
if [ "$BACKUP_STORE" = "yes" ]; then
  backupVolumes="$backupVolumes ${PROJECT}_piler_var_store"
fi

# Space check (uncompressed size as upper bound, db_data counted twice for the dump)
volumePaths="$VOLUME_ROOT/${PROJECT}_db_data"
for v in $backupVolumes; do volumePaths="$volumePaths $VOLUME_ROOT/$v"; done
# shellcheck disable=SC2086
neededBytes=$(du -scb "$INSTALL_DIR" $volumePaths 2>/dev/null | tail -1 | cut -f1)
backupParent="$(dirname "$BACKUP_DIR")"
mkdir -p "$backupParent" || die "Cannot create $backupParent."
freeBytes=$(df --output=avail -B1 "$backupParent" | tail -1 | tr -d ' ')
[ "$neededBytes" -lt "$freeBytes" ] \
  || die "Not enough free space in $backupParent (needed: $((neededBytes / 1024 / 1024)) MB, free: $((freeBytes / 1024 / 1024)) MB). Set BACKUP_DIR to another location."

storeSize=$(du -sh "$VOLUME_ROOT/${PROJECT}_piler_var_store" 2>/dev/null | cut -f1)

echo
echo "${blue}${HLINE}"
echo "${blue}Install directory:   $INSTALL_DIR"
echo "${blue}Current version:     Piler $OLD_PILER_VERSION / MariaDB $OLD_MARIA_DB_VERSION"
echo "${blue}Update source:       $REPO_RAW_URL"
echo "${blue}Backup directory:    $BACKUP_DIR (max. $((neededBytes / 1024 / 1024)) MB)"
echo "${blue}Backup volumes:     $backupVolumes"
if [ "$BACKUP_STORE" != "yes" ]; then
  echo "${blue}Mail store ($storeSize) is not touched by the update and not backed up."
  echo "${blue}Use a VM snapshot or BACKUP_STORE=yes to include it."
fi
echo "${blue}${HLINE}${normal}"
echo
echo "The Piler will be stopped during backup and update (mails are not received)."
echo

ask_yn "Start the migration now?" || { echo "${redBold}Migration canceled.${normal}"; exit 0; }

echo
echo "After the update the search index can be rebuilt (reindex -a)."
echo "This can take a long time for large archives. It can also be run later with:"
echo "  docker exec -u piler -w /var/tmp piler reindex -a"
if ask_yn "Run the reindex after the update?"; then
  REINDEX=y
else
  REINDEX=n
fi

#######################################################################################

step "1/4 Backup to $BACKUP_DIR"

mkdir -p "$BACKUP_DIR" || die "Cannot create $BACKUP_DIR."
chmod 700 "$BACKUP_DIR"

# Database dump
if [ "$(docker inspect -f '{{.State.Running}}' mysql_piler 2>/dev/null)" != "true" ]; then
  info "Starting mysql_piler for the database dump ..."
  compose up -d mysql || die "Cannot start mysql_piler."
  for _ in $(seq 1 30); do
    docker exec mysql_piler sh -c 'mariadb-admin -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" ping' > /dev/null 2>&1 && break
    sleep 2
  done
fi

info "Database dump ..."
docker exec mysql_piler sh -c 'exec mariadb-dump --single-transaction -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' \
  > "$BACKUP_DIR/piler-db.sql" || die "Database dump failed."
[ -s "$BACKUP_DIR/piler-db.sql" ] || die "Database dump is empty."
info "Database dump: $(du -h "$BACKUP_DIR/piler-db.sql" | cut -f1)"

# Stop containers with the old docker-compose.yml
info "Stopping Piler ..."
compose down || die "docker compose down failed."

info "Backup install directory ..."
tar --numeric-owner -czf "$BACKUP_DIR/install-dir.tgz" -C "$(dirname "$INSTALL_DIR")" "$(basename "$INSTALL_DIR")" \
  || die "Backup of $INSTALL_DIR failed."

info "Backup docker volumes ..."
# shellcheck disable=SC2086
tar --numeric-owner -czf "$BACKUP_DIR/volumes.tgz" -C "$VOLUME_ROOT" $backupVolumes \
  || die "Backup of the docker volumes failed."

# Rollback script
cat > "$BACKUP_DIR/restore.sh" <<EOF
#!/bin/bash
# Rollback to the state before the migration (Piler $OLD_PILER_VERSION / MariaDB $OLD_MARIA_DB_VERSION)
# Created by migrate-from-simatec.sh on $(date)

if ! docker image inspect simatec/piler:$OLD_PILER_VERSION > /dev/null 2>&1; then
  echo "Image simatec/piler:$OLD_PILER_VERSION not found, it will be downloaded from Docker Hub."
fi

read -ep "Restore $INSTALL_DIR and the docker volumes from $BACKUP_DIR? (y/n): " yn
case \$yn in
  [Yy]* ) ;;
  * ) echo "Restore canceled."; exit 0;;
esac

cd "$INSTALL_DIR" && $( [ "$COMPOSE_VERSION" = native ] && echo "docker compose" || echo "docker-compose" ) down
cd /
docker rm -f piler mysql_piler manticore_piler memcached_piler nginx-proxy nginx-letsencrypt > /dev/null 2>&1

rm -rf "$INSTALL_DIR"
tar --numeric-owner -xzf "$BACKUP_DIR/install-dir.tgz" -C "$(dirname "$INSTALL_DIR")" || exit 1

for v in$backupVolumes; do
  rm -rf "$VOLUME_ROOT/\$v/_data"
done
tar --numeric-owner -xzf "$BACKUP_DIR/volumes.tgz" -C "$VOLUME_ROOT" || exit 1

cd "$INSTALL_DIR" && $( [ "$COMPOSE_VERSION" = native ] && echo "docker compose" || echo "docker-compose" ) up -d
echo "Restore finished."
EOF
chmod 700 "$BACKUP_DIR/restore.sh"

info "Backup finished:"
ls -lh "$BACKUP_DIR"

#######################################################################################

step "2/4 Switch update source to $REPO_RAW_URL"

cp "$INSTALL_DIR/install-piler.sh" "$INSTALL_DIR/install-piler.sh.simatec"

tmpDir="$(mktemp -d)"
for f in install-piler.sh update.sh README.md; do
  wget -q "$REPO_RAW_URL/$f" -O "$tmpDir/$f" || die "Download of $REPO_RAW_URL/$f failed. Restore with: bash $BACKUP_DIR/restore.sh"
done
grep -q "REPO_RAW_URL" "$tmpDir/install-piler.sh" && grep -q "REPO_RAW_URL" "$tmpDir/update.sh" \
  || die "Downloaded files are not from DSTech-IT/mailpiler-with-docker. Restore with: bash $BACKUP_DIR/restore.sh"
for f in install-piler.sh update.sh README.md; do
  mv "$tmpDir/$f" "$INSTALL_DIR/$f"
done
rm -rf "$tmpDir"
info "install-piler.sh, update.sh and README.md updated (old installer: install-piler.sh.simatec)"

#######################################################################################

step "3/4 Update Piler (image build takes a few minutes)"

touch "$INSTALL_DIR/.update"
# Answers for update.sh: perform the update / reindex
printf 'y\n%s\n' "$REINDEX" | bash "$INSTALL_DIR/update.sh"

#######################################################################################

step "4/4 Check the update"

cd "$INSTALL_DIR" || die "Cannot change to $INSTALL_DIR."
. ./piler.conf

info "Waiting for the containers to become healthy (max. 3 minutes) ..."
for _ in $(seq 1 36); do
  pilerHealth="$(docker inspect -f '{{.State.Health.Status}}' piler 2>/dev/null)"
  mysqlHealth="$(docker inspect -f '{{.State.Health.Status}}' mysql_piler 2>/dev/null)"
  [ "$pilerHealth" = healthy ] && [ "$mysqlHealth" = healthy ] && break
  sleep 5
done

compose ps
echo

errors=0
check() {
  if [ "$2" = "$3" ]; then
    echo "${greenBold}[OK]${normal}    $1: $2"
  else
    echo "${redBold}[ERROR]${normal} $1: '$2' (expected: '$3')"
    errors=$((errors + 1))
  fi
}

check "piler container"       "$(docker inspect -f '{{.State.Health.Status}}' piler 2>/dev/null)" "healthy"
check "mysql_piler container" "$(docker inspect -f '{{.State.Health.Status}}' mysql_piler 2>/dev/null)" "healthy"
check "manticore_piler"       "$(docker inspect -f '{{.State.Running}}' manticore_piler 2>/dev/null)" "true"
check "memcached_piler"       "$(docker inspect -f '{{.State.Running}}' memcached_piler 2>/dev/null)" "true"
check "piler image"           "$(docker inspect -f '{{.Config.Image}}' piler 2>/dev/null)" "piler-docker/piler:${PILER_VERSION}"
check "piler package"         "$(docker exec piler dpkg-query -W -f='${Version}' piler 2>/dev/null | cut -d- -f1)" "${PILER_VERSION}"
check "mariadb image"         "$(docker inspect -f '{{.Config.Image}}' mysql_piler 2>/dev/null)" "mariadb:${MARIA_DB_VERSION}"
check "update source"         "$(grep -q 'DSTech-IT/mailpiler-with-docker' install-piler.sh && echo DSTech-IT || echo unknown)" "DSTech-IT"

echo
info "Last error lines in the piler log (if any):"
docker logs piler 2>&1 | grep -i "error" | tail -5

echo
if [ "$errors" -eq 0 ]; then
  echo "${greenBold}${HLINE}"
  echo "${greenBold}  Migration finished: Piler $OLD_PILER_VERSION -> $PILER_VERSION, MariaDB $OLD_MARIA_DB_VERSION -> $MARIA_DB_VERSION"
  echo "${greenBold}${HLINE}${normal}"
else
  echo "${redBold}${HLINE}"
  echo "${redBold}  Migration finished with $errors error(s), please check the output above"
  echo "${redBold}  Logs: docker logs piler / docker logs mysql_piler / docker logs manticore_piler"
  echo "${redBold}${HLINE}${normal}"
fi

echo
echo "${blue}${HLINE}"
echo "${blue}Please check in the web interface:"
if [ "$USE_LETSENCRYPT" = "yes" ]; then
  echo "${blue}  https://${PILER_DOMAIN}"
else
  echo "${blue}  http://${PILER_DOMAIN} or http://local-ip"
fi
echo "${blue}  - login works"
echo "${blue}  - search finds old mails"
echo "${blue}  - new mails are archived"
echo
echo "${blue}Rollback (only while the old image simatec/piler:$OLD_PILER_VERSION exists):"
echo "${blue}  bash $BACKUP_DIR/restore.sh"
echo
echo "${blue}If everything works, remove the old image and unused data:"
echo "${blue}  docker image rm simatec/piler:$OLD_PILER_VERSION"
echo "${blue}  docker system prune"
echo
echo "${blue}Future updates: bash install-piler.sh -> 2) Update-Piler"
echo "${blue}${HLINE}${normal}"
echo

[ "$errors" -eq 0 ]
