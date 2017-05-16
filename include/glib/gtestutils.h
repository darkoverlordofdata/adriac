/* LGPL3 - posixvala glib replacement - 2013 - pancake@nopcode.org */

#define g_assertion_message_expr(domain,file,line,func,expr)		\
do {									\
	if (!expr) {							\
		fprintf(stderr, "**\n%s:%s:%d:%s: %s\n",		\
			domain, file, line, func,			\
			"code should not be reached");			\
	} else {							\
		fprintf(stderr, "**\n%s:%s:%d:%s: "			\
				"assertion failed: (%s)\n",		\
				domain, file, line, func, expr);	\
	}								\
	abort();							\
} while (0)





