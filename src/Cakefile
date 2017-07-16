
##
## Cakefile
##
## build android / emscripten using autovala info
## by dynamically writing a build script.
## saves a copy of the most recently run script
##
fs = require 'fs'
path = require 'path'
child_process = require 'child_process'

##
## execute 1 or more commands
## asynchronously and serially
## save the script as ./#{name}.sh
##
exec = (name, lines) ->
    fs.writeFileSync("./#{name}.sh", lines)
    cmds = lines.split('\n')
    exec = (cmd, cb) ->
        console.log cmd
        child_process.exec cmd, (error, stdout, stderr) ->
            console.log error if error
            console.log stdout if stdout
            console.log stderr if stderr
            process.exit() if error
            cb()
    next = -> exec cmds.shift(), -> next() if cmds.length
    next()

##
## parse *.avprj info
##
avprjParse = ()->
    data = {}
    
    lines = fs.readFileSync("./#{path.basename(__dirname)}.avprj", 'utf8').split('\n')
    for line in lines
      if line is '' then continue
      if line[0] is '#' then continue
      
      [key0, value] = line.split(/\s*\:\s*/)
      [readonly, key] = [false, key0]
      if key[0] is '*'
        [readonly, key] = [true, key.substring(1)]
      
      if data[key] != null
        if !Array.isArray(data[key])
            data[key] = []
        
        data[key].push
          value: value
          readonly: readonly
        
      else 
        data[key] = 
          value: value
          readonly: readonly
    return data

##
## get list of vapi's to reference
##
getVapis = (vala_vapi) ->
    if not vala_vapi? then return ''
    ("--pkg #{path.basename(vapi.value, '.vapi')}" for vapi in vala_vapi).join(' ')
    
##
## get list of pkg's to reference
##
getPkgs = (vala_check_package) ->
    if not vala_check_package? then return ''
    result = []
    for pkg in vala_check_package
        switch pkg.value
            when 'glib-2.0' then continue
            when 'gobject-2.0' then continue
        result.push "--pkg #{pkg.value}"
    result.join(' ')

##
## get list of vala sources
##
getSrc = (vala_source) ->
    if not vala_source? then return ''
    ("build/src/#{src.value}" for src in vala_source)


##
## Template: android build script
##
androidTemplate = (defines, vapis, pkgs, list, copy) ->
    return """
adriac --builddir build \
    --cc=jni \
    #{defines} \
    --vapidir src/vapis \
    --pkg android \
    #{vapis} \
    #{pkgs} \
    -X -O2 \
    #{list}


sed  "s/#include <SDL2/#include <SDL2\\/SDL.h>\\n#include <SDL2/g"  ./build/src/main.c >  ./android/jni/src/main.c
#{copy}
cd ./android/jni && ndk-build
cd ./android && ant debug # install
"""
##
## Template: emscripten build script
##
emscriptenTemplate = (defines, vapis, pkgs, list) ->
    return """
mkdir -p build
adriac  \
    --builddir build \
    --cc=emcc \
    #{defines} \
    --vapidir src/vapis-em \
    --pkg emscripten \
    #{vapis} \
    #{pkgs} \
    -X -O3 \
    -X -I/usr/local/include \
    -X -I/home/bruce/.local/include/ \
    -o web/#{path.basename(__dirname)}.html  \
    #{list}
"""

##
## Template: desktop build script
##
desktopTemplate = (defines, vapis, pkgs, list) ->
    return """
mkdir -p build
adriac  \
    --builddir build \
    --cc=clang \
    #{defines} \
    --vapidir src/vapis \
    #{vapis} \
    #{pkgs} \
    -X -lm \
    -X -lSDL2 \
    -X -lSDL2_image \
    -X -lSDL2_mixer \
    -X -lSDL2_ttf \
    -X -O3 \
    -X -I/usr/local/include \
    -X -I/home/bruce/.local/include/ \
    -o build/#{path.basename(__dirname)}  \
    #{list}
"""

##
## build android project
##
task 'build:android', 'build android project', ->
    prj = avprjParse()
    vapis = getVapis(prj.vala_vapi)
    pkgs = getPkgs(prj.vala_check_package)
    list = getSrc(prj.vala_source)

    copy = []
    for src in list
        cfile = src.replace('.vala', '.c').replace('.gs', '.c')
        if src.indexOf('main.') is -1
            copy.push "cp -f ./#{cfile} "+cfile.replace('build/', './android/jni/')

    cmd = androidTemplate('--define ANDROID', vapis, pkgs, list.join(' '), copy.join('\n'))
    exec 'android', cmd
    
##
## clean android project
##
task 'clean:android', 'clean android project', ->
    console.log "not implemented"
    return

##
## build emscripten project
##
task 'build:emscripten', 'build emscripten project', ->
    prj = avprjParse()
    vapis = getVapis(prj.vala_vapi)
    pkgs = getPkgs(prj.vala_check_package)
    list = getSrc(prj.vala_source).join(' ') + ' ' + getSrc(prj.c_source).join(' ')

    cmd = emscriptenTemplate('--define EMSCRIPTEN --define PROFILING', vapis, pkgs, list) 
    console.log cmd
    exec 'emscripten', cmd

##
## clean emscripten project
##
task 'clean:emscripten', 'clean emscripten project', ->
    console.log "not implemented"
    return

##
## build desktop project
##
task 'build:desktop', 'build desktop project', ->
    prj = avprjParse()
    vapis = getVapis(prj.vala_vapi)
    pkgs = getPkgs(prj.vala_check_package)
    list = getSrc(prj.vala_source).join(' ') + ' ' + getSrc(prj.c_source).join(' ')

    cmd = desktopTemplate('--define NOGOBJECT', vapis, pkgs, list) 
    console.log cmd
    exec 'desktop', cmd

