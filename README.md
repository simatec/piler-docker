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

https://www.mailpiler.org/

*******************************************************************************************************

### Installation Guide:

* Install Docker

```
apt install curl git -y
```

```
curl -sSL https://get.docker.com/ | CHANNEL=stable sh
systemctl enable --now docker
```

* Install Docker-Compose

```
curl -L https://github.com/docker/compose/releases/download/$(curl -Ls https://www.servercow.de/docker-compose/latest.php)/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

* reboot your system

```
reboot now
```

* remove postfix

```
apt purge postfix -y
```

* Clone repository

```
cd /opt
git clone https://github.com/simatec/piler-docker.git
cd /opt/piler-docker
```

configure your Piler seetings

```
nano piler.conf
```

after config start the Install

```
bash install-piler.sh
```

Congratulations your Piler is installed...

The Piler can now be reached at http://your-domain:8080.

- After installation, any changes can be made in Piler.conf at any time and the install script can then be run again.


******************************************************************************************************

### SSL certificates

If you want to run your Piler with SSL certificates, which always makes sense if the Piler isn't running locally, then I recommend the Nginx proxy manager for Docker.

I built my setup with the Nginx.

The Ngnix can be installed with the following compose.

Create a docker-compose.yml file similar to this:

```
version: '3'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
```

```
docker-compose up -d
```

Log in to the Admin UI
When your docker container is running, connect to it on port 81 for the admin interface. Sometimes this can take a little bit because of the entropy of keys.

http://your-domain:81


**********************************************************************************************************

## Changelog

### 0.1.0 (08.03.2022)
* (simatec) first beta

## License
MIT License

Copyright (c) 2022 simatec

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