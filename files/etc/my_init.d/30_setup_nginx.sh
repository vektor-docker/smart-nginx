#!/usr/bin/env bash

set -e

if [ ! -f "/etc/nginx/nginx.conf.docker" ]; then
    cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.docker
fi
cp --force /etc/nginx/nginx.conf.docker /etc/nginx/nginx.conf

sed --in-place "s/user nginx;/user system;/g" /etc/nginx/nginx.conf
sed --in-place "s/listen.*\\[::\\]:80 default_server;/#listen       [::]:80 default_server;/g" /etc/nginx/nginx.conf
sed --regexp-extended --in-place "s/(\\s+root\\s+)\\/usr\\/share\\/nginx\\/html;/\1\\/app;/g" /etc/nginx/nginx.conf

if [ "${WORKER_CONNECTIONS}" ]; then
    sed --in-place "s/worker_connections .*;/worker_connections ${WORKER_CONNECTIONS};/g" /etc/nginx/nginx.conf
fi

if [ "${WORKER_RLIMIT_NOFILE}" ]; then
    sed --in-place "/worker_processes/i worker_rlimit_nofile ${WORKER_RLIMIT_NOFILE};" /etc/nginx/nginx.conf
fi
