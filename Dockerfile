FROM ubuntu:latest

ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/London"
RUN apt-get update && apt-get install -y \
  build-essential clang curl jq moreutils sudo tar unzip wget xz-utils

RUN useradd -m runner && echo "runner ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/runner
USER runner

RUN curl \
   -sSfL \
   --proto '=https' \
   --tlsv1.2 \
   https://sh.rustup.rs | sh -s -- --default-toolchain stable -y
ENV PATH="/home/runner/.cargo/bin:$PATH"
RUN curl \
  -sSfL \
  --proto '=https' \
  --tlsv1.2 \
   https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

RUN cargo install ripgrep --features pcre2
RUN cargo binstall --no-confirm hyperfine
RUN cargo binstall --no-confirm just
RUN cargo binstall --no-confirm timers

RUN cargo binstall --no-confirm juliaup && juliaup add release
RUN curl -fsSL https://bun.sh/install | bash
RUN curl -fsSL https://deno.land/x/install/install.sh | sh
RUN sudo -E apt-get install -y coffeescript
RUN sudo -E apt-get install -y erlang
RUN sudo -E apt-get install -y fp-compiler
RUN sudo -E apt-get install -y gforth
RUN sudo -E apt-get install -y gfortran
RUN sudo -E apt-get install -y gnu-smalltalk
RUN sudo -E apt-get install -y gnucobol3
RUN sudo -E apt-get install -y haskell-platform
RUN sudo -E apt-get install -y kotlin
RUN sudo -E apt-get install -y lua5.4
RUN sudo -E apt-get install -y nasm
RUN sudo -E apt-get install -y nodejs npm
RUN sudo -E apt-get install -y php
RUN sudo -E apt-get install -y scala
RUN sudo -E apt-get install -y swi-prolog
RUN sudo -E apt-get install -y tcl

RUN curl -fsSL https://crystal-lang.org/install.sh | sudo bash

RUN curl \
  -sSfL \
  --proto '=https' \
  --tlsv1.2 \
   https://nim-lang.org/choosenim/init.sh | sh -s -- -y
ENV PATH="/home/runner/.nimble/bin:$PATH"

RUN sudo mkdir -p /opt/zig && cd $_ && \
  wget \
    --quiet \
    -O zig.tar.xz \
    $(curl --silent https://ziglang.org/download/index.json | jq -r '.[keys_unsorted[1]]["x86_64-linux"].tarball') && \
  tar -xvf zig.tar.xz --strip-components=1 2>&1 >/dev/null
ENV PATH="/opt/zig:$PATH"

# FIXME: https://github.com/mono/mono/issues/21423
# installing gdb/lldb provide a better error message when mono-devel fails to install
# RUN sudo -E apt-get install -y gdb lldb
# RUN sudo -E apt-get install -y mono-complete

WORKDIR /data
COPY --chown=runner:runner . .
RUN cd ./scripts && npm install
ENV PATH="/home/runner/.bun/bin:$PATH"
ENV PATH="/home/runner/.deno/bin:$PATH"
RUN sudo -E apt-get install -y golang
RUN sudo -E apt-get install -y default-jdk default-jre

# TODO: when this docker image works, get CI to use it
