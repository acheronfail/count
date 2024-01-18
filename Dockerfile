FROM ubuntu:23.04

ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/London"

RUN apt-get update
RUN apt-get install -y bc build-essential curl gdb lldb git jq moreutils tar \
  unzip wget xz-utils                          && apt-get clean
RUN apt-get install -y clang                   && apt-get clean
RUN apt-get install -y default-jdk default-jre && apt-get clean
RUN apt-get install -y erlang                  && apt-get clean
RUN apt-get install -y fp-compiler             && apt-get clean
RUN apt-get install -y ghc                     && apt-get clean
RUN apt-get install -y gforth                  && apt-get clean
RUN apt-get install -y gfortran                && apt-get clean
RUN apt-get install -y gnu-smalltalk           && apt-get clean
RUN apt-get install -y gnucobol3               && apt-get clean
RUN apt-get install -y golang                  && apt-get clean
RUN apt-get install -y kotlin                  && apt-get clean
RUN apt-get install -y lua5.4                  && apt-get clean
RUN apt-get install -y mono-complete           && apt-get clean
RUN apt-get install -y nasm                    && apt-get clean
RUN apt-get install -y ocaml                   && apt-get clean
RUN apt-get install -y php                     && apt-get clean
RUN apt-get install -y ruby                    && apt-get clean
RUN apt-get install -y scala                   && apt-get clean
RUN apt-get install -y swi-prolog              && apt-get clean
RUN apt-get install -y tcl                     && apt-get clean
RUN apt-get install -y valac                   && apt-get clean

RUN curl -fSL https://deb.nodesource.com/setup_lts.x | bash - \
  && apt-get install -y nodejs && apt-get clean \
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

RUN cargo install max_rss --version 0.4.1

WORKDIR /var/count
