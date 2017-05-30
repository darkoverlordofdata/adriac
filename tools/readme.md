# emvalac

my build tools for targetting emscripen with vala


* Compile vala/genie with emscripten. 
* Works with SDL2. 
* Both vala and genie, but vala has fewer limitations.

Vala compiles to C, so it can target emscripten. That seems like a no brainer. 
The problem is, there is no runtime - Vala uses GLib for it's runtime, and there is no glib port for Emscripten. 

https://github.com/radare/posixvala shows how we can hack the runtime back to life, by supplying missing GLib implementation.

I'm taking this hack further, re-fitting selected glib modules to work in emscripten. 
There is also no GObject in Emscripten. This limits it to compact class. so I've added a preprocessing step to inject automatic reference counting into classes tagged by 'subclassing' Object. 

## restrictions

### vala

* one namespace per file, (except global)
* one namespace statement per file. Use '.' to specity compound namespace:

    namespace outer.inner {
        ...
    }

#### example:
https://github.com/darkoverlordofdata/vala-emscripten


### genie

* one class per file
* file tree must align with namespace, like java
* forward references to ARC methods are broken (see example for workaround)

#### example:
https://github.com/darkoverlordofdata/platformer-gs

## oop limitations

* no regex
* no virtual or override
* no interface
* no abstract
* no [Flags] enum
* subclases cannot declare instance members

## workarounds
to replace interface, make a struct of delegates


## install
copy bin, include, and share/emvalac to ./local

add to .bashrc

    export CPATH=$HOME/.local/include/

or add to each compile command line

    -X -I/home/bruce/.local/include/ 


## dependencies

valac
nodejs

## todo
finish glib port
