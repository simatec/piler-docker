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

* Clone repository

```
cd /opt
git clone https://github.com/simatec/piler-docker.git
cd /opt/piler-docker
```

* configure your Piler seetings

```
nano piler.conf
```

* after config start the Install

```
bash install-piler.sh
```


Congratulations your Piler is installed...

If you have Let's Encrypt activated, you can reach the Piler at https://your-piler-domain

If Let's Encrypt is disabled, the Piler is at http://your-piler-domain or at http://your-local-IP


> After installation, any changes can be made in piler.conf at any time and the install script can then be run again.


**********************************************************************************************************

## Changelog

### 0.2.0 (09.03.2022)
* (simatec) Let's Encrypt added

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