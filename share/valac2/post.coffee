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
    src = fs.readFileSync(file, 'utf8').split('\n')
    dst = []
    for line in src 
        for mangled, name of options
            if line.indexOf("#define _#{mangled}_release0") is 0
                flag = true
                dst.push "void #{mangled}_release (#{name}* self);"
                dst.push "void #{mangled}_free (#{name}* self);"
                dst.push "#{name}* #{mangled}_retain (#{name}* self);"
            else if line.indexOf("void #{mangled}_free (#{name}* self);") is 0
                flag = true
                dst.push "void #{mangled}_release (#{name}* self);"
                dst.push "#{name}* #{mangled}_retain (#{name}* self);"
           dst.push line 
    if flag then fs.writeFileSync(file, dst.join('\n'))

##
## cross reference _release & _free
##
files = decodeURIComponent(process.argv[2])
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
                

