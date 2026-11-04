#!/bin/bash

# Special file to ensure all dependencies still exist between server launches.
# Mainly for use by people who abuse docker by modifying the container's system.


# --- Auto-select map from vote for _map_include.dm ---
MAP_DATA_FILE="data/use_map"
MAP_INCLUDE="maps/_map_include.dm"
DEFAULT_MAP="site53"
CHANGE_MAP_LOG="data/changemaplog"

# Ensure data directory exists for logging
mkdir -p "$(dirname "$CHANGE_MAP_LOG")"

MAP_NAME="$DEFAULT_MAP"
MAP_SOURCE="default"

if [[ -f "$MAP_DATA_FILE" ]]; then
    MAP_TYPE="$(cat "$MAP_DATA_FILE" | tr -d '[:space:]')"
    if [[ -n "$MAP_TYPE" && "$MAP_TYPE" == /datum/map/* ]]; then
        # Extract name of map like /datum/map/site47 -> site47
        MAP_NAME="${MAP_TYPE##*/}"
        MAP_SOURCE="vote"
    else
        echo "Warning: Invalid map type in $MAP_DATA_FILE: '$MAP_TYPE', using default $DEFAULT_MAP"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - No change: invalid vote '$MAP_TYPE' in $MAP_DATA_FILE, keeping default $DEFAULT_MAP" >> "$CHANGE_MAP_LOG"
        MAP_NAME="$DEFAULT_MAP"
    fi
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - No change: $MAP_DATA_FILE not found, keeping default $DEFAULT_MAP" >> "$CHANGE_MAP_LOG"
fi

MAP_DM="maps/${MAP_NAME}/${MAP_NAME}.dm"
if [[ ! -f "$MAP_DM" ]]; then
    echo "Warning: Map '$MAP_NAME' ($MAP_DM) not found, falling back to $DEFAULT_MAP"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Change failed: map '$MAP_NAME' not found at $MAP_DM, falling back to $DEFAULT_MAP" >> "$CHANGE_MAP_LOG"
    MAP_NAME="$DEFAULT_MAP"
    MAP_SOURCE="fallback"
fi

# Log the final map selection
if [[ "$MAP_SOURCE" == "vote" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Map changed to: $MAP_NAME (voted: $MAP_TYPE)" >> "$CHANGE_MAP_LOG"
elif [[ "$MAP_SOURCE" == "fallback" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Using fallback map: $MAP_NAME" >> "$CHANGE_MAP_LOG"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Using default map: $MAP_NAME" >> "$CHANGE_MAP_LOG"
fi

echo "PreCompile: selected map = $MAP_NAME"
printf '#include "maps\\%s\\%s.dm"\n' "$MAP_NAME" "$MAP_NAME" > "$MAP_INCLUDE"


./InstallDeps.sh
