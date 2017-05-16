# vapis

the distributed package names, sdl2-modulename do not match the convention
expected by pkg-config use by cmake to build this project. These are the renamed versions.
Also, the references to SDL header files have been corrected for emscripten:

    //  [CCode (cheader_filename = "SDL2/SDL_ttf.h")]
    [CCode (cheader_filename = "SDL_ttf.h")]



Additionaly, the SDL2_mixer module was modified with access granted to Mix_PlayChannel so 
that game sound effects will work. It's just not working with emscripten yet.