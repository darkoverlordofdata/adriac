#!/usr/bin/env coffee
###
## Copyright (c) 2017 Bruce Davidson &lt;darkoverlordofdata@gmail.com&gt;
## Apache 2.0 License
##
##  Phase II - preprocess for emcc
##
## Inject missing forward references for boilerplate code
##      <class_name>_release
##      <class_name>_free
##      <class_name>_retain
##
## Problem:
##      CCode atrribute forward referenes are not propogated to other outputs
##      in the same compilation unit. This fixes the intermediate c files before
##      final compilation.
##
##  Assumptions: 
##      a folder corresponds to a namespace
##      files with PascalCase names contain reference counted classes
##      there is one such class per file
###
fs = require 'fs'
path = require 'path'
list = []
options = {}

lcfirst = (str) -> str.charAt(0).toLowerCase() + str.substr(1)
snakeCase = (str) ->  str.replace(/([A-Z])/g, ($0) -> "_"+$0.toLowerCase())

##
## inject missing forward references
## for automatic reference counting
##
inject = (file, options) ->
    src = fs.readFileSync(file, 'utf8')
    dst = ['/** updated by adriac */']
    flag = false
    # flag = true
    for line in src.split('\n')
        #
        #   check for macro wrapper 
        #
        line.replace /\#define\s+\_([_a-z0-9]+)_release0/, ($0, $1) ->
            type = symtbl[$1]
            # dst.push "// symtbl #{$1}"
            if type?
                flag = true
                dst.push "void #{$1}_release (#{type}* self);"
                dst.push "void #{$1}_free (#{type}* self);"
                dst.push "#{type}* #{$1}_retain (#{type}* self);"

        #
        #   check for function wrapper 
        #
        line.replace /static\s+void\s+\_([_a-z0-9]+)_release0_/, ($0, $1) ->
            type = symtbl[$1]
            # dst.push "// symtbl #{$1}"
            if type?
                flag = true
                dst.push "void #{$1}_release (#{type}* self);"
                dst.push "void #{$1}_free (#{type}* self);"
                dst.push "#{type}* #{$1}_retain (#{type}* self);"

        #
        #   check for base class methods 
        #
        line.replace /(\w+)\*\s+([_a-z0-9]+)_new/, ($0, $1, $2) ->
            type = symtbl[$2]
            # dst.push "// symtbl #{$1} / #{$2}"
            if type?
                if !(///#{type}*\s+#{$2}_retain\s+(#{type}*\s+self);///.test(src))
                    flag = true
                    dst.push "#{type}* #{$2}_retain (#{type}* self);"

            if type?
                if !(///void\s+#{$2}_release\s+(#{type}*\s+self);///.test(src))
                    flag = true
                    dst.push "void #{$2}_release (#{type}* self);"

        # line.replace /\void\s+([_a-z0-9]+)_release\s+\((\w+)* self\)/, ($0, $1, $2) ->
        #     type = symtbl[$1]
        #     dst.push "// symtbl #{$1} #{$2}"
        #     if type?
        #         flag = true
        #         dst.push "void #{$1}_release (#{$2}* self);"
        #         dst.push "#{$2}* #{$1}_retain (#{$2}* self);"

        # line.replace /void\s+([_a-z0-9]+)_free\s+\((\w+)* self\)/, ($0, $1, $2) ->
        #     type = symtbl[$1]
        #     dst.push "// symtbl #{$1}"
        #     if type?
        #         flag = true
        #         dst.push "void #{$1}_release (#{$2}* self);"
        #         dst.push "#{$2}* #{$1}_retain (#{$2}* self);"

        dst.push line 
    if flag then fs.writeFileSync(file, dst.join('\n'))

        # for mangled, name of options
        #     if line.indexOf("#define _#{mangled}_release0") is 0
        #         flag = true
        #         dst.push "void #{mangled}_release (#{name}* self);"
        #         dst.push "void #{mangled}_free (#{name}* self);"
        #         dst.push "#{name}* #{mangled}_retain (#{name}* self);"
        #     else if line.indexOf("void #{mangled}_free (#{name}* self);") is 0
        #         flag = true
        #         dst.push "void #{mangled}_release (#{name}* self);"
        #         dst.push "#{name}* #{mangled}_retain (#{name}* self);"
        #    dst.push line 
        # if flag then fs.writeFileSync(file, dst.join('\n'))

merge = (a, b) ->
    c = {}
    json_a = if fs.existsSync(a) then JSON.parse(fs.readFileSync(a)) else {}
    json_b = if fs.existsSync(b) then JSON.parse(fs.readFileSync(b)) else {}

    c[name] = value for name, value of json_a
    c[name] = value for name, value of json_b
    return c
        
##
## cross reference _release & _free
##
buildDir = process.argv[2]
symtbl = merge("./adriac.json", "#{buildDir}/adriac.json")
# symtbl = merge(
#     JSON.parse(fs.readFileSync("./adriac.json", 'utf8')), 
#     JSON.parse(fs.readFileSync("#{buildDir}/adriac.json", 'utf8')))
files = decodeURIComponent(process.argv[3])
files = files[1...-1] if files[0] is '"' 
for file in files.split(" ")
    if path.extname(file) is  '.c'
        klass = path.basename(file, '.c')
        if klass[0] >='A' && klass[0] <= 'Z'
            name = klass.toLowerCase()
            namespace = path.dirname(file).substring(10)
            fixed = snakeCase(lcfirst(klass))
            ns = namespace.replace(/\//g, "_")
            mangled = if ns is "" then fixed else "#{ns}_#{fixed}"
            mangled = mangled.replace(/\//g, "_")
            options[mangled] = (ns+klass).replace(/\_/g, "")


for file in files.split(" ")
    if path.extname(file) is  '.c'
        inject(file, options) 
                

