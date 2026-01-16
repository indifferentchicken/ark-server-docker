#!/bin/bash

echo "Starting ARK server with arkmanager..."

# Create arkmanager configuration
tee /etc/arkmanager/arkmanager.cfg > /dev/null << EOF
# ARK Server Manager Configuration
arkserverroot="/home/steam/steamcmd/ark"
arkserverexec="ShooterGame/Binaries/Linux/ShooterGameServer"
arkbackupdir="/home/steam/ark-backups"
arkwarnminutes="15"
arkAutoUpdateOnStart="${UPDATE_ON_START:-true}"
arkprecisewarn="false"

# SteamCMD Configuration
steamcmdroot="/home/steam/steamcmd"
steamcmdexec="steamcmd.sh"
steamcmd_user="steam"

# Beta branch configuration
arkbranch="${BETA:-public}"

logdir="/var/log/arktools"

# Server Configuration
serverMap="${WORLD:-TheIsland}"
ark_ServerPassword="${SERVER_PASSWORD:-}"
ark_ServerAdminPassword="${ADMIN_PASSWORD:-adminpass}"
ark_RCONEnabled="True"
ark_RCONPort="${RCON_PORT:-27020}"
ark_Port="${SERVER_PORT:-7777}"
ark_QueryPort="${QUERY_PORT:-27015}"
ark_MaxPlayers="${MAX_PLAYERS:-10}"
ark_SessionName="${SESSION_NAME:-ARK Server}"
ark_DifficultyOffset="${DIFFICULTY_OFFSET:-0.2}"
ark_OverrideOfficialDifficulty="${OVERRIDE_OFFICIAL_DIFFICULTY:-5.0}"
EOF

# Add PvE flag if enabled
if [ "${SERVER_PVE}" = "true" ]; then
    echo "arkflag_ServerPVE=true" | tee -a /etc/arkmanager/arkmanager.cfg > /dev/null
fi

# Add BattlEye configuration
if [ "${BATTLEEYE}" = "true" ]; then
    echo "arkflag_UseBattlEye=true" | tee -a /etc/arkmanager/arkmanager.cfg > /dev/null
else
    echo "arkflag_NoBattlEye=true" | tee -a /etc/arkmanager/arkmanager.cfg > /dev/null
fi

# Add cluster configuration if set
if [ ! -z "${CLUSTER_ID}" ] && [ "${CLUSTER_ID}" != "" ]; then
    echo "ark_ClusterId=\"${CLUSTER_ID}\"" | tee -a /etc/arkmanager/arkmanager.cfg > /dev/null
    echo "Cluster ID configured: ${CLUSTER_ID}"
fi

if [ ! -z "${CLUSTER_DIR_OVERRIDE}" ] && [ "${CLUSTER_DIR_OVERRIDE}" != "" ]; then
    echo "ark_ClusterDirOverride=\"${CLUSTER_DIR_OVERRIDE}\"" | tee -a /etc/arkmanager/arkmanager.cfg > /dev/null
fi

# Add additional arguments if set
if [ ! -z "${ADDITIONAL_ARGS}" ] && [ "${ADDITIONAL_ARGS}" != "" ]; then
    echo "" | tee -a /etc/arkmanager/arkmanager.cfg > /dev/null
    echo "# Additional custom arguments" | tee -a /etc/arkmanager/arkmanager.cfg > /dev/null
    for arg in ${ADDITIONAL_ARGS}; do
        if [[ $arg == -* ]]; then
            flag="${arg#-}"
            echo "arkflag_${flag}=true" | tee -a /etc/arkmanager/arkmanager.cfg > /dev/null
        fi
    done
    echo "Additional arguments configured: ${ADDITIONAL_ARGS}"
fi

# Always enable logging
echo "arkflag_log=true" | tee -a /etc/arkmanager/arkmanager.cfg > /dev/null

# Create instance configuration
mkdir -p /etc/arkmanager/instances
tee /etc/arkmanager/instances/main.cfg > /dev/null << EOF
# Instance Configuration
arkserverroot="/home/steam/steamcmd/ark"
arkserverexec="ShooterGame/Binaries/Linux/ShooterGameServer"
EOF

# Install ARK server if it doesn't exist
if [ ! -f "/home/steam/steamcmd/ark/ShooterGame/Binaries/Linux/ShooterGameServer" ]; then
    echo "Installing ARK server (this may take a while, downloading ~30GB)..."
    arkmanager install @main
    echo "ARK server installation completed!"
fi

# Install mods if specified
if [ ! -z "$MOD_IDS" ] && [ "$MOD_IDS" != "" ]; then
    echo "Installing mods: $MOD_IDS"
    IFS=',' read -ra MODS <<< "$MOD_IDS"
    for mod in "${MODS[@]}"; do
        mod=$(echo $mod | tr -d ' ')
        echo "Installing mod: $mod"
        arkmanager installmod $mod @main
    done
fi

# Update server if UPDATE_ON_START is set
if [ "${UPDATE_ON_START}" = "true" ]; then
    echo "Updating ARK server..."
    arkmanager update --update-mods @main
fi

# Start the server
echo "Starting ARK server..."
arkmanager start --noautoupdate @main

# Monitor the server's status
while true; do
    if ! arkmanager status @main > /dev/null 2>&1; then
        echo "Server stopped unexpectedly, restarting..."
        arkmanager start --noautoupdate @main
    fi
    sleep 60
done
