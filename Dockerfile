FROM ubuntu:23.04

ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/London"

RUN apt-get update && apt-get install -y \
  bc build-essential clang curl default-jdk default-jre erlang fp-compiler gdb \
  ghc lldb gforth gfortran git gnu-smalltalk gnucobol3 golang jq kotlin lua5.4 \
  mono-complete moreutils nasm php ruby scala swi-prolog tar tcl unzip wget \
  xz-utils \
  && apt-get clean
RUN curl -fSL https://deb.nodesource.com/setup_lts.x | bash - \
  && apt-get install -y nodejs \
  && npm install --global coffeescript

RUN curl -fSL https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:$PATH"

RUN curl -fSL \
  https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh \
  | bash
RUN cargo install ripgrep --features pcre2
RUN cargo binstall --no-confirm hyperfine just timers juliaup

RUN juliaup add release && juliaup config versionsdbupdateinterval 0

RUN curl -fSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

RUN curl -fSL https://deno.land/x/install/install.sh | sh
ENV PATH="/root/.deno/bin:$PATH"

RUN curl -fSL https://crystal-lang.org/install.sh | bash -s -- --version=1.11

RUN curl -fSL https://nim-lang.org/choosenim/init.sh | sh -s -- -y
ENV PATH="/root/.nimble/bin:$PATH"

RUN cd && curl -fSL "$(curl -fSL https://ziglang.org/download/index.json | jq -r '.[keys_unsorted[1]]["x86_64-linux"].tarball')" \
    > zig.tar.xz \
  && mkdir -p "/root/.zig" \
  && tar -xvf zig.tar.xz --strip-components=1 -C "/root/.zig" \
  && rm zig.tar.xz
ENV PATH="/root/.zig:$PATH"

RUN cargo install max_rss --version 0.3.3

WORKDIR /var/count
