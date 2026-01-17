#!/bin/bash
set -e

# Show branding
cat /branding

# Set PUID/PGID
if [ -n "${PUID}" ] && [ -n "${PGID}" ]; then
    echo "Setting steam user to UID:${PUID} GID:${PGID}"
    usermod -o -u "${PUID}" steam
    groupmod -o -g "${PGID}" steam
fi

# Fix permissions
chown -R steam:steam /home/steam /var/log/arktools
chown -R steam:steam /etc/arkmanager

# Trap signals for graceful shutdown
trap 'su - steam -c "arkmanager stop --saveworld @main" && exit 0' SIGTERM SIGINT

# Export and pass environment variables to steam user
su - steam -c "
    export PUID='${PUID}'
    export PGID='${PGID}'
    export SESSION_NAME='${SESSION_NAME}'
    export SERVER_PASSWORD='${SERVER_PASSWORD}'
    export ADMIN_PASSWORD='${ADMIN_PASSWORD}'
    export MAX_PLAYERS='${MAX_PLAYERS}'
    export WORLD='${WORLD}'
    export SERVER_PORT='${SERVER_PORT}'
    export QUERY_PORT='${QUERY_PORT}'
    export RCON_PORT='${RCON_PORT}'
    export SERVER_PVE='${SERVER_PVE}'
    export BATTLEEYE='${BATTLEEYE}'
    export DIFFICULTY_OFFSET='${DIFFICULTY_OFFSET}'
    export OVERRIDE_OFFICIAL_DIFFICULTY='${OVERRIDE_OFFICIAL_DIFFICULTY}'
    export CLUSTER_ID='${CLUSTER_ID}'
    export CLUSTER_DIR_OVERRIDE='${CLUSTER_DIR_OVERRIDE}'
    export MOD_IDS='${MOD_IDS}'
    export ADDITIONAL_ARGS='${ADDITIONAL_ARGS}'
    export BETA='${BETA}'
    export UPDATE_ON_START='${UPDATE_ON_START}'
    bash /home/steam/scripts/start.sh
"
