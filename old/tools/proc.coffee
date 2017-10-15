#!/usr/bin/env coffee
###
## Copyright (c) 2017 Bruce Davidson &lt;darkoverlordofdata@gmail.com&gt;
## Apache 2.0 License
##
##  Runs a command
##  vala dies with 1 error, and there is no error text.
##  but I can run this... 
##
###
{ exec } = require 'child_process'
cmd = decodeURIComponent(process.argv[2])
cmd = cmd[1...-1] if cmd[0] is '"' 

exec cmd, (error, stdout, stderr) -> 
    #console.log error if error
    console.log stdout if stdout
    console.error stderr if stderr
    process.exit(1) if error
