/* LGPL3 - posixvala glib replacement - 2013 - pancake@nopcode.org */

#define g_once_init_enter(x) ((*(x) == 0) ? TRUE : FALSE)
#define g_once_init_leave(x,y) (*(x) = y)
