/* LGPL3 - posixvala glib replacement - 2013 - pancake@nopcode.org */

#define g_return_if_fail(x) if(!(x)) return;
#define g_return_val_if_fail(x,y) if (!(x)) return y;
#define G_LOG_DOMAIN "ERROR"
#define g_print printf
#define g_critical printf
#define g_warning printf
#define g_warn_if_fail printf


