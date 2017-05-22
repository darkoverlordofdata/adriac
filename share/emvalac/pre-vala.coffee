#!/usr/bin/env coffee
###
## Copyright (c) 2017 Bruce Davidson &lt;darkoverlordofdata@gmail.com&gt;
## GPL3
##
###
fs = require 'fs'
path = require 'path'
lcfirst = (str) -> str.charAt(0).toLowerCase() + str.substr(1)
snakeCase = (str) ->  str.replace(/([A-Z])/g, ($0) -> "_"+$0.toLowerCase())

template = (file, name, options) ->

    klass = options.class
    namespace = options.namespace
    pfx = options.pfx

    src = fs.readFileSync(file, 'utf8')

    ##
    ##  class Name <K,V> : Object {
    ##
    if /^(\s*)public\s+class\s+\w*\s*\<\w,\s*\w\>\s*:\s*Object\s{*/m.test src
        src = src.replace(/^(\s*)public\s+class\s+(\w*)\s*\<(\w,\s*\w)\>\s*:\s*(Object)\s*{/m, ($0, $1, $2, $3, $4) ->
            tab = $1.replace(/\n/mg, "").replace("\t", "")
            """
#{tab}[Compact, CCode ( /** reference counting */
#{tab}\tref_function = "#{pfx}_retain", 
#{tab}\tunref_function = "#{pfx}_release"
#{tab})]
#{tab}public class #{$2}<#{$3}> {
#{tab}\tpublic int _retainCount = 1;
#{tab}\tpublic unowned #{$2}<#{$3}> retain() {
#{tab}\t\tGLib.AtomicInt.add (ref _retainCount, 1);
#{tab}\t\treturn this;
#{tab}\t}
#{tab}\tpublic void release() { 
#{tab}\t\tif (GLib.AtomicInt.dec_and_test (ref _retainCount)) this.free ();
#{tab}\t}
#{tab}\tpublic extern void free();\n\t\t
        """)
        fs.writeFileSync(file, src)
        return src

    ##
    ##  class Name <G> : Object {
    ##
    else if /^(\s*)public\s+class\s+\w*\s*\<\w\>\s*:\s*Object\s{*/m.test src
        src = src.replace(/^(\s*)public\s+class\s+(\w*)\s*\<(\w)\>\s*:\s*(Object)\s*{/m, ($0, $1, $2, $3, $4) ->
            tab = $1.replace(/\n/mg, "").replace("\t", "")
            """
#{tab}[Compact, CCode ( /** reference counting */
#{tab}\tref_function = "#{pfx}_retain", 
#{tab}\tunref_function = "#{pfx}_release"
#{tab})]
#{tab}public class #{$2}<#{$3}> {
#{tab}\tpublic int _retainCount = 1;
#{tab}\tpublic unowned #{$2}<#{$3}> retain() {
#{tab}\t\tGLib.AtomicInt.add (ref _retainCount, 1);
#{tab}\t\treturn this;
#{tab}\t}
#{tab}\tpublic void release() { 
#{tab}\t\tif (GLib.AtomicInt.dec_and_test (ref _retainCount)) this.free ();
#{tab}\t}
#{tab}\tpublic extern void free();\n\t\t
        """)
        fs.writeFileSync(file, src)
        return src

    ##
    ##  class Name : Object {
    ##
    else if /^(\s*)public\s+class\s+\w*\s*:\s*Object\s{*/m.test src
        src = src.replace(/^(\s*)public\s+class\s+(\w*)\s*:\s*(Object)\s*{/m, ($0, $1, $2, $3) ->
            tab = $1.replace(/\n/mg, "").replace("\t", "")
            """
#{tab}[Compact, CCode ( /** reference counting */
#{tab}\tref_function = "#{pfx}_retain", 
#{tab}\tunref_function = "#{pfx}_release"
#{tab})]
#{tab}public class #{$2} {
#{tab}\tpublic int _retainCount = 1;
#{tab}\tpublic unowned #{$2} retain() {
#{tab}\t\tGLib.AtomicInt.add (ref _retainCount, 1);
#{tab}\t\treturn this;
#{tab}\t}
#{tab}\tpublic void release() { 
#{tab}\t\tif (GLib.AtomicInt.dec_and_test (ref _retainCount)) this.free ();
#{tab}\t}
#{tab}\tpublic extern void free();\n\t\t
        """)
        fs.writeFileSync(file, src)
        return src


    ##
    ##  class Name {
    ##
    else if /^(\s*)public\s+class\s+\w*\s*:\s*\w+\s*{/m.test src
        src = src.replace(/^(\s*)public\s+class\s+(\w*)\s*:\s*(\w+)\s*{/m, ($0, $1, $2, $3) ->
            tab = $1.replace(/\n/mg, "").replace("\t", "")
            """
#{tab}[Compact]
#{tab}public class #{$2} : #{$3} {\n#{tab}\t
        """)
        fs.writeFileSync(file, src)
        return src



buildDir = process.argv[2]
cmd = decodeURIComponent(process.argv[3])
cmd = cmd[1...-1] if cmd[0] is '"' 
args = cmd.split(" ")
sym  = {}

for arg in args
    namespace = ''
    pfx = []
    classes = {}
    klass = ''
    outerKlass = ''
    inClass = false

    if arg is "" then continue
    src = fs.readFileSync(arg, 'utf8')

    a = src.split(/\s+/)
    i = 0
    level = 0
    while i<a.length
        switch a[i]
            when '{' #then l++
                level++
                
            when '}' #then l--
                level--

            when 'namespace'
                i++
                namespace = a[i]

            when 'class'
                i++
                klass = a[i]
                if klass.indexOf('<') > 0
                    klass = klass[0..klass.indexOf('<')-1]
                if namespace is '' and level > 0
                    # inner class
                    classname = outerKlass + '.' + klass
                    pfx = snakeCase(lcfirst(klass))
                    type = lcfirst(outerKlass)+klass
                    classes[classname] = {
                        namespace: namespace
                        outer: outerKlass
                        class: klass
                        type: type
                        pfx: pfx
                    }

                else if namespace isnt '' and level > 1
                    # inner class
                    classname = namespace + '.' + outerKlass + '.' + klass
                    #pfx = namespace.replace(/\./g, '_')+'_'+snakeCase(lcfirst(outerKlass))+'_'+snakeCase(lcfirst(klass)) 
                    pfx = namespace.toLowerCase().replace(/\./g, '_')+'_'+snakeCase(lcfirst(outerKlass))+'_'+klass.toLowerCase() 
                    type = namespace.replace(/\./g, '')+outerKlass+klass
                    classes[classname] = {
                        namespace: namespace
                        outer: outerKlass
                        class: klass
                        type: type
                        pfx: pfx
                    }
                else
                    outerKlass = klass
                    if namespace is ''
                        classname = klass
                        pfx = snakeCase(lcfirst(klass)) 
                        type = klass
                        classes[classname] = {
                            namespace: namespace
                            outer: ''
                            class: klass
                            type: type
                            pfx: pfx
                        }
                    else 
                        classname = namespace + '.' + klass
                        pfx = namespace.toLowerCase().replace(/\./g, '_')+'_'+snakeCase(lcfirst(klass)) 
                        type = namespace.replace(/\./g, '')+klass
                        classes[classname] = {
                            namespace: namespace
                            outer: ''
                            class: klass
                            type: type
                            pfx: pfx
                        }

        i++

    for name, opts of classes
        t = path.extname(arg)
        if t is '.vala' 
            sym[opts.pfx] = opts.type 
            template(arg, name, opts)


fs.writeFileSync("#{buildDir}/symtbl.json", JSON.stringify(sym, null, 2))
