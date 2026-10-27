FROM ubuntu:26.04@sha256:c098726dd9b9733f3e885f8de0ef375206a311b0a317eadc40d347b1115fb944

# Piler release package (https://github.com/jsuto/piler/releases)
# Package name: piler_<version>-<distro>-<commit>_<arch>.deb
# Keep PILER_VERSION in sync with build/build.conf
ARG PILER_VERSION="1.4.9"
ARG PILER_DISTRO="resolute"
ARG PILER_COMMIT="d3f4b07"
ARG PILER_SHA256_AMD64="e6f9e5e7bf307f024ea248352b93d5cad0925f0f998b2902e0e64ce0db51859a"
ARG PILER_SHA256_ARM64="af324754a748ec31aa83204ff20404cf7866fc0de71fc30ae796b1c9e51e42ab"
ARG TARGETARCH

LABEL description="piler ubuntu resolute image" \
      maintainer="Janos SUTO, sj@acts.hu" \
      package="piler_${PILER_VERSION}-${PILER_DISTRO}-${PILER_COMMIT}_${TARGETARCH}.deb"

ENV DEBIAN_FRONTEND="noninteractive" \
    DISTRO="resolute" \
    PILER_USER="piler" \
    MYSQL_DATABASE="piler"

ADD https://github.com/jsuto/piler/releases/download/piler-${PILER_VERSION}/piler_${PILER_VERSION}-${PILER_DISTRO}-${PILER_COMMIT}_${TARGETARCH}.deb /tmp/piler.deb

# hadolint ignore=DL3008
RUN case "${TARGETARCH}" in \
       amd64) PILER_SHA256="${PILER_SHA256_AMD64}" ;; \
       arm64) PILER_SHA256="${PILER_SHA256_ARM64}" ;; \
       *) echo "unsupported architecture: ${TARGETARCH}" 1>&2; exit 1 ;; \
    esac && \
    echo "${PILER_SHA256}  /tmp/piler.deb" | sha256sum -c - && \
    userdel -r ubuntu && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
       wget openssl sysstat catdoc unrtf poppler-utils nginx tnef sudo libtre5 cron ca-certificates curl rsyslog gnupg mariadb-client-core python3 python3-mysqldb libzip5 \
       php-cli php-cgi php-mysql php-fpm php-zip php-ldap php-gd php-curl php-xml php-memcached && \
    sed -i '/session    required     pam_loginuid.so/c\#session    required     pam_loginuid.so' /etc/pam.d/cron && \
    dpkg -i /tmp/piler.deb && \
    touch /etc/piler/MANTICORE && \
    ln -sf /etc/piler/piler-nginx.conf /etc/nginx/sites-enabled && \
    echo "www-data ALL=NOPASSWD: /etc/init.d/rc.piler reload" > /etc/sudoers.d/piler && \
    rm -f /tmp/piler.deb /etc/nginx/sites-enabled/default /etc/piler/piler.key /etc/piler/piler.pem /etc/piler/config-site.php && \
    cp -R /etc/piler /tmp/piler-conf && \
    crontab -u $PILER_USER /usr/share/piler/piler.cron && \
    sed -i '/imklog/ s/^/#/' /etc/rsyslog.conf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/*

VOLUME ["/etc/piler","/var/piler/store","/var/piler/manticore","/var/piler/imap","/var/piler/stat","/var/spool/cron/crontabs"]

EXPOSE 25/tcp
EXPOSE 80/tcp
EXPOSE 443/tcp

COPY --chmod=755 start.sh /start.sh

CMD ["/start.sh"]
