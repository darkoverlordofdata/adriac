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


    Lightweight replacement Vala's runtime, GLib

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

## ZeroG and the Dark Vala

ZeroG is a lightweight replacement Vala's runtime, GLib.

Based on a posix profile approach, so GObject is replaced with reference
counted compact class. This limits the available oop semantics, and there are
some other limitations, so it's no longer fully compatible with standard vala.
I'm also updating the style.

* no PThread, GObject, Gio, etc
* no snake-case natives, use 'ToString'
* simplified api for builtins: List, StringBuilder, etc.
* favor composition over inheritane, 
* favor closures, delegates and functional code over 'classy' oop 

Implements:

* GList & GSList
* GHashTable
* GString
* GNode
* GQue

