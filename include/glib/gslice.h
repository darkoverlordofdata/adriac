/* LGPL3 - posixvala glib replacement - 2013 - pancake@nopcode.org */

#define g_new0(x,y) (x*)calloc (y, sizeof(x));
#define g_new(x, y)	(x*)malloc (sizeof(x)*y);	
#define g_renew(x,m,y) (x*)realloc (m, sizeof(x)*y); 
#define g_slice_new(x) (x*)calloc (1, sizeof(x));
#define g_slice_new0(x) (x*)calloc (1, sizeof(x));
#define g_slice_free(x,y) free(y)
