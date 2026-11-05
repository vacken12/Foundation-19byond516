#!/bin/bash

./InstallDeps.sh

set -e
set -x

#load dep exports
#need to switch to game dir for Dockerfile weirdness
original_dir="$(pwd)"
cd "$1"

# Resolve the game/instance root that really contains maps/, data/, etc.
# $1 may be the game root itself or a subdirectory (e.g. Configuration/EventScripts).
# All map/vote paths below are resolved against this directory, not against $1.
GAME_DIR="$PWD"
while [[ "$GAME_DIR" != "/" && (! -d "$GAME_DIR/maps" || ! -f "$GAME_DIR/baystation12.dme") ]]; do
    GAME_DIR="$(dirname "$GAME_DIR")"
done
if [[ ! -d "$GAME_DIR/maps" || ! -f "$GAME_DIR/baystation12.dme" ]]; then
    echo "Warning: Could not auto-detect game root above $1; using $1 as game root" >&2
    GAME_DIR="$1"
fi

# --- Auto-select map from vote for _map_include.dm ---
# Moved here (before the rust-g/cargo build) so that data/changemaplog is
# always written, even if a later step aborts the script under `set -e`.
MAP_DATA_FILE="data/use_map"
MAP_DATA_PATH="$GAME_DIR/data/use_map"
MAP_INCLUDE="$GAME_DIR/maps/_map_include.dm"
DEFAULT_MAP="site53"
CHANGE_MAP_LOG="$GAME_DIR/data/changemaplog"
LAUNCH_DATA_PATH="$original_dir/data/use_map"

# Ensure data directory exists for logging
mkdir -p "$(dirname "$CHANGE_MAP_LOG")"

echo "PreCompile: game dir = $GAME_DIR"
echo "PreCompile: PWD after cd = $PWD"
echo "PreCompile: looking for vote file: $MAP_DATA_PATH (or $LAUNCH_DATA_PATH)"

MAP_NAME="$DEFAULT_MAP"
MAP_SOURCE="default"

# Try to find use_map in the game root first, then relative to the dir we launched from
if [[ -f "$MAP_DATA_PATH" ]]; then
    :
elif [[ -n "$original_dir" && -f "$LAUNCH_DATA_PATH" ]]; then
    MAP_DATA_PATH="$LAUNCH_DATA_PATH"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - No change: $MAP_DATA_FILE not found in $GAME_DIR or $original_dir, keeping default $DEFAULT_MAP" >> "$CHANGE_MAP_LOG"
    MAP_NAME="$DEFAULT_MAP"
fi

if [[ -f "$MAP_DATA_PATH" ]]; then
    MAP_TYPE="$(cat "$MAP_DATA_PATH" | tr -d '[:space:]')"
    echo "PreCompile: read vote file '$MAP_DATA_PATH' = '$MAP_TYPE'"
    if [[ -n "$MAP_TYPE" && "$MAP_TYPE" == /datum/map/* ]]; then
        # Extract name of map like /datum/map/site47 -> site47
        MAP_NAME="${MAP_TYPE##*/}"
        MAP_SOURCE="vote"
    elif [[ -n "$MAP_TYPE" ]]; then
        # Allow raw map name like "site53" without /datum/map/ prefix
        MAP_NAME="$MAP_TYPE"
        MAP_SOURCE="vote"
    else
        echo "Warning: Invalid map type in $MAP_DATA_PATH: '$MAP_TYPE', using default $DEFAULT_MAP"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - No change: invalid vote '$MAP_TYPE' in $MAP_DATA_PATH, keeping default $DEFAULT_MAP" >> "$CHANGE_MAP_LOG"
        MAP_NAME="$DEFAULT_MAP"
    fi
fi

MAP_DM="$GAME_DIR/maps/${MAP_NAME}/${MAP_NAME}.dm"
echo "PreCompile: checking map file: $MAP_DM"
if [[ ! -f "$MAP_DM" ]]; then
    echo "Warning: Map '$MAP_NAME' ($MAP_DM) not found. GAME_DIR=$GAME_DIR, PWD=$PWD, falling back to $DEFAULT_MAP"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Change failed: map '$MAP_NAME' not found at $MAP_DM (GAME_DIR=$GAME_DIR, PWD=$PWD), falling back to $DEFAULT_MAP" >> "$CHANGE_MAP_LOG"
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

echo "PreCompile: selected map = $MAP_NAME (source: $MAP_SOURCE)"
printf '#include "%s/%s.dm"\n' "$MAP_NAME" "$MAP_NAME" > "$MAP_INCLUDE"
echo "PreCompile: wrote $MAP_INCLUDE"

. dependencies.sh
cd "$original_dir"


# update rust-g
if [ ! -d "rust-g" ]; then
	echo "Cloning rust-g..."
	git clone https://github.com/tgstation/rust-g
	cd rust-g
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
else
	echo "Fetching rust-g..."
	cd rust-g
	git fetch
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
fi

echo "Deploying rust-g..."
git checkout "$RUST_G_VERSION"
env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --ignore-rust-version --release --target=i686-unknown-linux-gnu
mv target/i686-unknown-linux-gnu/release/librust_g.so "$1/librust_g.so"
cd ..

# compile tgui
echo "Compiling tgui..."
cd "$1"

env TG_BOOTSTRAP_CACHE="$original_dir" TG_BOOTSTRAP_NODE_LINUX=1 CBT_BUILD_MODE="TGS" tools/bootstrap/node tools/build/build.js
