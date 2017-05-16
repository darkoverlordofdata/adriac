#!/usr/bin/env bash


./valac2/valac2  \
    --plugin ./valac2 \
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
    -X -Iinclude \
    -X -O2 \
    -o web/shmupwarz.html  \
    build/src/Factory.vala\
    build/src/Game.vala \
    build/src/components.gs \
    build/src/entitas/Cache.vala \
    build/src/entitas/Group.vala \
    build/src/entitas/Matcher.vala \
    build/src/entitas/World.vala \
    build/src/entitas/entitas.vala \
    build/src/main.vala \
    build/src/sdx/Color.gs \
    build/src/sdx/Files.vala \
    build/src/sdx/Font.vala \
    build/src/sdx/files/FileHandle.vala \
    build/src/sdx/graphics/Sprite.vala \
    build/src/sdx/graphics/Surface.vala \
    build/src/sdx/sdx.vala \
    build/src/systems/AnimationSystem.vala \
    build/src/systems/CollisionSystem.vala \
    build/src/systems/DisplaySystem.vala \
    build/src/systems/ExpireSystem.vala \
    build/src/systems/InputSystem.vala \
    build/src/systems/PhysicsSystem.vala \
    build/src/systems/RemoveSystem.vala \
    build/src/systems/ScoreSystem.vala \
    build/src/systems/SpawnSystem.vala \
    build/src/util/Cache.vala \
    build/src/util/File.vala \
    build/src/util/String.vala \
    build/src/vala-emscripten.vala


