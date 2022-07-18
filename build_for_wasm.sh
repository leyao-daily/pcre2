#!/bin/bash

set -euo pipefail

target=$1

if [ -z "$target" ]; then
  echo "You must specify a target (wasm32-wasi or wasm32-emscripten)"
  exit 1
fi

CONFIGURE="./configure"
MAKE="make"

if [ "$target" == "wasm32-emscripten" ]; then
  CONFIGURE="emconfigure $CONFIGURE"
  MAKE="emmake $MAKE"
fi

if [ "$target" == "wasm32-wasi" ]; then
  export CC="$WASI_SDK_PATH/bin/clang --sysroot=$WASI_SDK_PATH/share/wasi-sysroot"
  export AR="$WASI_SDK_PATH/bin/llvm-ar"
  export RANLIB="$WASI_SDK_PATH/bin/llvm-ranlib"
  export LD="$WASI_SDK_PATH/bin/wasm-ld"
fi

$CONFIGURE --host wasm32 \
  --disable-dependency-tracking \
  --enable-utf8 \
  --enable-pcre2-8 \
  --enable-pcre2-16 \
  --enable-pcre2-32 \
  --enable-unicode-properties \
  --disable-shared \
  --disable-cpp

$MAKE

mkdir -p "targets/$target"
cp .libs/*.a "targets/$target/"

echo "Finished compiling libpcre for $target. Output in targets/$target"
