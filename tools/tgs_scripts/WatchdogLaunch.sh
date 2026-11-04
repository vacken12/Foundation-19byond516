#!/bin/bash

# Special file to ensure all dependencies still exist between server launches.
# Mainly for use by people who abuse docker by modifying the container's system.


# --- Auto-select map from vote for _map_include.dm ---
MAP_DATA_FILE="data/use_map"
MAP_INCLUDE="maps/_map_include.dm"
DEFAULT_MAP="site53"

MAP_NAME="$DEFAULT_MAP"

if [[ -f "$MAP_DATA_FILE" ]]; then
    MAP_TYPE="$(cat "$MAP_DATA_FILE" | tr -d '[:space:]')"
    if [[ -n "$MAP_TYPE" && "$MAP_TYPE" == /datum/map/* ]]; then
        # Extract name of map like /datum/map/site47 -> site47
        MAP_NAME="${MAP_TYPE##*/}"
    fi
fi

MAP_DM="maps/${MAP_NAME}/${MAP_NAME}.dm"
if [[ ! -f "$MAP_DM" ]]; then
    echo "Warning: Map '$MAP_NAME' ($MAP_DM) not found, falling back to $DEFAULT_MAP"
    MAP_NAME="$DEFAULT_MAP"
fi

echo "PreCompile: selected map = $MAP_NAME"
printf '#include "maps\\%s\\%s.dm"\n' "$MAP_NAME" "$MAP_NAME" > "$MAP_INCLUDE"


./InstallDeps.sh
