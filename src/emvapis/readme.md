# vapis

the distributed package names, sdl2-modulename do not match the convention
expected by pkg-config use by cmake to build this project. These are the renamed versions.

Additionaly, the SDL2_mixer module was modified with access granted to Mix_PlayChannel so 
that game sound effects will work.