_default:
  just -l

setup:
  #!/usr/bin/env bash
  set -euxo pipefail
  if [ ! -z "${CI:-}" ]; then
    sudo apt-get install build-essential cargo clang curl gfortran jq kotlin moreutils nodejs rustc scala
    cargo install timers
    cargo install hyperfine
    cargo install ripgrep --features 'pcre2'
  fi
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
    *"python"*|*"ruby"*)
      args="--runs 1"
      ;;
    *)
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

build-gcc:
  gcc -O3 ./count.c
  echo './a.out' > CMD

build-clang:
  clang -O3 ./count.c
  echo './a.out' > CMD

build-rust:
  rustc -C opt-level=3 ./count.rs
  echo './count' > CMD

build-fortran:
  gfortran -O3 ./count.f90
  echo './a.out' > CMD

build-java:
  javac count.java
  echo 'java count' > CMD

build-scala:
  scalac count.scala
  echo 'scala count' > CMD

build-kotlin:
  kotlinc count.kt -include-runtime -d count.jar
  echo 'java -jar count.jar' > CMD

build-ruby:
  echo 'ruby count.rb' > CMD

build-python3:
  echo 'python3 count.py' > CMD

build-node:
  echo 'node count.js' > CMD

build-deno:
  echo 'deno run count.js' > CMD

build-bun:
  echo 'bun run count.js' > CMD
