#!/bin/sh

# Usage:
# $ show-certs "hellupline.dev" "360"
# $ show-certs "hellupline.dev"

set -x # verbose
set -o pipefail # exit on pipeline error
set -e # exit on error
set -u # variable must exist

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -ge 1 ] || die "1 argument required, $# provided"

DOMAIN="${1}"
DAYS="${2:-30}"
SECONDS="$((${DAYS} * 24 * 60 * 60))"

openssl s_client -servername "${DOMAIN}" -connect "${DOMAIN}":443 -showcerts < /dev/null | openssl x509 -noout -text -subject -issuer -dates -checkend "${SECONDS}"
