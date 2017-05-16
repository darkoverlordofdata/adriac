#!/usr/bin/env coffee
###
## Copyright (c) 2017 Bruce Davidson &lt;darkoverlordofdata@gmail.com&gt;
## Apache 2.0 License
##
##  inject vala boilerplate
##
## Injects reference counting boilerplate into classes declared as:
##
##  <ClassName> : Object
##
###
fs = require 'fs'
path = require 'path'
lcfirst = (str) -> str.charAt(0).toLowerCase() + str.substr(1)
snakeCase = (str) ->  str.replace(/([A-Z])/g, ($0) -> "_"+$0.toLowerCase())

##
## inject the reference counting code
##
module.exports = (file, options) ->


    klass = options.class
    name = options.name
    # fix namespace
    namespace = options.namespace.replace(/\//g, "_")
    # fix name
    name = snakeCase(lcfirst(klass))

    src = fs.readFileSync(file, 'utf8')

    ##
    ##  class Name <K,V> : Object {
    ##
    if /^(\s*)public\s+class\s+\w*\s*\<\w,\s*\w\>\s*:\s*Object\s{*/mg.test src
        src = src.replace(/^(\s*)public\s+class\s+(\w*)\s*\<(\w,\s*\w)\>\s*:\s*(Object)\s*{/mg, ($0, $1, $2, $3, $4) ->
            tab = $1.replace(/\n/mg, "").replace("\t", "")
            n1 = if namespace is "" then "" else namespace+"_"
            """
#{tab}[Compact, CCode ( /** reference counting */
#{tab}\tref_function = "#{n1}#{name}_retain", 
#{tab}\tunref_function = "#{n1}#{name}_release"
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

    ##
    ##  class Name <G> : Object {
    ##
    else if /^(\s*)public\s+class\s+\w*\s*\<\w\>\s*:\s*Object\s{*/mg.test src
        src = src.replace(/^(\s*)public\s+class\s+(\w*)\s*\<(\w)\>\s*:\s*(Object)\s*{/mg, ($0, $1, $2, $3, $4) ->
            tab = $1.replace(/\n/mg, "").replace("\t", "")
            n1 = if namespace is "" then "" else namespace+"_"
            """
#{tab}[Compact, CCode ( /** reference counting */
#{tab}\tref_function = "#{n1}#{name}_retain", 
#{tab}\tunref_function = "#{n1}#{name}_release"
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

    ##
    ##  class Name : Object {
    ##
    else if /^(\s*)public\s+class\s+\w*\s*:\s*Object\s{*/mg.test src
        src = src.replace(/^(\s*)public\s+class\s+(\w*)\s*:\s*(Object)\s*{/mg, ($0, $1, $2, $3) ->
            tab = $1.replace(/\n/mg, "").replace("\t", "")
            n1 = if namespace is "" then "" else namespace+"_"
            """
#{tab}[Compact, CCode ( /** reference counting */
#{tab}\tref_function = "#{n1}#{name}_retain", 
#{tab}\tunref_function = "#{n1}#{name}_release"
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


    ##
    ##  class Name {
    ##
    else if /^(\s*)public\s+class\s+\w*\s*:\s*\w+\s*{/mg.test src
        src = src.replace(/^(\s*)public\s+class\s+(\w*)\s*:\s*(\w+)\s*{/mg, ($0, $1, $2, $3) ->
            tab = $1.replace(/\n/mg, "").replace("\t", "")
            """
#{tab}[Compact]
#{tab}public class #{$2} : #{$3} {\n#{tab}\t
        """)
        fs.writeFileSync(file, src)

