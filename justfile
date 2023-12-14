t := "timers --time=nano"
r := "results"
b := "build"

_default:
  just -l

setup:
  #!/usr/bin/env bash
  set -euxo pipefail
  if [ ! -z "${CI:-}" ]; then
    sudo apt-get install build-essential cargo clang curl jq moreutils nodejs rustc
    cargo install timers
    cargo install hyperfine
    cargo install ripgrep --features 'pcre2'
  fi
  cd scripts && npm install

prepare:
  rm -rf {{r}} {{b}}
  mkdir {{r}} {{b}}

build: prepare
  gcc   -O3 ./count.c -o {{b}}/c-gcc
  clang -O3 ./count.c -o {{b}}/c-clang
  rustc -C opt-level=3 ./count.rs -o {{b}}/rust
  javac count.java
  echo "#!/usr/bin/env -S java count" > {{b}}/java
  echo "#!/usr/bin/env -S ruby     \n$(cat count.rb)" > {{b}}/ruby
  echo "#!/usr/bin/env -S python3  \n$(cat count.py)" > {{b}}/python3
  echo "#!/usr/bin/env -S node     \n$(cat count.js)" > {{b}}/node
  echo "#!/usr/bin/env -S deno run \n$(cat count.js)" > {{b}}/deno
  echo "#!/usr/bin/env -S bun      \n$(cat count.js)" > {{b}}/bun
  for f in {{b}}/*; do chmod +x "$f"; done

run: build
  #!/usr/bin/env bash
  set -euxo pipefail
  for f in {{b}}/*; do
    sleep 5

    name="$(basename $f)"
    out="{{r}}/${name}.json"

    case "$name" in
      *"python"*|*"ruby"*)
        args="--runs 2"
        ;;
      *)
      args="--warmup 3"
      ;;
    esac
    hyperfine $args --shell=none --export-json "$out" "$f"

    jq '.results[0] | del(.exit_codes)' "$out" | sponge "$out"
    timers "$f" >/dev/null 2> >(jq '. += {"max_rss":'$(rg -oP '(?:max_rss:\s*)(\d+)' -r '$1')'}' "$out" | sponge "$out")
  done

count: run
  node ./scripts/summary.js > {{r}}/table.txt
  cat {{r}}/table.txt