# piler-docker


### Mailpiler for Docker

This is a project to get the Mailpiler running in a docker compose system in a simple and uncomplicated way.

You can find more information about the Piler project here.

https://www.mailpiler.org/

*******************************************************************************************************

### Installation Guide:

* Install Docker

`curl -sSL https://get.docker.com/ | CHANNEL=stable sh
systemctl enable --now docker`

* Install Docker-Compose

`curl -L https://github.com/docker/compose/releases/download/$(curl -Ls https://www.servercow.de/docker-compose/latest.php)/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose`

* reboot your system

`reboot now`

* remove postfix

`apt purge postfix`

* Clone repository

`cd /opt
clone https://github.com/simatec/piler-docker.git
cd /opt/piler-docker`

configure your Piler seetings

`nano piler.conf`

after config start the Install

`./install-piler.sh`

Congratulations your Piler is installed...

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