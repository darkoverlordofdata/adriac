#!/usr/bin/env coffee
###
## Copyright (c) 2017 Bruce Davidson &lt;darkoverlordofdata@gmail.com&gt;
## Apache 2.0 License
##
##  Phase I - preprocess for valac
##
## Injects reference counting boilerplate into classes that sublcass Object
##
##  <ClassName> : Object
##
###
fs = require 'fs'
path = require 'path'
options = {}


files = decodeURIComponent(process.argv[2])
files = files[1...-1] if files[0] is '"' 
for file in files.split(" ")
    switch path.extname(file)
        when '.gs' 
            klass = path.basename(file, '.gs')
            if klass[0] >='A' && klass[0] <= 'Z'
                name = klass.toLowerCase()
                namespace = path.dirname(file).substring(10)
                require('./boilerplate').gs(file, 
                    ext         :'gs'
                    class       : klass
                    name        : name
                    namespace   : namespace
                ) 

        when '.vala' 
            klass = path.basename(file, '.vala')
            if klass[0] >='A' && klass[0] <= 'Z'
                name = klass.toLowerCase()
                namespace = path.dirname(file).substring(10)
                require('./boilerplate').vala(file, 
                    ext         :'vala'
                    class       : klass
                    name        : name
                    namespace   : namespace
                )
    

    
    
