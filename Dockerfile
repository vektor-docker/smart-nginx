FROM ubuntu:22.04 as BASE

MAINTAINER Viktor Verbitsky <vektory79@gmail.com>

COPY files /

ENV PUID=911 \
    PGID=911 \
    PUSER=system \
    BASE_APTLIST="syslog-ng inotify-tools zip unzip wget less psmisc iproute2 runit locales nginx certbot" \
    LOG_LEVEL="INFO" \
    DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm" \
    LANG="ru_RU.UTF-8" \
    TZ="Europe/Moscow" \
    KILL_PROCESS_TIMEOUT=5 \
    KILL_ALL_PROCESSES_TIMEOUT=5 \
    APTLIST="" \
    LOG_LEVEL="INFO" \
    WORKER_CONNECTIONS="" \
    WORKER_RLIMIT_NOFILE="" \
    USE_DHPARAM="no" \
    DOCKER_HOST=unix:///tmp/docker.sock \
    DEFAULT_HOST="localhost" \
    DEFAULT_USE_LETSENCRYPT="no" \
    LETSENCRYPT_EMAIL="" \
    DOCKER_GEN_VERSION="0.11.1"

RUN echo '*** Set permissions for the support tools' && \
    chmod --recursive +x /etc/my_init.d/*.sh /etc/service /usr/local/bin/* && \
    sync && \
    echo '*** Update all deb packages' && \
    apt update && \
    echo '*** Install additional softvare' && \
    apt -o Dpkg::Options::="--force-confdef" install --yes ${BASE_APTLIST} && \
#    apt -o Dpkg::Options::="--force-confnew" install --yes ${BASE_APTLIST} && \
    echo '*** Add user "system"' && \
    useradd -u ${PUID} -U -d /config -s /bin/false system && \
    usermod -G users system && \
    echo '*** Prepare application directories' && \
    mkdir -p /app /config /defaults && \
    echo '*** Install init process.' && \
    mkdir -p /etc/my_init.d && \
    mkdir -p /etc/container_environment && \
    touch /etc/container_environment.sh && \
    touch /etc/container_environment.json && \
    chmod 700 /etc/container_environment /etc/container_environment.sh /etc/container_environment.json && \
    ln -s /etc/container_environment.sh /etc/profile.d/ && \
    rm -f /tmp/* && \
    echo '*** Configure the syslog daemon and logrotate.' && \
    touch /var/log/syslog && \
    mknod -m 640 /dev/xconsole p && \
    chmod u=rw,g=r,o= /var/log/syslog && \
    echo '*** Configure locale.' && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    echo '*** Configure the cron daemon.' && \
    chmod 600 /etc/crontab && \
    sed -i 's/^\s*session\s\+required\s\+pam_loginuid.so/# &/' /etc/pam.d/cron && \
    chown system:system /app /config /defaults && \
    echo '*** Clean up the system' && \
    rm -rf /var/log/anaconda && \
    echo '*** Clean up apt caches' && \
    apt-clean && \
    echo '*** Prepare NGINX work directory' && \
    cp --recursive --archive /usr/share/nginx/html/* /app && \
    echo '*** Setup docker-gen' && \
    wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz && \
    tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz && \
    rm /docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz && \
    echo '*** Shedule the letsencrypt renew' && \
    crontab /etc/cron.d/letsencrypt-renew

LABEL \
    os.vendor="Ubuntu" \
    os.version="${UBUNTU_VERSION}" \
    os.license="GPLv2" \
    image.vendor="vektory79"

EXPOSE 80

CMD ["/usr/local/bin/my_init"]
