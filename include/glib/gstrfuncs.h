#ifndef __GLIB_STRFUNCS_H__
#define __GLIB_STRFUNCS_H__

/* Functions like the ones in <ctype.h> that are not affected by locale. */
typedef enum {
  G_ASCII_ALNUM  = 1 << 0,
  G_ASCII_ALPHA  = 1 << 1,
  G_ASCII_CNTRL  = 1 << 2,
  G_ASCII_DIGIT  = 1 << 3,
  G_ASCII_GRAPH  = 1 << 4,
  G_ASCII_LOWER  = 1 << 5,
  G_ASCII_PRINT  = 1 << 6,
  G_ASCII_PUNCT  = 1 << 7,
  G_ASCII_SPACE  = 1 << 8,
  G_ASCII_UPPER  = 1 << 9,
  G_ASCII_XDIGIT = 1 << 10
} GAsciiType;

GLIB_VAR const guint16 * const g_ascii_table;

#define g_ascii_isalnum(c) \
  ((g_ascii_table[(guchar) (c)] & G_ASCII_ALNUM) != 0)

#define g_ascii_isalpha(c) \
  ((g_ascii_table[(guchar) (c)] & G_ASCII_ALPHA) != 0)

#define g_ascii_iscntrl(c) \
  ((g_ascii_table[(guchar) (c)] & G_ASCII_CNTRL) != 0)

#define g_ascii_isdigit(c) \
  ((g_ascii_table[(guchar) (c)] & G_ASCII_DIGIT) != 0)

#define g_ascii_isgraph(c) \
  ((g_ascii_table[(guchar) (c)] & G_ASCII_GRAPH) != 0)

#define g_ascii_islower(c) \
  ((g_ascii_table[(guchar) (c)] & G_ASCII_LOWER) != 0)

#define g_ascii_isprint(c) \
  ((g_ascii_table[(guchar) (c)] & G_ASCII_PRINT) != 0)

#define g_ascii_ispunct(c) \
  ((g_ascii_table[(guchar) (c)] & G_ASCII_PUNCT) != 0)

#define g_ascii_isspace(c) \
  ((g_ascii_table[(guchar) (c)] & G_ASCII_SPACE) != 0)

#define g_ascii_isupper(c) \
  ((g_ascii_table[(guchar) (c)] & G_ASCII_UPPER) != 0)

#define g_ascii_isxdigit(c) \
  ((g_ascii_table[(guchar) (c)] & G_ASCII_XDIGIT) != 0)

//static gint string_last_index_of (const gchar* self, const gchar* needle, gint start_index) {
//	_tmp2_ = g_strrstr (((gchar*) self) + _tmp0_, (gchar*) _tmp1_);
/**
 * g_strdup:
 * @str: (nullable): the string to duplicate
 *
 * Duplicates a string. If @str is %NULL it returns %NULL.
 * The returned string should be freed with g_free()
 * when no longer needed.
 *
 * Returns: a newly-allocated copy of @str
 */
static inline gchar*
g_strdup (const gchar *str)
{
  gchar *new_str;
  gsize length;

  if (str)
    {
      length = strlen (str) + 1;
      new_str = g_new (char, length);
      memcpy (new_str, str, length);
    }
  else
    new_str = NULL;

  return new_str;
}
/**
 * g_strrstr:
 * @haystack: a nul-terminated string
 * @needle: the nul-terminated string to search for
 *
 * Searches the string @haystack for the last occurrence
 * of the string @needle.
 *
 * Returns: a pointer to the found occurrence, or
 *    %NULL if not found.
 */
static inline gchar *
g_strrstr (const gchar *haystack,
           const gchar *needle)
{
  gsize i;
  gsize needle_len;
  gsize haystack_len;
  const gchar *p;

  g_return_val_if_fail (haystack != NULL, NULL);
  g_return_val_if_fail (needle != NULL, NULL);

  needle_len = strlen (needle);
  haystack_len = strlen (haystack);

  if (needle_len == 0)
    return (gchar *)haystack;

  if (haystack_len < needle_len)
    return NULL;

  p = haystack + haystack_len - needle_len;

  while (p >= haystack)
    {
      for (i = 0; i < needle_len; i++)
        if (p[i] != needle[i])
          goto next;

      return (gchar *)p;

    next:
      p--;
    }

  return NULL;
}


#endif /* __GLIB_STRFUNCS_H__ */
