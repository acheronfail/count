FROM ubuntu:latest

ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/London"
RUN apt-get update && apt-get install -y \
  build-essential clang coffeescript curl default-jdk default-jre erlang \
  fp-compiler gdb lldb gforth gfortran gnu-smalltalk gnucobol3 golang \
  haskell-platform jq kotlin lua5.4 moreutils nasm nodejs npm php scala sudo \
  swi-prolog tar tcl unzip wget xz-utils \
  && apt-get clean
# FIXME: also install mono-complete, see: https://github.com/mono/mono/issues/21423

RUN useradd -m runner && echo "runner ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/runner
USER runner

RUN curl -fsSL https://sh.rustup.rs | RUSTUP_DEBUG=1 bash -s -- -v -y
ENV PATH="/home/runner/.cargo/bin:$PATH"

RUN curl -fsSL \
  https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh \
  | bash
RUN cargo install ripgrep --features pcre2
RUN cargo binstall --no-confirm hyperfine just timers juliaup

RUN juliaup add release

RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/home/runner/.bun/bin:$PATH"

RUN curl -fsSL https://deno.land/x/install/install.sh | bash
ENV PATH="/home/runner/.deno/bin:$PATH"

RUN curl -fsSL https://crystal-lang.org/install.sh | sudo bash

RUN curl -fsSL https://nim-lang.org/choosenim/init.sh | bash -s -- -y
ENV PATH="/home/runner/.nimble/bin:$PATH"

RUN sudo mkdir -p /opt/zig && cd $_ && \
  wget --quiet -O zig.tar.xz \
    $(curl -fsSL https://ziglang.org/download/index.json | jq -r '.[keys_unsorted[1]]["x86_64-linux"].tarball') && \
  tar -xvf zig.tar.xz --strip-components=1 2>&1 >/dev/null
ENV PATH="/opt/zig:$PATH"

WORKDIR /data
COPY --chown=runner:runner . .
RUN cd ./scripts && npm install

# TODO: when this docker image works, get CI to use it
