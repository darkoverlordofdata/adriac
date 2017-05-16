#!/usr/bin/env coffee
###
## Copyright (c) 2017 Bruce Davidson &lt;darkoverlordofdata@gmail.com&gt;
## Apache 2.0 License
##
##  inject genie boilerplate
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

    if /^	class\s+\w*\s*:\s*Object\s*/mg.test src
        src = src.replace(/^	class\s+(\w*)\s*:\s*(Object)\s*/mg, ($0, $1, $2) ->
            """
\t[Compact, CCode ( /** reference counting */
\t\tref_function = "#{namespace}_#{name}_retain", 
\t\tunref_function = "#{namespace}_#{name}_release"
\t)]
\tclass #{klass}
\t\trefCount: int = 1
\t\tdef retain() : unowned #{klass}
\t\t\tGLib.AtomicInt.add (ref retainCount__, 1)
\t\t\treturn this
\t\tdef release() 
\t\t\tif GLib.AtomicInt.dec_and_test (ref retainCount__) do this.free ()
\t\tdef extern free()\n\t\t
        """)
        fs.writeFileSync(file, src)
    else if /^class\s+\w*\s*:\s*Object\s*/mg.test src
        src = src.replace(/^class\s+(\w*)\s*:\s*(Object)\s*/mg, ($0, $1, $2) ->
            """
[Compact, CCode ( /** reference counting */
	ref_function = "#{name}_retain", 
	unref_function = "#{name}_release"
)]
class #{klass}
	retainCount__: int = 1
	def retain() : unowned #{klass}
		GLib.AtomicInt.add (ref retainCount__, 1)
		return this
	def release() 
		if GLib.AtomicInt.dec_and_test (ref retainCount__) do this.free ()
	def extern free()\n\t
        """)
        fs.writeFileSync(file, src)

    else if /^	class\s+\w*\s*:\s*\w+\s*/mg.test src
        src = src.replace(/^	class\s+(\w*)\s*:\s*(\w+)\s*/mg, ($0, $1, $2) ->
            """
\t[Compact]
\tclass #{klass} : #{$2}\n\t\t
        """)
        fs.writeFileSync(file, src)

    else if /^class\s+\w*\s*:\s*\w+\s*/mg.test src
        src = src.replace(/^class\s+(\w*)\s*:\s*(\w+)\s*/mg, ($0, $1, $2) ->
            """
[Compact]
class #{klass} : #{$2}\n\t
        """)
        fs.writeFileSync(file, src)

