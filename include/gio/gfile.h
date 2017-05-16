/* LGPL3 - posixvala gio replacement - 2017 - darkoverlordofdata */

#ifndef __G_FILE_H__
#define __G_FILE_H__

#if !defined (__GIO_GIO_H_INSIDE__) && !defined (GIO_COMPILATION)
#error "Only <gio/gio.h> can be included directly."
#endif

static inline GFile *g_file_new_for_path (const char *path)
{
  g_return_val_if_fail (path != NULL, NULL);

  printf("FILE: %s\n", path);
  return NULL;
}

static inline gboolean g_file_query_exists (GFile *file, GCancellable *cancellable)
{
  return FALSE;
}




#endif /* __G_FILE_H__ */
