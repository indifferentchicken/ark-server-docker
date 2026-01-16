# ARK: Survival Evolved Dedicated Server Docker

A Docker container for running an ARK: Survival Evolved dedicated server using [ARK Server Tools (arkmanager)](https://github.com/arkmanager/ark-server-tools).

## Features

- **ARK Server Tools Integration**: Full-featured server management with arkmanager
- **Automatic Updates**: Optional server and mod updates on startup
- **Mod Support**: Easy installation and management of Steam Workshop mods
- **Comprehensive Configuration**: Environment variables for all major server options
- **Graceful Shutdown**: Proper world saving on container stop

## Server Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU      | 2 cores | 4+ cores    |
| RAM      | 6GB     | 8GB+        |
| Storage  | 30GB    | 50GB        |

## How to use

Copy the .env.example file to a new file called .env and adjust the settings as needed.

### Docker compose

Starting the server with Docker Compose:

```bash
docker compose up -d
```

Stopping the server:

```bash
docker compose down
```

Viewing logs:

```bash
docker compose logs -f
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| PUID | - | **Required** User ID for file permissions |
| PGID | - | **Required** Group ID for file permissions |
| SESSION_NAME | ARK Server | The name of your server |
| SERVER_PASSWORD | (empty) | Password required to join (leave empty for no password) |
| ADMIN_PASSWORD | adminpass | Admin/RCON password |
| MAX_PLAYERS | 10 | Maximum number of players |
| WORLD | TheIsland | Map name (TheIsland, ScorchedEarth_P, TheCenter, Ragnarok, etc.) |
| SERVER_PORT | 7777 | Game port |
| QUERY_PORT | 27015 | Query port |
| RCON_PORT | 27020 | RCON port |
| SERVER_PVE | false | Enable PvE mode |
| BATTLEEYE | false | Enable BattlEye anti-cheat |
| DIFFICULTY_OFFSET | 0.2 | Difficulty offset (0.0-1.0) |
| OVERRIDE_OFFICIAL_DIFFICULTY | 5.0 | Override difficulty (affects max dino level) |
| MOD_IDS | (empty) | Comma-separated mod IDs (e.g., 731604991,893735676) |
| CLUSTER_ID | (empty) | Cluster ID for server clusters |
| CLUSTER_DIR_OVERRIDE | (empty) | Custom cluster directory path |
| ADDITIONAL_ARGS | (empty) | Additional command line arguments (e.g., -ServerHardcore -ForceAllowCaveFlyers) |
| BETA | public | Server branch (public, preaquatica, etc.) |
| UPDATE_ON_START | true | Update server on container start |

### Additional Arguments Examples

You can add any ARK server flags via `ADDITIONAL_ARGS`:

```bash
# Hardcore mode with cave flyers
ADDITIONAL_ARGS=-ServerHardcore -ForceAllowCaveFlyers

# PvE with no structure decay
ADDITIONAL_ARGS=-DisableStructureDecayPvE -AllowFlyerCarryPvE

# Disable crosshair and third person
ADDITIONAL_ARGS=-ServerCrosshair=false -ServerAllowThirdPersonPlayer=false
```

For a complete list of available flags, see the [ARK Server Configuration Wiki](https://ark.fandom.com/wiki/Server_configuration).

<details>
<summary>Common Additional Arguments</summary>

- `-ServerHardcore` - Enable hardcore mode
- `-ServerCrosshair` - Show crosshair
- `-ServerAllowThirdPersonPlayer` - Allow third person view
- `-ForceAllowCaveFlyers` - Allow flyers in caves
- `-DisableStructureDecayPvE` - Disable structure decay on PvE
- `-AllowFlyerCarryPvE` - Allow flyers to carry dinos in PvE
- `-DisableDinoDecayPvE` - Disable dino decay in PvE
- `-AllowCaveBuildingPvE` - Allow building in caves (PvE)
- `-AllowCaveBuildingPvP` - Allow building in caves (PvP)
- `-DisableFriendlyFire` - Disable friendly fire
- `-PreventOfflinePvP` - Prevent offline raiding
- `-GlobalVoiceChat` - Enable global voice chat
- `-ProximityChat` - Enable proximity voice chat
- `-NoTributeDownloads` - Disable tribute downloads
- `-preventdownloadsurvivors` - Prevent survivor downloads
- `-preventdownloaditems` - Prevent item downloads
- `-preventdownloaddinos` - Prevent dino downloads
- `-exclusivejoin` - Enable whitelist mode

</details>

## Ports

Make sure to forward these ports on your router:
- 7777/udp - Game port
- 27015/udp - Query port
- 27020/tcp - RCON port

## File Structure

```
steamcmd/                   (created on first run)
└── ark/
    └── ShooterGame/
        ├── Binaries/
        ├── Content/
        │   └── Mods/       # Installed mods
        ├── Saved/
        │   ├── Config/
        │   └── SavedArks/  # World saves
        └── steamapps/
```

## Using ARK Server Tools

This container uses [ARK Server Tools (arkmanager)](https://github.com/arkmanager/ark-server-tools) for server management. You can execute arkmanager commands directly:

```bash
# Check server status
docker exec -u steam ark-server arkmanager status

# Update server and mods
docker exec -u steam ark-server arkmanager update --update-mods

# Install a mod
docker exec -u steam ark-server arkmanager installmod 731604991

# Create a backup
docker exec -u steam ark-server arkmanager backup

# Broadcast a message
docker exec -u steam ark-server arkmanager broadcast "Server restart in 5 minutes"

# Execute RCON command
docker exec -u steam ark-server arkmanager rconcmd "ListPlayers"

# Save the world
docker exec -u steam ark-server arkmanager saveworld

# Stop the server gracefully
docker exec -u steam ark-server arkmanager stop --saveworld

# Restart the server
docker exec -u steam ark-server arkmanager restart --warn
```

**Note**: Always use `-u steam` flag to run commands as the steam user.

For more arkmanager commands, see the [ARK Server Tools documentation](https://github.com/arkmanager/ark-server-tools#usage).
