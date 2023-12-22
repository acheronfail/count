# install dependencies
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y build-essential cargo clang coffeescript curl erlang gfortran \
                        gnucobol4 gnu-smalltalk haskell-platform jq kotlin moreutils nasm \
                        nodejs php rustc scala swi-prolog tar tcl wget xz-utils

# required tools for running our benchmarks
cargo install timers
cargo install hyperfine
cargo install ripgrep --features 'pcre2'

# julia
cargo install juliaup
juliaup add release

# nim
wget -qO choosenim.sh https://nim-lang.org/choosenim/init.sh
bash ./choosenim.sh -y
echo "$HOME/.nimble/bin" >> ${GITHUB_PATH:-/dev/null}
export PATH="$HOME/.nimble/bin:$PATH"

# crystal
curl -fsSL https://crystal-lang.org/install.sh | sudo bash

# zig
mkdir -p /opt/zig && cd $_
wget --quiet -O zig.tar.xz $(curl --silent https://ziglang.org/download/index.json | jq -r '.[keys_unsorted[1]]["x86_64-linux"].tarball')
tar -xvf zig.tar.xz 2>&1 >/dev/null
zig_path="$PWD/$(tar -tf zig.tar.xz | head -n1)"
echo "$zig_path" >> ${GITHUB_PATH:-/dev/null}
export PATH="$PATH:$zig_path"
cd -
