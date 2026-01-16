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

# Run as steam user
su - steam -c 'bash /home/steam/scripts/start-server.sh'
