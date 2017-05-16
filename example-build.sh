#!/usr/bin/env bash
#    -X "-s ALLOW_MEMORY_GROWTH=1" \


valac2  \
    --builddir build \
    --cc=emcc \
    --define PROFILING \
    --vapidir src/vapis \
    --pkg sdl2 \
    --pkg SDL2_image \
    --pkg SDL2_ttf \
    --pkg posix \
    --pkg mt19937ar \
    --pkg emscripten \
    -X -O2 \
    -o web/platformer.html  \
    build/src/Components.gs \
    build/src/Entities.gs \
    build/src/Game.gs \
    build/src/Main.gs \
    build/src/Map.gs \
    build/src/Systems.gs \
    build/src/TextCache.gs \
    build/src/platformer.vala


