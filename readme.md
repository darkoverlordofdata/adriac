# adriac
Wrapper for valac performs out of tree build of vala
Additional pre and post processing steps:

* pre processing 
    Reference counting code is injected into vala classes
* post processing
    Forward references to injected code is added to resulting c code

# ZeroG


        __________                    ________ 
        \____    /___________  ____  /  _____/ 
          /     // __ \_  __ \/  _ \/   \  ___ 
         /     /\  ___/|  | \(  <_> )    \_\  \
        /_______ \___  >__|   \____/ \______  /
                \/   \/                     \/ 


    Lightweight replacement for GLib runtime for Vala

## install

cd ~/Applications
git clone https://github.com/darkoverlordofdata/zerog.git

update ./bashrc

    export SDL2SDK=$HOME/Applications/SDL2-2.0.5/

    export ZEROG=$HOME/Applications/zerog/

    export PATH=$PATH:$ZEROG/bin

    export CPATH=$ZEROG/include/


## use

    zerog init match3 com.darkoverlordofdata.match3

    cd match3

    autovala refresh
    autovala cmake
    cd install
    cmake ..
    make
    
    cd ..
    cake build:emscripten
    cake build:android
    cake build:desktop
    
## requirements

    valac
    sdl2
    autovala
    emscripten
    nodejs
    coffeescrpipt

## Dark Vala Manifesto


While working with ecere, I saw again that I prefer the MSDN style naming convention.
Moving back to Vala, I implement my code using that style. But it is jaring to see 
against the gnome snake case code - but that can fixed in the vapi.

Powered by ZeroG - runtime for vala without GObject

So, by design, this Dark Vala reinforces that it is a different vala:

* no PThread, GObject / GType / Gio, etc
* no snake-case natives, use msdn style
* simplified api for builtins: List, StringBuilder, etc.
* alternate oop strategies such as closures.


