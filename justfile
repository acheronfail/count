t := "timers --time=nano"
r := "results"
b := "build"

_default:
  just -l

prepare:
  rm -rf {{r}} {{b}}
  mkdir {{r}} {{b}}

node:
  {{t}} node ./count.js 2> {{r}}/node.yml
  {{t}} deno run --allow-all ./count.js 2> {{r}}/deno.yml
  {{t}} bun run ./count.js 2> {{r}}/bun.yml

python:
  {{t}} python3 ./count.py 2> {{r}}/python.yml

c:
  gcc -O3 ./count.c -o {{b}}/c-gcc
  {{t}} {{b}}/c-gcc 2> {{r}}/gcc.yml
  clang -O3 ./count.c -o {{b}}/c-clang
  {{t}} {{b}}/c-clang 2> {{r}}/clang.yml

rust:
  rustc -C opt-level=3 ./count.rs -o {{b}}/rust
  {{t}} {{b}}/rust 2> {{r}}/rust.yml

all: prepare node python c rust
  node ./scripts/summary.js