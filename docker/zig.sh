#!/usr/bin/env bash

set -euxo pipefail
cd "$HOME"

install_dir="$HOME/.zig"
jq_path='.[keys_unsorted[1]]["x86_64-linux"].tarball'
tarball_url=$(curl -fSL https://ziglang.org/download/index.json | jq -r "$jq_path")
tarball="zig.tar.xz"

curl -fSL "$tarball_url" > $tarball
mkdir -p "$install_dir"

tar -xvf $tarball --strip-components=1 -C "$install_dir"
rm $tarball
