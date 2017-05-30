# bosco-sdk

generate a new vala game project
paired with emvalac

## install

cd ~/Applications
git clone https://github.com/darkoverlordofdata/emvalac.git

update ./bashrc

    export SDL2SDK=$HOME/Applications/SDL2-2.0.5/

    export BOSCO=$HOME/Applications/emvalac/

    export PATH=$PATH:$BOSCO/bin

    export CPATH=$BOSCO/include/


## use

    bosco init match3 com.darkoverlordofdata.match3

    cd match3

    autovala refresh
    autovala cmake
    cd install
    cmake ..
    make
    
    cd ..
    cake build:emscripten
    cake build:android

## requirements

    valac
    sdl2
    autovala
    emscripten
    nodejs
    coffeescrpipt
