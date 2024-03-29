#!/bin/sh

# Usage:
# $ make-selfsign-certificate "hellupline.dev"

# set -x # verbose
set -o pipefail # exit on pipeline error
set -e # exit on error
set -u # variable must exist

DOMAIN=${1:-localhost}

mkdir -p tls-certs

openssl req -nodes -x509 -sha256 -days 3650 \
    -newkey rsa:4096 \
    -keyout tls-certs/service.key \
    -out tls-certs/service.pem \
    -addext "subjectAltName = DNS:${DOMAIN},IP:::1,IP:127.0.0.1" \
    -subj "/O=${DOMAIN}/CN=${DOMAIN}"
