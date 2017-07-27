# ZeroG


        __________                    ________ 
        \____    /___________  ____  /  _____/ 
          /     // __ \_  __ \/  _ \/   \  ___ 
         /     /\  ___/|  | \(  <_> )    \_\  \
        /_______ \___  >__|   \____/ \______  /
                \/   \/                     \/ 


    Lightweight replacement for Vala runtime GLib

# adriac

    "A spoiled brat with a God complex."
                        Vala Mal Doran 

Adriac is a Wrapper for valac, it performs an out of tree build using ZeroG
Additional pre and post processing steps:

* pre processing 
    Reference counting code is injected into vala classes
* post processing
    Forward references to injected code is added to resulting c code

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
    coffeescript

## ZeroG and the Dark Vala

ZeroG is a lightweight replacement for Vala runtime GLib.
This supports a subset of Vala.

Code is based on portions of the original GLib, but only includes parts required for vala, plus some data strutures. These are ported to static inline code for inclusion as *.h header files.

GObject is replaced with reference counted compact class. This limits the available oop semantics, and Genie is not fully supported.

Implements:

* GList & GSList
* GHashTable
* GString
* GArray
* GNode
* GQue

Dark Vala style guide:
[Based on](https://docs.microsoft.com/en-us/dotnet/standard/design-guidelines/capitalization-conventions)

* Do use casing instead of underscores.
* Do use Pascal casing for all public member, type, and namespace names.
* Do use camel casing for parameter, field and variable names.
* Do use UPPER_CASE for constants.

I prefer this for readabliity, and it ensures this code will not be mistaken for standard vala.


## License
Various licences apply. 

The ZeroG library and Adriac: GPL2

Dark Vala preprocesors: Apache2.

Application libraries:
* entitas - MIT
* sdx - Apache2
* mt19937 - see code 