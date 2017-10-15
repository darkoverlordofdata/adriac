[indent=4]
uses GLib
uses Gee

struct ClassInfo
    scope: string
    outer: string
    klass: string
    type: string
    pfx: string

/**
 * Do all the parsing stuff
 * 
 */
class Parser 

    valac:      StringBuilder           /* vala compiler command */
    cc:         StringBuilder           /* c compiler command */
    builddir:   string                  /* out of tree build location */
    vala_files: array of string         /* all the vala files */
    c_files:    array of string         /* all the c files */
    symtbl:     dict of string, string  /* symbol table to track forward references */

    construct(builddir: string, cc_command: string)
        this.builddir = builddir
        valac = new StringBuilder("/usr/bin/valac ")
        cc = new StringBuilder(@"$(cc_command) ")
        vala_files = new array of string[0]
        c_files = new array of string[0]
        symtbl = new dict of string, string

    /**
     * Add cc command
     */
    def addCcCommand(s: string)
        cc.append(s)
        return

    /**
     * Add valac command
     */
    def addValacCommand(s: string)
        valac.append(s)
        return

    /**
     * Add valac file
     */
    def addValaFile(s: string)
        var tmp = vala_files
        tmp += s
        vala_files = tmp
        return

    /**
     * Add valac file
     */
    def addCFile(s: string)
        var tmp = c_files
        tmp += s
        c_files = tmp
        return

    /**
     * inject reference counting into *.vala code
     *
     * @param string file
     * @param string name
     * @param ClassInfo options
     */
    def injectVala(file:string, name:string, options:ClassInfo)
        var klass = options.klass
        var scope = options.scope
        var pfx = options.pfx
        var src = readTextFile(file)
        if src.index_of("[Adriac]") >= 0 do return  

        src = forcePublicAccess(src)
        src = injectRefCount(options.klass, options.pfx, src)
        writeTextFile(file, src)
        return

    /**
     * inject forward references into *.c code
     *
     * @param string file
     */
    def injectC(file:string)
        var src = readTextFile(file)
        var dst = new StringBuilder()
        var flag = true

        dst.append("/** updated by adriac */\n")
        for line in src.split("\n")
            if generateMacroDependency(line, symtbl, dst)     do flag = true
            if generateFunctionDependency(line, symtbl, dst)  do flag = true
            if generateBaseDependency(line, symtbl, dst)      do flag = true

            dst.append(line)
            dst.append("\n")

        writeTextFile(file, dst.str)
        return


    /**
     * pre-process the vala code
     * Inject reference counting
     * Reset all accessors to 'public'
     * Track symbols for c pre-processing 
     */
    def preProcessVala():bool 
        for var file in vala_files
            if file == "" do continue
            var scope = ""
            var pfx = ""
            var klass = ""
            var outer = ""
            var in_class = false
            var i = 0
            var level = 0
            var dirty = false
            var name = ""
            var type = ""
            var classes = new dict of string, ClassInfo?
            var src = readTextFile(file)
            var t = new Utils.StringTokenizer(src, " \t\n\r\f,=[]{}():", true)
            var a = t.toArray(" \t\n\r\f")

            while i<a.length
                case a[i]
                    when "{"
                        level++
                    when "}"
                        level--
                    when "namespace"
                        i++
                        scope = a[i]
                    when "class"
                        i++
                        klass = a[i]
                        if klass.index_of("<") > 0 // strip off <Generic> parameter
                            klass = klass[0:klass.index_of("<")]
                            
                        if scope == "" && level > 0

                            name = outer + "." + klass
                            pfx = snakeCase(lcfirst(klass))
                            type = outer+klass
                            classes[name] = { scope, outer, klass, type, pfx }
                        

                        else if scope != "" && level > 1

                            name = scope + "." + outer + "." + klass
                            pfx = scope.down().replace(".", "_")+"_"+snakeCase(lcfirst(outer))+"_"+klass.down() 
                            type = scope.replace(".", "")+outer+klass
                            classes[name] = { scope, outer, klass, type, pfx }
                        
                        else

                            outer = klass
                            if scope == ""

                                name = klass
                                pfx = snakeCase(lcfirst(klass)) 
                                type = klass
                                classes[name] = { scope, "", klass, type, pfx }

                            else
                            
                                name = scope + "." + klass
                                pfx = scope.down().replace(".", "_")+"_"+snakeCase(lcfirst(klass))
                                type = scope.replace(".", "")+klass
                                classes[name] = { scope, "", klass, type, pfx }
                        
                i++

            for key in classes.keys
                var opts = classes[key]
                symtbl[opts.pfx] = opts.type 
                injectVala(file, key, opts)

        return true


    
    /**
     * pre-process the c code
     * Injects forward references to the identifiers tracked during pre-processing
     */
    def preProcessC():bool
        for var file in c_files
            injectC(file)
        return true
    

    /**
     * initialize the out of tree build location
     */
    def createBuildDir():bool 
        return spawn(@"cp -rfL src $(builddir)")
    
    /**
     * Compile the vala code to c
     */
    def compileVala():bool
        return spawn(valac.str)
    
    /**
     * Compile the c code
     */
    def compileC():bool
        return spawn(cc.str)
    
    
    /**
     * Spawn a child process
     */
    def spawn(cmd:string):bool
        
        var result = false

        try 
            var cmd_stdout = ""
            var cmd_stderr = ""
            var cmd_status = 0

            Process.spawn_command_line_sync(cmd, out cmd_stdout, out cmd_stderr, out cmd_status)

            if cmd_status != 0
                print cmd_stderr
            print cmd_stdout
            result = cmd_status == 0

        except e: SpawnError 
            print "Spawn Error: %s", e.message
        
        return result
        
    
    /**
     * readTextFile
     *
     * @param string name
     * @return string
     */
    def readTextFile(name: string):string
        var src = ""
        try
            var input = File.new_for_path(name).read()
            var stream = new DataInputStream(input)
            var line = ""
            while (line = stream.read_line()) != null
                src += line+"\n"

        except e: IOError
            print "readTextFile error: %s", e.message

        return src

    /**
     * writeTextFile
     *
     * @param string name
     * @param string text
     */
    def writeTextFile(name: string, text: string)
        try
            var file = File.new_for_path(name)
            if file.query_exists()
                file.delete ()
            
            var dst = new DataOutputStream(file.create (FileCreateFlags.REPLACE_DESTINATION));
            dst.put_string(text)

        except e: IOError
            print "writeTextFile error: %s", e.message

        return
                


