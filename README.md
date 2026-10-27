# piler-docker

[![CI](https://github.com/DSTech-IT/mailpiler-with-docker/actions/workflows/ci.yml/badge.svg)](https://github.com/DSTech-IT/mailpiler-with-docker/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/DSTech-IT/mailpiler-with-docker?style=flat)](https://github.com/DSTech-IT/mailpiler-with-docker/blob/main/LICENSE)
[![Donate](https://img.shields.io/badge/paypal-donate%20|%20spenden-blue.svg)](https://paypal.me/schldomi)


**************************************************************************************************************

**If you like it, please consider a donation:**
  
[![paypal](https://www.paypalobjects.com/en_US/DK/i/btn/btn_donateCC_LG.gif)](https://paypal.me/schldomi)

**************************************************************************************************************


### Mailpiler for Docker

This is a project to get the Mailpiler running in a docker compose system in a simple and uncomplicated way.

You can find more information about the Piler project here.

https://www.mailpiler.org/ or https://github.com/jsuto/piler

*******************************************************************************************************

### Piler Image

The Piler image is built locally from `build/Dockerfile` when the containers are started
(`docker compose up`). The Dockerfile downloads the official Piler package from
https://github.com/jsuto/piler/releases and verifies its SHA256 checksum.

The image can also be built manually with `bash build/build.sh`.

Current versions:

| Component | Version |
|-----------|---------|
| Piler | 1.4.9 |
| Base image | Ubuntu 26.04 (resolute), PHP 8.5 |
| MariaDB | 12.3.3 (LTS) |
| Manticore Search | 29.9.0 |
| Memcached | 1.6 |
| nginx-proxy / acme-companion (Let's Encrypt) | 1.11 / 2.8 |

*******************************************************************************************************


### Installation Guide:

* Install Docker and dependencies

```
apt install curl git -y
```

```
curl -sSL https://get.docker.com/ | CHANNEL=stable sh
```
```
systemctl enable --now docker
```

* Docker Compose

The Docker installation above already includes the Docker Compose plugin (`docker compose`).
Docker Compose v2 or higher is required.

* reboot your system

```
reboot now
```

* Clone repository

```
cd /opt
```
```
git clone https://github.com/DSTech-IT/mailpiler-with-docker.git piler-docker
```
```
cd /opt/piler-docker
```


* start the Install

```
bash install-piler.sh
```


Congratulations your Piler is installed...

If you have Let's Encrypt activated, you can reach the Piler at https://your-piler-domain

If Let's Encrypt is disabled, the Piler is at http://your-piler-domain or at http://your-local-IP

The Default Login is `admin@local` and the Password ist `pilerrocks`


> After installation, any changes can be made in piler.conf at any time and the install script can then be run again.


**********************************************************************************************************


### Update Guide:

You can execute the following commands to update the containers.
Here the current yml files are downloaded from Github and the containers are updated if necessary.

```
cd /opt/piler-docker
bash install-piler.sh
```
You will get a selection menu with the following options:

```
1) Install-Piler
2) Update-Piler
```

The update files are downloaded from `https://raw.githubusercontent.com/DSTech-IT/mailpiler-with-docker/main`.
Another source can be set with the environment variable `REPO_RAW_URL`.

During the update the Piler image is rebuilt locally. Configuration changes required by a new
Piler version (e.g. php-fpm socket in `piler-nginx.conf`, pid file location, database indexes)
are applied automatically when the Piler container starts.

* After a successful update, unused container images can be removed from the system with the following command:

```
docker system prune
```

**********************************************************************************************************

### Migration from simatec/piler-docker

Installations of the original project [simatec/piler-docker](https://github.com/simatec/piler-docker)
(e.g. Piler 1.4.8) can not be updated with the menu above, because their `install-piler.sh`
still downloads the update from simatec. The script `migrate-from-simatec.sh` switches an
existing installation to this repository and updates it in one step.

Run the following command as root in the install directory:

```
cd /opt/piler-docker && wget -O migrate-from-simatec.sh https://raw.githubusercontent.com/DSTech-IT/mailpiler-with-docker/main/migrate-from-simatec.sh && bash migrate-from-simatec.sh
```

> The script asks questions, so it has to be downloaded first and can not be run with `curl ... | bash`.

The script

* checks the installation (root, Docker Compose v2 or higher, volumes of the compose project `piler-docker`, free disk space)
* asks once at the beginning whether the migration and a reindex should be performed, afterwards it runs without further input
* creates a backup in `/root/piler-backup-<date>`: database dump, install directory and docker volumes, plus a `restore.sh` for a rollback
* replaces `install-piler.sh`, `update.sh` and `README.md` with the versions from this repository (the old installer is kept as `install-piler.sh.simatec`)
* runs the regular update (local image build, automatic MariaDB upgrade, config migration)
* checks the result (container health, piler image and package version, MariaDB version, update source)

The Piler is stopped during backup and update, so no mails are received in this time.

Optional settings via environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `BACKUP_DIR` | `/root/piler-backup-<date>` | Backup location (must not be inside the install directory) |
| `BACKUP_STORE` | `no` | `yes` also backs up the mail store volume, which can be very large. The update does not touch the mail store. |
| `INSTALL_DIR` | current directory | Install directory |

Example: `BACKUP_DIR=/mnt/backup/piler BACKUP_STORE=yes bash migrate-from-simatec.sh`

After the migration, check in the web interface that the login works, old mails are found and new
mails are archived. A rollback to the previous version is possible as long as the old image
`simatec/piler:1.4.8` has not been removed:

```
bash /root/piler-backup-<date>/restore.sh
```

If everything works, the old image can be removed:

```
docker image rm simatec/piler:1.4.8
docker system prune
```

Future updates are done as usual via `bash install-piler.sh` and `2) Update-Piler`.

**********************************************************************************************************

### Using the Piler on the command line

For use on the command line, we first log into the container.

```
docker exec -it piler /bin/bash
```

Next we switch to the user "piler"

```
su piler
```

To get write permissions, we switch to the /var/tmp folder

```
cd /var/tmp
```

Here you can now execute the functions of the Piler on the command line.
Here are some examples:

```
pilerimport -h
crontab -l
```

To leave the container on the console you have to execute 2x `exit`.


**********************************************************************************************************

## Changelog

### 1.2.1 (27.10.2026)
* (DSTech-IT) Security: PHP2Shell (CVE-2026-109618, CVE-2026-109619), the update installs the fixed PHP 8.5.4-0ubuntu1.5
* (DSTech-IT) update.sh rebuilds the Piler image without cache, so Ubuntu security updates are always installed
* (DSTech-IT) update.sh pulls new releases of the MariaDB, Manticore, Memcached and nginx-proxy images
* (DSTech-IT) Piler image: install all available Ubuntu updates during the build (apt-get upgrade)

### 1.2.0 (27.10.2026)
* (DSTech-IT) Migration script `migrate-from-simatec.sh` for existing simatec/piler-docker installations
* (DSTech-IT) Fix update.sh: stop the containers before the old docker-compose.yml is removed
* (DSTech-IT) Base image Ubuntu 26.04 pinned by digest and updated to the current rebuild with security updates
* (DSTech-IT) Fix Mailcow comment in config-site.php written by install-piler.sh and patch.sh
* (DSTech-IT) CI checks, Dependabot and a weekly check for new Piler, MariaDB and image versions

### 1.1.0 (24.09.2026)
* (DSTech-IT) Update to Piler 1.4.9
* (DSTech-IT) Base image Ubuntu 26.04 (resolute) with PHP 8.5
* (DSTech-IT) Update MariaDB to 12.3.3 (LTS), Manticore Search to 29.9.0, Memcached to 1.6
* (DSTech-IT) Let's Encrypt: nginxproxy/nginx-proxy 1.11 and nginxproxy/acme-companion 2.8
* (DSTech-IT) Piler image is built locally, package download with SHA256 check (amd64 and arm64)
* (DSTech-IT) Automatic migration of existing configs on container start (php-fpm socket, pid file, DB indexes)
* (DSTech-IT) Fixed compose project name (piler-docker), independent of the install directory
* (DSTech-IT) Support for Docker Compose v5 in install and update scripts
* (DSTech-IT) Update source changed to DSTech-IT/mailpiler-with-docker
* (DSTech-IT) Fix version check in patch.sh

### 1.0.0 (24.11.2025)
* (simatec) Update to Piler 1.4.8

### 0.9.7 (14.06.2024)
* (simatec) Fix Network on Update

### 0.9.7 (14.06.2024)
* (simatec) Release 0.9.7

### 0.9.6 (11.06.2024)
* (simatec) Hostname Fix

### 0.9.5 (10.06.2024)
* (simatec) small fix

### 0.9.4 (05.06.2024)
* (simatec) patch for Piler Update added

### 0.9.3 (01.06.2024)
* (simatec) Piler v1.4.5 updated
* (simatec) MariaDB v11.1.2 updated

### 0.9.2 (19.09.2023)
* (simatec) Piler v1.4.4 updated

### 0.9.1 (23.01.2023)
* (simatec) Piler updated

### 0.9.1 (23.01.2023)
* (simatec) Piler Docker Hub added
* (simatec) Fix Automatic Import

### 0.9.0 (23.01.2023)
* (simatec) Piler Build added
* (simatec) Piler Import Option added
* (simatec) Fix Updater

### 0.8.3 (19.01.2023)
* (simatec) Update himself added

### 0.8.2 (18.01.2023)
* (simatec) docker, curl and git Check added
* (simatec) Update Config added

### 0.8.1 (17.01.2023)
* (simatec) Docker Compose Check added

### 0.8.0 (17.01.2023)
* (simatec) Config-Menu for Installer added

### 0.7.0 (15.01.2023)
* (simatec) New Volumes added
* (simatec) Fix Installer

### 0.6.0 (18.12.2022)
* (simatec) Update Installer
* (simatec) update.sh added
* (simatec) downgrade mariadb to v10.6

### 0.5.3 (17.12.2022)
* (simatec) Installer Fix

### 0.5.2 (16.12.2022)
* (simatec) update piler to v1.4.2

### 0.5.1 (15.12.2022)
* (simatec) update piler to v1.4.1
* (simatec) update mariadb to v10.9.4

### 0.5.0 (25.08.2022)
* (simatec) update piler to 1.3.12
* (simatec) update mariadb to 10.9.2

### 0.4.0 (20.04.2022)
* (simatec) small fixes

### 0.3.0 (10.03.2022)
* (simatec) purge option added to config

### 0.2.0 (09.03.2022)
* (simatec) Let's Encrypt added

### 0.1.0 (08.03.2022)
* (simatec) first beta

## License
MIT License

Copyright (c) 2022 - 2025 simatec

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.