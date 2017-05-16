#ifndef _GLIB_OBJECT_H_
#define _GLIB_OBJECT_H_
#define GType int
#define g_enum_register_static(x,y) 0

#define g_boxed_type_register_static(x, y, z) g_str_hash(x)
// static inline void g_type_init() {}
// static inline void g_boxed() {}
// typedef gpointer        (*GBoxedCopyFunc)       (gpointer s);
// typedef void            (*GBoxedFreeFunc)       (gpointer s);

/* empty */
typedef struct {
	int x;
	const char *n;
	const char *m;
} GEnumValue;



#endif /* _GLIB_OBJECT_H_ */
