#BUILD THE SERVER IMAGE
FROM --platform=linux/amd64 cm2network/steamcmd:root

# Install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y --no-install-recommends \
    lib32gcc-s1 \
    lib32stdc++6 \
    perl-modules \
    curl \
    lsof \
    bzip2 \
    gettext-base \
    procps \
    jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

LABEL maintainer="support@indifferentbroccoli.com" \
      name="indifferentbroccoli/ark-server-docker" \
      github="https://github.com/indifferentbroccoli/ark-server-docker" \
      dockerhub="https://hub.docker.com/r/indifferentbroccoli/ark-server-docker"

ENV HOME=/home/steam \
    PUID=1000 \
    PGID=1000 \
    SESSION_NAME="ARK Server" \
    SERVER_PASSWORD="" \
    ADMIN_PASSWORD="adminpass" \
    MAX_PLAYERS=10 \
    WORLD="TheIsland" \
    SERVER_PORT=7777 \
    QUERY_PORT=27015 \
    RCON_PORT=27020 \
    SERVER_PVE=false \
    BATTLEEYE=false \
    DIFFICULTY_OFFSET=0.2 \
    OVERRIDE_OFFICIAL_DIFFICULTY=5.0 \
    CLUSTER_ID="" \
    CLUSTER_DIR_OVERRIDE="" \
    MOD_IDS="" \
    ADDITIONAL_ARGS="" \
    BETA="public" \
    UPDATE_ON_START=true \
    ARKST_OUTPUT_FORMATTING=true

# Install ark-server-tools
RUN curl -sL https://raw.githubusercontent.com/arkmanager/ark-server-tools/master/netinstall.sh | bash -s steam --install-service

# Create necessary directories
RUN mkdir -p /ark /ark-backups && \
    chown -R steam:steam /ark /ark-backups /var/log/arktools

COPY ./scripts /home/steam/scripts/
COPY branding /branding

RUN chmod +x /home/steam/scripts/*.sh

WORKDIR /home/steam

HEALTHCHECK --start-period=5m \
            CMD pgrep "ShooterGameServer" > /dev/null || exit 1

ENTRYPOINT ["/home/steam/scripts/init.sh"]
