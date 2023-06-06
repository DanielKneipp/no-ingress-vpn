#!/usr/bin/env bash

set -e
set -o pipefail

source lib.sh

ACCOUNT_NAME_PREFIX='Daniel.kneipp@outlook.com'
TUNNEL_NAME="my-tunnel"

# Config account id
echo "Getting the account id"
config_account_id "${ACCOUNT_NAME_PREFIX}"

# Create tunnel
echo "Creating tunnel ${TUNNEL_NAME}"
tunnel_id=$(create_tunnel "${TUNNEL_NAME}") || true

if [ "${tunnel_id}" == "null" ]; then
  echo "Failed to create tunnel, Trying to get id of existing tunnel"
  tunnel_id=$(get_tunnel_id "${TUNNEL_NAME}")
fi

echo "Tunnel ID is ${tunnel_id}"

# Create the tunnel route
echo "Creating ipv4 tunnel route"
create_tunnel_route "${tunnel_id}" "0.0.0.0/0" "Forward ipv4" | jq
echo "Creating ipv6 tunnel route"
create_tunnel_route "${tunnel_id}" "::/0" "Forward ipv6" | jq
