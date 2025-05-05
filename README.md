# piler-docker

[![License](https://img.shields.io/github/license/simatec/piler-docker?style=flat)](https://github.com/simatec/piler-docker/blob/master/LICENSE)
[![Donate](https://img.shields.io/badge/paypal-donate%20|%20spenden-blue.svg)](https://paypal.me/mk1676)


**************************************************************************************************************

**If you like it, please consider a donation:**
  
[![paypal](https://www.paypalobjects.com/en_US/DK/i/btn/btn_donateCC_LG.gif)](https://paypal.me/mk1676)

**************************************************************************************************************


### Mailpiler for Docker

This is a project to get the Mailpiler running in a docker compose system in a simple and uncomplicated way.

You can find more information about the Piler project here.

https://www.mailpiler.org/ or https://github.com/jsuto/piler

*******************************************************************************************************

### DockerHub

https://hub.docker.com/r/simatec/piler

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

* Install Docker-Compose

```
curl -L https://github.com/docker/compose/releases/download/v$(curl -Ls https://www.servercow.de/docker-compose/latest.php)/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
```
```
chmod +x /usr/local/bin/docker-compose
```

* reboot your system

```
reboot now
```

* Clone repository

```
cd /opt
```
```
git clone https://github.com/simatec/piler-docker.git
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

#### Using Custom Database

If you are using a custom database (for example your existing mysql/mariadb server), you have to create the database by yourself.

First create a new user, for example `piler`, and write down the username and password.

After that create a new database, for example `piler`, and then import the `piler.sql` from the examples folder in the new database, so that you have all database tables.<br>
(Tested with `mailpiler 1.4.4` installation)

Finally enter everything during the installation process (`hostname`, `username`, `password` and `database`).

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

* After a successful update, unused container images can be removed from the system with the following command:

```
docker system prune
```

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

Copyright (c) 2022 - 2024 simatec

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