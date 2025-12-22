FROM ubuntu:25.04

ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/London"

RUN apt-get update
RUN apt-get install -y autoconf automake bc bison build-essential curl flex \
gawk gdb git jq libffi-dev libsigsegv-dev libtool linux-perf lldb moreutils \
pkg-config tar texinfo unzip wget xz-utils zip && apt-get clean
RUN apt-get install -y clang                   && apt-get clean
RUN apt-get install -y default-jdk default-jre && apt-get clean
RUN apt-get install -y erlang                  && apt-get clean
RUN apt-get install -y fp-compiler             && apt-get clean
RUN apt-get install -y ghc                     && apt-get clean
RUN apt-get install -y gforth                  && apt-get clean
RUN apt-get install -y gfortran                && apt-get clean
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

# smalltalk no longer included in ubuntu repos
RUN git clone https://github.com/gnu-smalltalk/smalltalk.git /tmp/smalltalk \
  && cd /tmp/smalltalk \
  && autoreconf -vi \
  && ./configure CFLAGS="-O2 -g -std=gnu89" \
  && make \
  && make install \
  && rm -rf /tmp/smalltalk

RUN curl -fSL https://packages.microsoft.com/config/ubuntu/25.04/packages-microsoft-prod.deb > packages-microsoft-prod.deb \
  && dpkg -i packages-microsoft-prod.deb \
  && rm packages-microsoft-prod.deb \
  && apt-get update \
  && apt-get install -y dotnet-sdk-10.0 \
  && apt-get clean

RUN curl -fSL https://deb.nodesource.com/setup_lts.x | bash - \
  && apt-get install -y nodejs && apt-get clean \
  && npm install --global coffeescript

RUN curl -fSL https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:$PATH"

RUN curl -fSL \
  https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh \
  | bash
RUN cargo install ripgrep --features pcre2
RUN cargo binstall --no-confirm hyperfine just max_rss juliaup

RUN juliaup add release && juliaup config versionsdbupdateinterval 0

RUN curl -fSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

RUN curl -fSL https://deno.land/x/install/install.sh | sh
ENV PATH="/root/.deno/bin:$PATH"

RUN curl -fSL https://crystal-lang.org/install.sh | bash -s -- --version=1.11

RUN curl -fSL https://nim-lang.org/choosenim/init.sh | sh -s -- -y
ENV PATH="/root/.nimble/bin:$PATH"

COPY ./zig.sh ./zig.sh
RUN ./zig.sh
ENV PATH="/root/.zig:$PATH"

COPY ./swift.sh ./swift.sh
RUN ./swift.sh
ENV PATH="/root/.swift/usr/bin:$PATH"

ENV PATH="/root/.local/share/ponyup/bin:$PATH"
RUN (curl -fSL https://raw.githubusercontent.com/ponylang/ponyup/latest-release/ponyup-init.sh | sh) || true \
  && ponyup default x86_64-linux-ubuntu22.04 \
  && ponyup update ponyc release

WORKDIR /var/count
