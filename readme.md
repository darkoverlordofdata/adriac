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

## oop limitations

* no regex
* no virtual or override
* no interface
* no abstract
* no [Flags] enum
* subclases cannot declare instance members

## workarounds
to replace interface, make a struct of delegates


## todo
convert coffeescript to bash script
finish glib port