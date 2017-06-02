#ifndef __GLIB_STRFUNCS_H__
#define __GLIB_STRFUNCS_H__


#define G_ASCII_DTOSTR_BUF_SIZE (29 + 10)
static gchar *               g_ascii_dtostr   (gchar        *buffer,
					gint          buf_len,
					gdouble       d);

static gchar *               g_ascii_formatd  (gchar        *buffer,
					gint          buf_len,
					const gchar  *format,
					gdouble       d);

/* removes leading spaces */
static gchar*                g_strchug        (gchar        *string);
/* removes trailing spaces */
static gchar*                g_strchomp       (gchar        *string);

#define _g_snprintf  snprintf
#define g_strstrip( string )	g_strchomp (g_strchug (string))


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

static const guint16 ascii_table_data[256] = {
  0x004, 0x004, 0x004, 0x004, 0x004, 0x004, 0x004, 0x004,
  0x004, 0x104, 0x104, 0x004, 0x104, 0x104, 0x004, 0x004,
  0x004, 0x004, 0x004, 0x004, 0x004, 0x004, 0x004, 0x004,
  0x004, 0x004, 0x004, 0x004, 0x004, 0x004, 0x004, 0x004,
  0x140, 0x0d0, 0x0d0, 0x0d0, 0x0d0, 0x0d0, 0x0d0, 0x0d0,
  0x0d0, 0x0d0, 0x0d0, 0x0d0, 0x0d0, 0x0d0, 0x0d0, 0x0d0,
  0x459, 0x459, 0x459, 0x459, 0x459, 0x459, 0x459, 0x459,
  0x459, 0x459, 0x0d0, 0x0d0, 0x0d0, 0x0d0, 0x0d0, 0x0d0,
  0x0d0, 0x653, 0x653, 0x653, 0x653, 0x653, 0x653, 0x253,
  0x253, 0x253, 0x253, 0x253, 0x253, 0x253, 0x253, 0x253,
  0x253, 0x253, 0x253, 0x253, 0x253, 0x253, 0x253, 0x253,
  0x253, 0x253, 0x253, 0x0d0, 0x0d0, 0x0d0, 0x0d0, 0x0d0,
  0x0d0, 0x473, 0x473, 0x473, 0x473, 0x473, 0x473, 0x073,
  0x073, 0x073, 0x073, 0x073, 0x073, 0x073, 0x073, 0x073,
  0x073, 0x073, 0x073, 0x073, 0x073, 0x073, 0x073, 0x073,
  0x073, 0x073, 0x073, 0x0d0, 0x0d0, 0x0d0, 0x0d0, 0x004
  /* the upper 128 are all zeroes */
};

//GLIB_VAR 
static const guint16 * const g_ascii_table = ascii_table_data;

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


/**
 * g_ascii_strtod:
 * @nptr:    the string to convert to a numeric value.
 * @endptr:  (out) (transfer none) (optional): if non-%NULL, it returns the
 *           character after the last character used in the conversion.
 *
 * Converts a string to a #gdouble value.
 *
 * This function behaves like the standard strtod() function
 * does in the C locale. It does this without actually changing
 * the current locale, since that would not be thread-safe.
 * A limitation of the implementation is that this function
 * will still accept localized versions of infinities and NANs.
 *
 * This function is typically used when reading configuration
 * files or other non-user input that should be locale independent.
 * To handle input from the user you should normally use the
 * locale-sensitive system strtod() function.
 *
 * To convert from a #gdouble to a string in a locale-insensitive
 * way, use g_ascii_dtostr().
 *
 * If the correct value would cause overflow, plus or minus %HUGE_VAL
 * is returned (according to the sign of the value), and %ERANGE is
 * stored in %errno. If the correct value would cause underflow,
 * zero is returned and %ERANGE is stored in %errno.
 *
 * This function resets %errno before calling strtod() so that
 * you can reliably detect overflow and underflow.
 *
 * Returns: the #gdouble value.
 */
static inline gdouble
g_ascii_strtod (const gchar *nptr,
                gchar      **endptr)
{
#ifdef USE_XLOCALE

  g_return_val_if_fail (nptr != NULL, 0);

  errno = 0;

  return strtod_l (nptr, endptr, get_C_locale ());

#else

  gchar *fail_pos;
  gdouble val;
#ifndef __BIONIC__
  struct lconv *locale_data;
#endif
  const char *decimal_point;
  int decimal_point_len;
  const char *p, *decimal_point_pos;
  const char *end = NULL; /* Silence gcc */
  int strtod_errno;

  g_return_val_if_fail (nptr != NULL, 0);

  fail_pos = NULL;

  decimal_point = ".";
  decimal_point_len = 1;

  assert (decimal_point_len != 0);

  decimal_point_pos = NULL;
  end = NULL;

  if (decimal_point[0] != '.' ||
      decimal_point[1] != 0)
    {
      p = nptr;
      /* Skip leading space */
      while (g_ascii_isspace (*p))
        p++;

      /* Skip leading optional sign */
      if (*p == '+' || *p == '-')
        p++;

      if (p[0] == '0' &&
          (p[1] == 'x' || p[1] == 'X'))
        {
          p += 2;
          /* HEX - find the (optional) decimal point */

          while (g_ascii_isxdigit (*p))
            p++;

          if (*p == '.')
            decimal_point_pos = p++;

          while (g_ascii_isxdigit (*p))
            p++;

          if (*p == 'p' || *p == 'P')
            p++;
          if (*p == '+' || *p == '-')
            p++;
          while (g_ascii_isdigit (*p))
            p++;

          end = p;
        }
      else if (g_ascii_isdigit (*p) || *p == '.')
        {
          while (g_ascii_isdigit (*p))
            p++;

          if (*p == '.')
            decimal_point_pos = p++;

          while (g_ascii_isdigit (*p))
            p++;

          if (*p == 'e' || *p == 'E')
            p++;
          if (*p == '+' || *p == '-')
            p++;
          while (g_ascii_isdigit (*p))
            p++;

          end = p;
        }
      /* For the other cases, we need not convert the decimal point */
    }

  if (decimal_point_pos)
    {
      char *copy, *c;

      /* We need to convert the '.' to the locale specific decimal point */
      copy = g_malloc (end - nptr + 1 + decimal_point_len);

      c = copy;
      memcpy (c, nptr, decimal_point_pos - nptr);
      c += decimal_point_pos - nptr;
      memcpy (c, decimal_point, decimal_point_len);
      c += decimal_point_len;
      memcpy (c, decimal_point_pos + 1, end - (decimal_point_pos + 1));
      c += end - (decimal_point_pos + 1);
      *c = 0;

      errno = 0;
      val = strtod (copy, &fail_pos);
      strtod_errno = errno;

      if (fail_pos)
        {
          if (fail_pos - copy > decimal_point_pos - nptr)
            fail_pos = (char *)nptr + (fail_pos - copy) - (decimal_point_len - 1);
          else
            fail_pos = (char *)nptr + (fail_pos - copy);
        }

      g_free (copy);

    }
  else if (end)
    {
      char *copy;

      copy = g_malloc (end - (char *)nptr + 1);
      memcpy (copy, nptr, end - nptr);
      *(copy + (end - (char *)nptr)) = 0;

      errno = 0;
      val = strtod (copy, &fail_pos);
      strtod_errno = errno;

      if (fail_pos)
        {
          fail_pos = (char *)nptr + (fail_pos - copy);
        }

      g_free (copy);
    }
  else
    {
      errno = 0;
      val = strtod (nptr, &fail_pos);
      strtod_errno = errno;
    }

  if (endptr)
    *endptr = fail_pos;

  errno = strtod_errno;

  return val;
#endif
}

/**
 * g_ascii_dtostr:
 * @buffer: A buffer to place the resulting string in
 * @buf_len: The length of the buffer.
 * @d: The #gdouble to convert
 *
 * Converts a #gdouble to a string, using the '.' as
 * decimal point.
 *
 * This function generates enough precision that converting
 * the string back using g_ascii_strtod() gives the same machine-number
 * (on machines with IEEE compatible 64bit doubles). It is
 * guaranteed that the size of the resulting string will never
 * be larger than @G_ASCII_DTOSTR_BUF_SIZE bytes, including the terminating
 * nul character, which is always added.
 *
 * Returns: The pointer to the buffer with the converted string.
 **/
static inline gchar *
g_ascii_dtostr (gchar       *buffer,
                gint         buf_len,
                gdouble      d)
{
  return g_ascii_formatd (buffer, buf_len, "%.17g", d);
}

/**
 * g_ascii_formatd:
 * @buffer: A buffer to place the resulting string in
 * @buf_len: The length of the buffer.
 * @format: The printf()-style format to use for the
 *          code to use for converting.
 * @d: The #gdouble to convert
 *
 * Converts a #gdouble to a string, using the '.' as
 * decimal point. To format the number you pass in
 * a printf()-style format string. Allowed conversion
 * specifiers are 'e', 'E', 'f', 'F', 'g' and 'G'.
 *
 * The returned buffer is guaranteed to be nul-terminated.
 *
 * If you just want to want to serialize the value into a
 * string, use g_ascii_dtostr().
 *
 * Returns: The pointer to the buffer with the converted string.
 */
static inline gchar *
g_ascii_formatd (gchar       *buffer,
                 gint         buf_len,
                 const gchar *format,
                 gdouble      d)
{
/*
#ifdef USE_XLOCALE
  locale_t old_locale;

  old_locale = uselocale (get_C_locale ());
   _g_snprintf (buffer, buf_len, format, d);
  uselocale (old_locale);

  return buffer;
#else
#ifndef __BIONIC__
  struct lconv *locale_data;
#endif
*/
  const char *decimal_point;
  int decimal_point_len;
  gchar *p;
  int rest_len;
  gchar format_char;

  g_return_val_if_fail (buffer != NULL, NULL);
  g_return_val_if_fail (format[0] == '%', NULL);
  g_return_val_if_fail (strpbrk (format + 1, "'l%") == NULL, NULL);

  format_char = format[strlen (format) - 1];

  g_return_val_if_fail (format_char == 'e' || format_char == 'E' ||
                        format_char == 'f' || format_char == 'F' ||
                        format_char == 'g' || format_char == 'G',
                        NULL);

  if (format[0] != '%')
    return NULL;

  if (strpbrk (format + 1, "'l%"))
    return NULL;

  if (!(format_char == 'e' || format_char == 'E' ||
        format_char == 'f' || format_char == 'F' ||
        format_char == 'g' || format_char == 'G'))
    return NULL;

  _g_snprintf (buffer, buf_len, format, d);
/*
#ifndef __BIONIC__
  locale_data = localeconv ();
  decimal_point = locale_data->decimal_point;
  decimal_point_len = strlen (decimal_point);
*/
//#else
  decimal_point = ".";
  decimal_point_len = 1;
//#endif

  assert (decimal_point_len != 0);

  if (decimal_point[0] != '.' ||
      decimal_point[1] != 0)
    {
      p = buffer;

      while (g_ascii_isspace (*p))
        p++;

      if (*p == '+' || *p == '-')
        p++;

      while (isdigit ((guchar)*p))
        p++;

      if (strncmp (p, decimal_point, decimal_point_len) == 0)
        {
          *p = '.';
          p++;
          if (decimal_point_len > 1)
            {
              rest_len = strlen (p + (decimal_point_len-1));
              memmove (p, p + (decimal_point_len-1), rest_len);
              p[rest_len] = 0;
            }
        }
    }

  return buffer;
//#endif
}

/**
 * g_strchug:
 * @string: a string to remove the leading whitespace from
 *
 * Removes leading whitespace from a string, by moving the rest
 * of the characters forward.
 *
 * This function doesn't allocate or reallocate any memory;
 * it modifies @string in place. Therefore, it cannot be used on
 * statically allocated strings.
 *
 * The pointer to @string is returned to allow the nesting of functions.
 *
 * Also see g_strchomp() and g_strstrip().
 *
 * Returns: @string
 */
static inline gchar *
g_strchug (gchar *string)
{
  guchar *start;

  g_return_val_if_fail (string != NULL, NULL);

  for (start = (guchar*) string; *start && g_ascii_isspace (*start); start++)
    ;

  memmove (string, start, strlen ((gchar *) start) + 1);

  return string;
}

/**
 * g_strchomp:
 * @string: a string to remove the trailing whitespace from
 *
 * Removes trailing whitespace from a string.
 *
 * This function doesn't allocate or reallocate any memory;
 * it modifies @string in place. Therefore, it cannot be used
 * on statically allocated strings.
 *
 * The pointer to @string is returned to allow the nesting of functions.
 *
 * Also see g_strchug() and g_strstrip().
 *
 * Returns: @string
 */
static inline gchar *
g_strchomp (gchar *string)
{
  gsize len;

  g_return_val_if_fail (string != NULL, NULL);

  len = strlen (string);
  while (len--)
    {
      if (g_ascii_isspace ((guchar) string[len]))
        string[len] = '\0';
      else
        break;
    }

  return string;
}


#endif /* __GLIB_STRFUNCS_H__ */
