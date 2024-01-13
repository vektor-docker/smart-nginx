#!/usr/bin/env bash

set -e

[ ! -d "/config/letsencrypt" ] && mkdir --parents /config/letsencrypt || true
