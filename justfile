i := '1000000000'
tag := 'acheronfail/count'
mount := '/var/count'

_default:
  just -l

@_check +CMDS:
    echo {{CMDS}} | xargs -n1 sh -c 'if ! command -v $1 >/dev/null 2>&1 /dev/null; then echo "$1 is required!"; exit 1; fi' bash

setup: (_check "npm")
  cd scripts && npm install

docker-sh:
  docker run --rm -ti --platform 'linux/amd64' -v "$PWD:{{mount}}" {{tag}}

# NOTE: there are issues if you try to build this on an arm macbook via rosetta emulation
# - mono fails to install (https://github.com/mono/mono/issues/21423)
# - getting erlang version segfaults
docker-build:
  docker build --progress=plain --platform 'linux/amd64' -t {{tag}} .

docker-pull:
  docker pull {{tag}}

docker-push: docker-build
  docker push {{tag}}

docker-measure what:
  docker run --rm -ti --platform 'linux/amd64' -v "$PWD:{{mount}}" {{tag}} just measure {{what}}

docker-measure-all:
  docker run --rm -ti --platform 'linux/amd64' -v "$PWD:{{mount}}" {{tag}} just measure-all

_all:
  just -l | grep -v 'build-all' | grep 'build-' | cut -d'-' -f2- | xargs

build what:
  rm -f CMD VERSION STATS SIZE
  just build-{{what}}

build-all:
  #!/usr/bin/env bash
  set -euxo pipefail

  failed=()
  for lang in $(just _all); do
    if ! just build "$lang"; then
      failed+=("$lang")
    fi
  done

  echo "${failed[@]}"

run what:
  just build {{what}}
  @$(cat CMD)

measure what:
  #!/usr/bin/env bash
  set -euxo pipefail
  just build {{what}}
  slow_langs=(
    cobol
    haskell
    julia
    perl
    php
    prolog
    python
    ruby
    smalltalk
    tcl
  )

  args="--warmup 3"
  for language in "${slow_langs[@]}"; do
      if [[ "{{what}}" == *"$language"* ]]; then
          args="--runs 1"
          break
      fi
  done

  mkdir -p results
  out="results/{{what}}.json"

  hyperfine $args --shell=none --export-json "$out" "$(cat CMD)"
  jq '.results[0] | del(.exit_codes)' "$out" | sponge "$out"
  jq '. += {"name":"{{what}}","version":"'"$(cat VERSION)"'"}' "$out" | sponge "$out"
  if [[ -f SIZE ]]; then
    jq '. += {"size":"'"$(cat SIZE)"'"}' "$out" | sponge "$out"
  fi
  timers $(cat CMD) >/dev/null 2> STATS
  jq '. += {"max_rss":'$(rg -oP '(?:max_rss:\s*)(\d+)' -r '$1' ./STATS)'}' "$out" | sponge "$out"

measure-all:
  #!/usr/bin/env bash
  set -exuo pipefail

  for lang in $(just _all); do
    just test "$lang";
    just measure "$lang";
  done

  cd scripts && npm start

summary:
  cd scripts && npm start -- --results ../results
  cat scripts/summary.md

test what:
  #!/usr/bin/env bash
  set -euo pipefail
  just build {{what}}
  tests=(
    1          1
    10         11
    100        101
    1000       1001
    10000      10001
    100000     100001
    1000000    1000001
    10000000   10000001
    100000000  100000001
    1000000000 1000000001
  )

  for ((i=0;i< ${#tests[@]} ;i+=2)); do
    input="${tests[i]}"
    expect="${tests[i+1]}"
    cmd="$(cat CMD)"
    cmd="${cmd/{{i}}/"$input"}"
    echo -n "test: '"$cmd"'"
    actual="$($cmd 2>&1 | grep -v '^%' | xargs)"
    if [[ "$actual" != "$expect" ]]; then
      echo " (fail)"
      echo "fail, sent '${input}' and expected '${expect}' but got '${actual}'"
      echo "command was: $cmd"
      exit 1
    else
      echo " (ok)"
    fi
  done

test-all:
  #!/usr/bin/env bash
  set -euxo pipefail

  for lang in $(just _all); do
    just test "$lang";
  done

# total byte size of all passed files
_size +files: (_check "paste" "bc" "stat")
  stat -c '%s' {{files}} | paste -sd+ | bc > SIZE
# define size type (used in summary)
_sizet type:
  echo -n {{type}} >> SIZE

# languages

build-c-gcc: (_check "gcc") && (_size "./count")
  gcc --version | head -1 > VERSION
  gcc -O3 -o count ./count.c
  echo './count {{i}}' > CMD

build-c-clang: (_check "clang") && (_size "./count")
  clang --version | head -1 > VERSION
  clang -O3 -o count ./count.c
  echo './count {{i}}' > CMD

build-cpp-gcc: (_check "g++") && (_size "./count")
  g++ --version | head -1 > VERSION
  g++ -O3 -o count ./count.cpp
  echo './count {{i}}' > CMD

build-cpp-clang: (_check "clang++") && (_size "./count")
  clang++ --version | head -1 > VERSION
  clang++ -O3 -o count ./count.cpp
  echo './count {{i}}' > CMD

build-rust: (_check "rustc") && (_size "./count")
  rustc --version > VERSION
  rustc -C opt-level=3 ./count.rs
  echo './count {{i}}' > CMD

build-fortran: (_check "gfortran") && (_size "./count")
  gfortran --version | head -1 > VERSION
  gfortran -O3 -o count ./count.f90
  echo './count {{i}}' > CMD

build-java: (_check "javac java") && (_size "./count.java") (_sizet "bytecode")
  javac --version > VERSION
  java --version | head -1 >> VERSION
  javac count.java
  echo 'java count {{i}}' > CMD

build-scala: (_check "scalac scala") && (_size "count.class" "count$.class" "count.tasty") (_sizet "bytecode")
  scalac -version > VERSION 2>&1
  scala -version >> VERSION 2>&1
  scalac count.scala
  echo 'scala count {{i}}' > CMD

build-kotlin: (_check "kotlinc java") && (_size "count.jar") (_sizet "bytecode")
  kotlinc -version > VERSION 2>&1
  java --version | head -1 >> VERSION
  kotlinc count.kt -include-runtime -d count.jar
  echo 'java -jar count.jar {{i}}' > CMD

build-ruby: (_check "ruby")
  ruby --version > VERSION
  echo 'ruby count.rb {{i}}' > CMD

build-python3: (_check "python3")
  python3 --version > VERSION
  echo 'python3 count.py {{i}}' > CMD

build-node: (_check "node")
  node --version > VERSION
  echo 'node count.js {{i}}' > CMD

build-deno: (_check "deno")
  deno --version | xargs > VERSION
  echo 'deno run count.deno {{i}}' > CMD

build-bun: (_check "bun")
  bun --version > VERSION
  echo 'bun run count.js {{i}}' > CMD

build-zig: (_check "zig") && (_size "count")
  zig version > VERSION
  zig build-exe -O ReleaseFast ./count.zig
  echo './count {{i}}' > CMD

build-perl: (_check "perl")
  perl --version | grep version > VERSION
  echo 'perl ./count.pl {{i}}' > CMD

build-haskell: (_check "ghc") && (_size "count")
  ghc --version > VERSION
  ghc count.hs
  echo './count {{i}}' > CMD

build-go: (_check "go") && (_size "count")
  go version > VERSION
  go build -o count count.go
  echo './count {{i}}' > CMD

build-php: (_check "php")
  php --version | head -1 > VERSION
  echo 'php ./count.php {{i}}' > CMD

build-erlang: (_check "erlc erl") && (_size "count.beam") (_sizet "bytecode")
  erl -eval '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version), halt().' -noshell > VERSION
  erlc count.erl
  echo 'erl -noshell -s count start {{i}}' > CMD

build-crystal: (_check "crystal")
  crystal version | xargs > VERSION
  echo 'crystal run ./count.cr -- {{i}}' > CMD

build-assembly: (_check "nasm") && (_size "count")
  nasm --version > VERSION
  nasm -f bin -o count ./count.asm
  chmod +x ./count
  echo './count {{i}}' > CMD

build-cobol: (_check "cobc") && (_size "count")
  cobc --version | head -1 > VERSION
  cobc -O3 -free -x -o count count.cbl
  echo './count {{i}}' > CMD

build-julia: (_check "julia")
  julia --version > VERSION
  echo 'julia ./count.jl {{i}}' > CMD

build-coffeescript: (_check "coffee")
  coffee --version > VERSION
  echo 'coffee ./count.coffee {{i}}' > CMD

build-nim: (_check "nim") && (_size "count")
  nim --version | head -1 > VERSION
  nim compile --opt:speed ./count.nim
  echo './count {{i}}' > CMD

build-prolog: (_check "swipl") && (_size "count")
  swipl --version > VERSION
  swipl -s count.pro -g "main" -t halt -- 1
  echo './count {{i}}' > CMD

build-smalltalk: (_check "gst")
  gst --version | head -1 > VERSION
  echo 'gst -f count.st {{i}}' > CMD

build-tcl: (_check "tclsh")
  echo 'puts $tcl_version;exit 0' | tclsh > VERSION
  echo 'tclsh ./count.tcl {{i}}' > CMD

build-pascal: (_check "fpc") && (_size "count")
  fpc -iW > VERSION
  fpc -O3 ./count.pas
  echo './count {{i}}' > CMD

build-lua: (_check "lua")
  lua -v > VERSION
  echo 'lua ./count.lua {{i}}' > CMD

build-forth: (_check "gforth")
  gforth --version > VERSION 2>&1
  echo 'gforth ./count.fth {{i}}' > CMD

build-csharp: (_check "mcs mono") && (_size "count.exe") (_sizet "bytecode")
  mcs --version > VERSION
  mono --version | head -1 >> VERSION
  mcs -o+ ./count.cs
  echo 'mono ./count.exe {{i}}' > CMD
