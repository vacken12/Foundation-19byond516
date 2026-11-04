#!/bin/bash

./InstallDeps.sh

set -e
set -x

#load dep exports
#need to switch to game dir for Dockerfile weirdness
original_dir=$PWD
cd "$1"
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

env TG_BOOTSTRAP_CACHE="$original_dir" TG_BOOTSTRAP_NODE_LINUX=1 CBT_BUILD_MODE="TGS" tools/bootstrap/node tools/build/build.js
