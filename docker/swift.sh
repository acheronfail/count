#!/usr/bin/env bash

# https://www.swift.org/install/linux/#installation-via-tarball

set -euxo pipefail
cd "$HOME"

install_dir="$HOME/.swift"


tarball_url="https://download.swift.org/swift-6.2.3-release/ubuntu2404/swift-6.2.3-RELEASE/swift-6.2.3-RELEASE-ubuntu24.04.tar.gz"
tarball_sig_url="${tarball_url}.sig"

tarball="swift.tar.gz"
tarball_sig="swift.tar.gz.sig"

wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import -

curl -fSL "$tarball_url" > "$tarball"
curl -fSL "$tarball_sig_url" > "$tarball_sig"
gpg --verify "$tarball_sig"

mkdir -p "$install_dir"
tar -xvf "$tarball" --strip-components=1 -C "$install_dir"
rm "$tarball"
