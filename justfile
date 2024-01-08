i := '1000000000'

_default:
  just -l

@_check +CMDS:
    echo {{CMDS}} | xargs -n1 sh -c 'if ! command -v $1 >/dev/null 2>&1 /dev/null; then echo "$1 is required!"; exit 1; fi' bash

setup: (_check "npm")
  cd scripts && npm install

build-docker:
  docker build --platform 'linux/amd64' -t count .

# just checks if mono can be installed in docker, since there's an issue with it
# currently preventing us from shipping this docker image properly
# see: https://github.com/mono/mono/issues/21423
check-docker:
  docker run --rm -ti --platform 'linux/amd64' ubuntu \
    sh -c 'apt update && DEBIAN_FRONTEND=noninteractive TZ="Europe/London" apt install -y mono-complete'

build what:
  just build-{{what}}

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

  out="{{what}}.json"

  hyperfine $args --shell=none --export-json "$out" "$(cat CMD)"
  jq '.results[0] | del(.exit_codes)' "$out" | sponge "$out"
  timers $(cat CMD) >/dev/null 2> >(jq '. += {"max_rss":'$(rg -oP '(?:max_rss:\s*)(\d+)' -r '$1')'}' "$out" | sponge "$out")

summary results:
  cd scripts && node ./summary.js --results ..

test what:
  #!/usr/bin/env bash
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

# languages

build-c-gcc: (_check "gcc")
  gcc -O3 ./count.c
  echo './a.out {{i}}' > CMD

build-c-clang: (_check "clang")
  clang -O3 ./count.c
  echo './a.out {{i}}' > CMD

build-cpp-gcc: (_check "g++")
  g++ -O3 ./count.cpp
  echo './a.out {{i}}' > CMD

build-cpp-clang: (_check "clang++")
  clang++ -O3 ./count.cpp
  echo './a.out {{i}}' > CMD

build-rust: (_check "rustc")
  rustc -C opt-level=3 ./count.rs
  echo './count {{i}}' > CMD

build-fortran: (_check "gfortran")
  gfortran -O3 ./count.f90
  echo './a.out {{i}}' > CMD

build-java: (_check "javac java")
  javac count.java
  echo 'java count {{i}}' > CMD

build-scala: (_check "scalac scala")
  scalac count.scala
  echo 'scala count {{i}}' > CMD

build-kotlin: (_check "kotlinc java")
  kotlinc count.kt -include-runtime -d count.jar
  echo 'java -jar count.jar {{i}}' > CMD

build-ruby: (_check "ruby")
  echo 'ruby count.rb {{i}}' > CMD

build-python3: (_check "python3")
  echo 'python3 count.py {{i}}' > CMD

build-node: (_check "node")
  echo 'node count.js {{i}}' > CMD

build-deno: (_check "deno")
  echo 'deno run count.deno {{i}}' > CMD

build-bun: (_check "bun")
  echo 'bun run count.js {{i}}' > CMD

build-zig: (_check "zig")
  zig build-exe -O ReleaseFast ./count.zig
  echo './count {{i}}' > CMD

build-perl: (_check "perl")
  echo 'perl ./count.pl {{i}}' > CMD

build-haskell: (_check "ghc")
  ghc count.hs
  echo './count {{i}}' > CMD

build-go: (_check "go")
  go build -o count count.go
  echo './count {{i}}' > CMD

build-php: (_check "php")
  echo 'php ./count.php {{i}}' > CMD

build-erlang: (_check "erlc erl")
  erlc count.erl
  echo 'erl -noshell -s count start {{i}}' > CMD

build-crystal: (_check "crystal")
  echo 'crystal run ./count.cr -- {{i}}' > CMD

build-assembly: (_check "nasm ld")
  nasm -f elf64 count.asm
  ld count.o -o count -lc -I/lib64/ld-linux-x86-64.so.2
  echo './count {{i}}' > CMD

build-cobol: (_check "cobc")
  cobc -O3 -free -x -o count count.cbl
  echo './count {{i}}' > CMD

build-julia: (_check "julia")
  echo 'julia ./count.jl {{i}}' > CMD

build-coffeescript: (_check "coffee")
  echo 'coffee ./count.coffee {{i}}' > CMD

build-nim: (_check "nim")
  nim compile --opt:speed ./count.nim
  echo './count {{i}}' > CMD

build-prolog: (_check "swipl")
  swipl -s count.pro -g "main" -t halt -- 1
  echo './count {{i}}' > CMD

build-smalltalk: (_check "gst")
  echo 'gst -f count.st {{i}}' > CMD

build-tcl: (_check "tclsh")
  echo 'tclsh ./count.tcl {{i}}' > CMD

build-pascal: (_check "fpc")
  fpc -O3 ./count.pas
  echo './count {{i}}' > CMD

build-lua: (_check "lua")
  echo 'lua ./count.lua {{i}}' > CMD

build-forth: (_check "gforth")
  echo 'gforth ./count.fth {{i}}' > CMD

build-csharp: (_check "mcs mono")
  mcs -o+ ./count.cs
  echo 'mono ./count.exe {{i}}' > CMD
