#!/usr/bin/env bash

set -e
set -o pipefail

ACCOUNT_ID=""

function urlencode() {
  txt="${1}"

  printf %s "${txt}" | jq -sRr @uri
}

function config_account_id() {
  name_prefix="${1}"

  ACCOUNT_ID=$(curl --request GET --silent --fail-with-body \
    --url https://api.cloudflare.com/client/v4/accounts \
    --header 'Content-Type: application/json' \
    --header "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
    --header "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
    | jq -r '.result[] | select(.name | startswith("'"${name_prefix}"'")) | .id')
}

function create_tunnel() {
  tunnel_name="${1}"

  curl --request POST --silent --fail-with-body \
    --url https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/cfd_tunnel \
    --header 'Content-Type: application/json' \
    --header "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
    --header "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
    --data '{
    "config_src": "cloudflare",
    "name": "'"${tunnel_name}"'",
    "tunnel_secret": "'"$(head -c 32 < /dev/urandom | base64)"'"
  }' | jq -r '.result.id'
}

function get_tunnel_id () {
  tunnel_name="${1}"

  curl --request GET --silent --fail-with-body \
    --url https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/cfd_tunnel \
    --header 'Content-Type: application/json' \
    --header "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
    --header "X-Auth-Key: ${CLOUDFLARE_API_KEY}" | jq -r '.result[] |
      select(.name == "'"${tunnel_name}"'") |
      select(.deleted_at == null) |
      .id'
}

function get_tunnels () {
  curl --request GET --silent --fail-with-body \
    --url https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/cfd_tunnel \
    --header 'Content-Type: application/json' \
    --header "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
    --header "X-Auth-Key: ${CLOUDFLARE_API_KEY}"
}

function create_tunnel_route () {
  tunnel_id="${1}"
  cidr="${2}"
  comment="${3}"

  curl --request POST --silent --fail-with-body \
    --url "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/teamnet/routes/network/$(urlencode "${cidr}")" \
    --header 'Content-Type: application/json' \
    --header "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
    --header "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
    --data '{
      "comment": "'"${comment}"'",
      "tunnel_id": "'"${tunnel_id}"'"
  }'
}
