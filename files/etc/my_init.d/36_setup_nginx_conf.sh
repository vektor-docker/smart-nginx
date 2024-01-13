#!/usr/bin/env bash

set -e

[ ! -d "/config/nginx/config/config.d" ] && mkdir --parents /config/nginx/config/config.d || true
