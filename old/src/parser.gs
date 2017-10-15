[indent=4]
uses GLib
uses Gee

struct ClassDef
    name_space: string
    outer_klass: string
    klass: string
    type: string
    pfx: string


class Parser 

    /** symbol table to track forward references */
    symtbl: dict of string, string = new dict of string, string
    /* replaces adriac.json from the prototype */

    valac:      StringBuilder
    cc:         StringBuilder
    vala_files: StringBuilder
    c_files:    StringBuilder
    builddir:   string

    vala_list:  array of string = new array of string[0]
    cc_list:    array of string = new array of string[0]

    construct(builddir: string, cc_command: string)
        this.builddir = builddir
        valac = new StringBuilder("/usr/bin/valac ")
        cc = new StringBuilder(@"$(cc_command) ")
        vala_files = new StringBuilder()
        c_files = new StringBuilder()

    

    /**
     * Add cc command
     */
    def addCcCommand(s: string)
        cc.append(s)

    /**
     * Add valac command
     */
    def addValacCommand(s: string)
        valac.append(s)

    def addValaFile(s: string)
        vala_files.append(s)
        vala_files.append(" ")

    def addCFile(s: string)
        c_files.append(s)
        c_files.append(" ")

    /**
     * inject reference counting into *.vala code
     *
     * @param string file
     * @param string name
     * @param ClassDef options
     */
    def template(file:string, name:string, options:ClassDef)
        var klass = options.klass
        var name_space = options.name_space
        var pfx = options.pfx

        var src = readTextFile(file)
        if src.index_of("[Adriac]") >= 0 do return  

        src = publicAccess(src)
        src = injectRefCount(options.klass, options.pfx, src)
        writeTextFile(file, src)
        return


    /**
     * inject forward references into *.c code
     *
     * @param string file
     */
    def inject(file:string)
        var src = readTextFile(file)
        var dst = new StringBuilder()
        var flag = true

        dst.append("/** updated by adriac */\n")
        for line in src.split("\n")
            if generateMacroWrapper(line, symtbl, dst)     do flag = true
            if generateFunctionWrapper(line, symtbl, dst)  do flag = true
            if generateBaseMethods(line, symtbl, dst)      do flag = true

            dst.append(line)
            dst.append("\n")

        writeTextFile(file, dst.str)
        return


    /**
     * initialize the out of tree build
     *
     * @return bool
     */
    def createBuildDir():bool 
        return spawn(@"cp -rfL src $(builddir)")
    
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
        except e: Error
            pass
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

        except e: Error
            pass
        return
                

    /**
     * Inject reference counting
     * Reset all accessors to 'public'
     * Track symbols for post processing 
     */
    def preProcessVala():bool 
        for var file in vala_files.str.split(" ")
            if file == "" do continue
            var name_space = ""
            var pfx = ""
            var classes = new dict of string, ClassDef?
            var klass = ""
            var outerKlass = ""
            var in_class = false
            var src = readTextFile(file)
            var t = new Utils.StringTokenizer(src, " \t\n\r\f,=[]{}():", true)
            var a = t.toArray(" \t\n\r\f")
            var i = 0
            var level = 0
            var dirty = false
            var classname = ""
            var type = ""

            while i<a.length
                case a[i]
                    when "{"
                        level++
                    when "}"
                        level--
                    when "namespace"
                        i++
                        name_space = a[i]
                    when "class"
                        i++
                        klass = a[i]
                        if klass.index_of("<") > 0 // strip off <Generic> parameter
                            klass = klass[0:klass.index_of("<")]
                            
                        if name_space == "" && level > 0

                            classname = outerKlass + "." + klass
                            pfx = snakeCase(lcfirst(klass))
                            type = outerKlass+klass
                            classes[classname] = { name_space, outerKlass, klass, type, pfx }
                            // print "1 %s [%s - %s - %s - %s - %s]", classname, classes[classname].name_space, classes[classname].outer_klass, classes[classname].klass, classes[classname].type, classes[classname].pfx
                        

                        else if name_space != "" && level > 1

                            classname = name_space + "." + outerKlass + "." + klass
                            pfx = name_space.down().replace(".", "_")+"_"+snakeCase(lcfirst(outerKlass))+"_"+klass.down() 
                            type = name_space.replace(".", "")+outerKlass+klass
                            classes[classname] = { name_space, outerKlass, klass, type, pfx }
                            // print "2 %s [%s - %s - %s - %s - %s]", classname, classes[classname].name_space, classes[classname].outer_klass, classes[classname].klass, classes[classname].type, classes[classname].pfx
                        
                        else

                            outerKlass = klass
                            if name_space == ""

                                classname = klass
                                pfx = snakeCase(lcfirst(klass)) 
                                type = klass
                                classes[classname] = { name_space, "", klass, type, pfx }
                                // print "3 %s [%s - %s - %s - %s - %s]", classname, classes[classname].name_space, classes[classname].outer_klass, classes[classname].klass, classes[classname].type, classes[classname].pfx

                            else
                            
                                classname = name_space + "." + klass
                                pfx = name_space.down().replace(".", "_")+"_"+snakeCase(lcfirst(klass))
                                type = name_space.replace(".", "")+klass
                                classes[classname] = { name_space, "", klass, type, pfx }
                                // print "4 %s [%s - %s - %s - %s - %s]", classname, classes[classname].name_space, classes[classname].outer_klass, classes[classname].klass, classes[classname].type, classes[classname].pfx
                        
                i++

            for var name in classes.keys
                var opts = classes[name]
                if file.index_of(".vala") > 0
                    symtbl[opts.pfx] = opts.type 
                    template(file, name, opts)
                    

        // var SDK = getEnv("ZEROG")
        // return spawn(@"$(SDK)/tools/pre-vala.coffee $(builddir) \"$(encodeURIComponent(vala_files.str))\"")
        return true

        
    

    /**
     * Inject reference counting
     * Reset all accessors to 'public'
     * Track symbols for post processing 
     */
    def preProcessGenie():bool 
        var SDK = getEnv("ZEROG")
        return spawn(@"$(SDK)/tools/pre-gs.coffee $(builddir) \"$(encodeURIComponent(vala_files.str))\"")
    

    /**
     * Compile the pre-processed source code to c
     */
    def compileValac():bool
        var SDK = getEnv("ZEROG")
        // print "============================================\n"
        // print valac.str
        // print "\n============================================\n"
        return spawn(@"$(SDK)/tools/proc \"$(encodeURIComponent(valac.str))\"")
    
    
    /**
     * Post-process the c code
     * Injects forward references to the identifiers tracked during pre-processing
     */
    def postProcessAll():bool
    
        for var file in c_files.str.split(" ")
            inject(file)
        return true

        // var SDK = getEnv("ZEROG")
        // return spawn(@"$(SDK)/tools/post.coffee $(builddir) \"$(encodeURIComponent(c_files.str))\"")
    

    /**
     * Compile the finished c code
     */
    def compileCc():bool
        var SDK = getEnv("ZEROG")
        // print "============================================\n"
        // print cc.str
        // print "\n============================================\n"
        return spawn(@"$(SDK)/tools/proc \"$(encodeURIComponent(cc.str))\"")
    
    
    /**
     */
    def spawn(cmd:string):bool
        
        var result = false

        try 
            var spawn_args = cmd.split(" ") 
            var spawn_env = Environ.get()
            var cmd_stdout = ""
            var cmd_stderr = ""
            var cmd_status = 0

            Process.spawn_sync(null, spawn_args, spawn_env, SpawnFlags.SEARCH_PATH, null, out cmd_stdout, out cmd_stderr, out cmd_status)

            if cmd_status != 0
                print cmd_stderr
            print cmd_stdout
            result = cmd_status == 0

        except e: SpawnError 
            print "Error: %s", e.message
        
        return result
        
    

    /**
     * get Environment variable
     */
    def static getEnv(name: string): string
        var stdout_ = ""
        var stderr_ = ""
        var status = 0
        var match = name+"="
        try 
            Process.spawn_command_line_sync ("printenv", out stdout_, out stderr_, out status)
            for var v in stdout_.split("\n")
                if v.substring(0,match.length) == match
                    return v.substring(match.length)
            return ""
        except e:SpawnError
            return null
    
    /**
     * encodeURIComponent
     * 
     * prevents the cli from expanding flags, quotes and paths in parameter list
     */
    def encodeURIComponent(str:string): string
        //  Regex rx = new Regex("\\-")

        var result = Uri.escape_string(str)
        // we also need to process hyphens to prevent command line flag expansion
        return /-/.replace(result, result.length, 0, "%2D")

