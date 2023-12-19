i := '1000000000'

_default:
  just -l

@_check +CMDS:
    echo {{CMDS}} | xargs -n1 sh -c 'if ! command -v $1 >/dev/null 2>&1 /dev/null; then echo "$1 is required!"; exit 1; fi' bash

setup: (_check "npm")
  cd scripts && npm install

build what:
  just build-{{what}}

run what:
  just build {{what}}
  @$(cat CMD)

measure what:
  #!/usr/bin/env bash
  set -euxo pipefail

  just build {{what}}

  case "{{what}}" in
    ( *"python"* | *"ruby"* | *"perl"* | *"haskell"* | *"php"* )
      args="--runs 1"
      ;;
    (*)
      args="--warmup 3"
      ;;
  esac

  out="{{what}}.json"

  hyperfine $args --shell=none --export-json "$out" "$(cat CMD)"
  jq '.results[0] | del(.exit_codes)' "$out" | sponge "$out"
  timers $(cat CMD) >/dev/null 2> >(jq '. += {"max_rss":'$(rg -oP '(?:max_rss:\s*)(\d+)' -r '$1')'}' "$out" | sponge "$out")

summary results:
  cd scripts && node ./summary.js --results ..

# languages

build-gcc: (_check "gcc")
  gcc -O3 ./count.c
  echo './a.out {{i}}' > CMD

build-clang: (_check "clang")
  clang -O3 ./count.c
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

build-assembly: (_check "nasm")
  nasm -f elf64 count.asm
  ld count.o -o count -lc -I/lib64/ld-linux-x86-64.so.2
  echo './count {{i}}' > CMD
