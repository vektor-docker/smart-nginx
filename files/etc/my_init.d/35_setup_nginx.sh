#!/usr/bin/env bash

set -e

if [ ! -d "/config/nginx" ]; then
    mkdir --parents \
        /config/nginx/log \
        /config/nginx/config/default.d \
        /config/nginx/config/conf.d \
        /config/nginx/certs \
        /config/nginx/htpasswd \
        /config/nginx/config/vhost.d \
        /config/nginx/www
    chmod --recursive 0776 /var/lib/nginx
    chown --recursive system:system /config/nginx
fi

chmod --recursive 0776 /var/lib/nginx
chown --recursive system:system /var/lib/nginx

if [ ! -d "/config/letsencrypt/live" ]; then
    mkdir --parents /config/letsencrypt/live
    chmod --recursive 0776 /config/letsencrypt/live
    chown --recursive system:system /config/letsencrypt/live
fi

if [ "${USE_DHPARAM}" == "yes" ] && [ ! -f "/config/nginx/certs/dhparam.pem" ]; then
    openssl dhparam -dsaparam -out /config/nginx/certs/dhparam.pem 4096
fi

sed --in-place "s/error_log \\/var\\/log\\/nginx\\/error.log;/error_log \\/config\\/nginx\\/log\\/error.log;/g" /etc/nginx/nginx.conf
sed --in-place "s/access_log.*main;/access_log \\/config\\/nginx\\/log\\/access.log main;/g" /etc/nginx/nginx.conf
sed --in-place "s/include\\s.*conf.d.*;/include \\/config\\/nginx\\/config\\/conf.d\\/*.conf;/g" /etc/nginx/nginx.conf
sed --in-place "s/include\\s.*default.d.*;/include \\/config\\/nginx\\/config\\/default.d\\/*.conf;/g" /etc/nginx/nginx.conf
# Переставляем корневой каталог в /config/nginx/www, чтобы иметь доступ к каталогу с корневыми ресурсами
sed --regexp-extended --in-place "s/(\\s+root\\s+)\\/app;/\1\\/config\\/nginx\\/www;/g" /etc/nginx/nginx.conf

