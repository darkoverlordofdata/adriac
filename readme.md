# ZeroG-SDK


        __________                    ________ 
        \____    /___________  ____  /  _____/ 
          /     // __ \_  __ \/  _ \/   \  ___ 
         /     /\  ___/|  | \(  <_> )    \_\  \
        /_______ \___  >__|   \____/ \______  /
                \/   \/                     \/ 


    Lightweight replacement for Vala runtime GLib

## Demos

### [<del>ShmupWarz II</del> Better Than Shmup](https://darkoverlordofdata.com/zerog-shmupwarz/)
[The old standby](https://github.com/darkoverlordofdata/zerog-shmupwarz)

### [Match3](https://darkoverlordofdata.com/zerog-match3/)
[wip](https://github.com/darkoverlordofdata/zerog-match3)

### [Platformer](https://darkoverlordofdata.com/zerog-platformer/)
[wip](https://github.com/darkoverlordofdata/zerog-platformer)


## Vala Subset
ZeroG supports a subset of Vala based on Compact classes. This limits oop functionality, and Genie is not well supported. It requires a different coding style, and to set it appart, I'm altering the syle guide. I call it Dark Vala.

Dark Vala style guide:
[Based on msn](https://docs.microsoft.com/en-us/dotnet/standard/design-guidelines/capitalization-conventions)

* Do use casing instead of underscores.
* Do use Pascal casing for all public member, type, and namespace names.
* Do use camel casing for parameter, field and variable names.
* Do use UPPER_CASE for constants.


Parts of zerog are based on the original GLib. There is no GObject. 

Implemented:

* GList & GSList
* GHashTable
* GString
* GArray
* GNode
* GQue



# adriac

    "A spoiled brat with a God complex."
                        Vala Mal Doran 

Adriac is a wrapper for valac, it performs an out of tree build using ZeroG

Additional pre and post processing steps:

* pre processing 
    
    Reference counting code is injected into vala classes

    All access modifiers are changed to 'public'
* post processing
    
    Forward references to injected code is added to resulting c code

## install

cd ~/Applications
git clone https://github.com/darkoverlordofdata/zerog.git

#### todo
make an autovala install for adriac
replace zerog.sh with zerog.js. 

mkdir install
cd install
cmake -G "MSYS Makefiles" ..
make
make install
cd ..
npm install
npm install . -g

update ./bashrc

    export SDL2SDK=$HOME/Applications/SDL2-2.0.5/

    export ZEROG=$HOME/Applications/zerog/

    export PATH=$PATH:$ZEROG/bin

    export CPATH=$ZEROG/include/

#### todo
Windows 10 / MSys2 Environment:


## use

    zerog init myproject com.darkoverlordofdata.myproject

    cd myproject

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



## License
Various licences apply. 

The ZeroG library and Adriac: GPL2

Dark Vala preprocesors: Apache2.

Application libraries:
* entitas - MIT
* sdx - Apache2
* mt19937 - see code 