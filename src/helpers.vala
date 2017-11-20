using Gee;
/**
 * snakeCase
 * 
 * converts a PascalCase or camelCase string to snake_case
 * 
 * @param string s
 * @return string
 */
public string snakeCase(string s) {
	var t = /([A-Z])/.replace_eval(s, s.length, 0, 0, (info, result) => {
		result.append("_");
		result.append(info.fetch(0).down());
		return true;
	});
	var u = /([A-Z])/.replace_eval(t, t.length, 0, 0, (info, result) => {
		result.append("_");
		result.append(info.fetch(0).down());
		return true;
	});
	return u;
}

/**
 * lcfirst
 * 
 * ensure that the 1st char is lower case
 * 
 * @param string s
 * @return string
 */
public string lcfirst(string s) {
	return s.get_char(0).to_string().down() + s.substring(1);
}

/**
 * force public access
 * 
 * @param string s
 * @return string
 */
public string forcePublicAccess(string s) {
	return /\b(private|internal|protected)\b/m.replace(s, s.length, 0, "public");
}

/**
 * inject reference counting code
 * 
 * @param string klass
 * @param string pfx
 * @param string s
 * @return string
 */
public string injectRefCount(string klass, string pfx, string s) {
	//  var lines = s.split("\n");

	var rxObject = new Regex(@"(\\s*)\\bpublic\\s+class\\s+$(klass)\\s*:\\s*Object\\s*{");
	var rxCompact = new Regex(@"(\\s*)\\bpublic\\s+class\\s+$(klass)\\s*:\\s*\\w+\\s*{");

	if (rxObject.match(s)) {
		/**
		 * If it extends Object, then it's a base Compact class
		 * and we inject the reference counting implementation
		 */
		return rxObject.replace_eval(s, s.length, 0, 0, (info, res) => {
			var t = "";
			var w = info.fetch(1);
			for (var i=0; i<w.length; i++) {
				if (w[i] == '\t') t += "\t";
			}
			res.append("\n"+t+@"[Compact, CCode (ref_function = \"$(pfx)_retain\", unref_function = \"$(pfx)_release\")]\n");
			res.append(t+@"public class $(klass) {\n");
			res.append(t+"\tpublic int ref_count = 1;\n");
			res.append(t+@"\tpublic unowned $(klass) retain() {\n");
			res.append(t+"\t\tGLib.AtomicInt.add (ref ref_count, 1);\n");
			res.append(t+"\t\treturn this;\n");
			res.append(t+"\t}\n");
			res.append(t+"\tpublic void release() {\n");
			res.append(t+"\t\tif (GLib.AtomicInt.dec_and_test (ref ref_count)) this.free ();\n");
			res.append(t+"\t}\n");
			res.append(t+"\tpublic extern void free();\n"+t);
			return true;
		});
	
	} else {
		/**
		 * The superclass is a base Compact class,
		 * we just need to mark it with the Compact attribute.
		 */
		return rxCompact.replace_eval(s, s.length, 0, 0, (info, res) => {
			var t = "";
			var w = info.fetch(1);
			for (var i=0; i<w.length; i++) {
				if (w[i] == '\t') t += "\t";
			}
			res.append("\n"+t+"[Compact]\n");
			res.append(t+info.fetch(0)+"\n");
			return true;
		});
	}
}

/**
 * generateMacroDependency
 * 
 * @param string line
 * @param HashMap<string,string> symtbl
 * @param StringBuilder dst
 */
public bool generateMacroDependency(string line, HashMap<string,string> symtbl, StringBuilder dst) {
	var flag = false;
	var t = /\#define\s+_([_a-z0-9]+)_release0/
	.replace_eval(line, line.length, 0, 0, (info, result) => {

		var p1 = info.fetch(1);
		if (symtbl.has_key(p1)) {
			flag = true;
			var type = symtbl.@get(p1);
			dst.append(@"// symtbl.1 $(p1)\n");
			dst.append(@"void $(p1)_release ($(type)* self);\n");
			dst.append(@"void $(p1)_free ($(type)* self);\n");
			dst.append(@"$(type)* $(p1)_retain ($(type)* self);\n");
		}
		return true;
	});
	return flag;
}

/**
 * generateFunctionDependency
 * 
 * @param string line
 * @param HashMap<string,string> symtbl
 * @param StringBuilder dst
 */
public bool generateFunctionDependency(string line, HashMap<string,string> symtbl, StringBuilder dst) {
	var flag = false;
	var t = /static\s+void\s+_([_a-z0-9]+)_release0_/
	.replace_eval(line, line.length, 0, 0, (info, result) => {
		
		var p1 = info.fetch(1);
		if (symtbl.has_key(p1)) {
			flag = true;
			var type = symtbl.@get(p1);
			dst.append(@"// symtbl.2 $(p1)\n");
			dst.append(@"void $(p1)_release ($(type)* self);\n");
			dst.append(@"void $(p1)_free ($(type)* self);\n");
			dst.append(@"$(type)* $(p1)_retain ($(type)* self);\n");
	}
		return true;
	});
	return flag;	
}

/**
 * generateBaseDependency
 * 
 * @param string line
 * @param HashMap<string,string> symtbl
 * @param StringBuilder dst
 */
public bool generateBaseDependency(string line, HashMap<string,string> symtbl, StringBuilder dst) {
	var flag = false;
	var t = /(\w+)\*\s+([_a-z0-9]+)_new/.replace_eval(line, line.length, 0, 0, (info, result) => {
		
		var p1 = info.fetch(1);
		var p2 = info.fetch(2);
		if (symtbl.has_key(p1)) {
			var type = symtbl.@get(p1);
			dst.append(@"// symtbl.3 $(p1) / $(p2)\n");

			var t1 = new Regex(@"$(type)*\\s+$(p2)_retain\\s+($(type)*\\s+self);");
			if (!t1.match(line)) {
				flag = true;
				dst.append(@"$(type)* $(p2)_retain ($(type)* self);\n");
			}

			var t2 = new Regex(@"void\\s+$(p2)_release\\s+($(type)*\\s+self);");
			if (!t2.match(line)) {
				flag = true;
				dst.append(@"void $(p2)_release ($(type)* self);\n");
			}

		}
		return true;
	});
	return flag;
}