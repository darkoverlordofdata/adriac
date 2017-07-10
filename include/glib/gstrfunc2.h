/* LGPL3 - posixvala glib replacement - 2013 - pancake@nopcode.org */

#ifndef __GLIB_STRFUNC2_H__
#define __GLIB_STRFUNC2_H__

/* For vsnprintf(3) */
#ifndef _POSIX_C_SOURCE
#define _POSIX_C_SOURCE 200112L
#endif /* _POSIX_C_SOURCE */

#include <stdarg.h>

/** @return a pointer to the next unicode point in a _valid_ unicode string or null if s points to the last character. */
static inline const gchar* g_utf8_next_char (const gchar *s) {
	unsigned char ch = *s;
	if (ch == '\0') return NULL;
	if (ch < 0x80) return s+1;
	if (ch < 0xE0) return s + 2;
	if (ch < 0xF0) return s + 3;
	if (ch < 0xF5) return s + 4;
	return NULL;
}


// static inline char *g_strdup_printf(const char *fmt, ...) {
// 	unsigned int length;
// 	char *buf = NULL;
// 	va_list ap;
// 	va_start (ap, fmt);
// 	/* Get the length of the result */
// 	length = (unsigned int)vsnprintf(buf, 0, fmt, ap);
// 	/* Must include space for the NULL-terminating byte. */
// 	buf = calloc(length + 1, sizeof(char));
// 	/* Actually create string, copies NULL byte too */
// 	vsnprintf(buf, length + 1, fmt, ap);
// 	va_end (ap);
// 	return buf;
// }

/**
 * g_vasprintf:
 * @string: the return location for the newly-allocated string.
 * @format: a standard printf() format string, but notice
 *          [string precision pitfalls][string-precision]
 * @args: the list of arguments to insert in the output.
 *
 * An implementation of the GNU vasprintf() function which supports 
 * positional parameters, as specified in the Single Unix Specification.
 * This function is similar to g_vsprintf(), except that it allocates a 
 * string to hold the output, instead of putting the output in a buffer 
 * you allocate in advance.
 *
 * Returns: the number of bytes printed.
 *
 * Since: 2.4
 **/
static inline gint 
g_vasprintf (gchar      **string,
	     gchar const *format,
	     va_list      args)
{
  gint len;
  g_return_val_if_fail (string != NULL, -1);

// #if !defined(HAVE_GOOD_PRINTF)

//   len = _g_gnulib_vasprintf (string, format, args);
//   if (len < 0)
//     *string = NULL;

//#el
// #if defined (HAVE_VASPRINTF)

  len = vasprintf (string, format, args);
  if (len < 0)
    *string = NULL;

// #else

//   {
//     va_list args2;

//     G_VA_COPY (args2, args);

//     *string = g_new (gchar, g_printf_string_upper_bound (format, args));

//     len = _g_vsprintf (*string, format, args2);
//     va_end (args2);
//   }
// #endif

  return len;
}
/**
 * g_strdup_vprintf:
 * @format: a standard printf() format string, but notice
 *     [string precision pitfalls][string-precision]
 * @args: the list of parameters to insert into the format string
 *
 * Similar to the standard C vsprintf() function but safer, since it
 * calculates the maximum space required and allocates memory to hold
 * the result. The returned string should be freed with g_free() when
 * no longer needed.
 *
 * See also g_vasprintf(), which offers the same functionality, but
 * additionally returns the length of the allocated string.
 *
 * Returns: a newly-allocated string holding the result
 */
static inline gchar*
g_strdup_vprintf (const gchar *format,
                  va_list      args)
{
  gchar *string = NULL;

  g_vasprintf (&string, format, args);

  return string;
}
/**
 * g_strdup_printf:
 * @format: a standard printf() format string, but notice
 *     [string precision pitfalls][string-precision]
 * @...: the parameters to insert into the format string
 *
 * Similar to the standard C sprintf() function but safer, since it
 * calculates the maximum space required and allocates memory to hold
 * the result. The returned string should be freed with g_free() when no
 * longer needed.
 *
 * Returns: a newly-allocated string holding the result
 */
static inline gchar*
g_strdup_printf (const gchar *format,
                 ...)
{
  gchar *buffer;
  va_list args;

  va_start (args, format);
  buffer = g_strdup_vprintf (format, args);
  va_end (args);

  return buffer;
}


static inline char *g_strconcat(const char *str, ...) {
	int plen, olen;
	const char *p;
	char *out;
	va_list ap;

	va_start (ap, str);
	out = strdup (str);
	olen = strlen (out);
	for (;;) {
        	p = va_arg (ap, char*);
		if (!p) break;
		plen = strlen (p);
		out = realloc (out, plen + olen+1);
		strcpy (out+olen, p);
		olen += plen;
	}
	va_end (ap);
	return out;
}

/**
 * g_strcmp0:
 * @str1: (nullable): a C string or %NULL
 * @str2: (nullable): another C string or %NULL
 *
 * Compares @str1 and @str2 like strcmp(). Handles %NULL
 * gracefully by sorting it before non-%NULL strings.
 * Comparing two %NULL pointers returns 0.
 *
 * Returns: an integer less than, equal to, or greater than zero, if @str1 is <, == or > than @str2.
 *
 * Since: 2.16
 */
static inline int g_strcmp0 (const char *str1, const char *str2)
{
  if (!str1)
    return -(str1 != str2);
  if (!str2)
    return str1 != str2;
  return strcmp (str1, str2);
}

/**
 * g_strndup:
 * @str: the string to duplicate
 * @n: the maximum number of bytes to copy from @str
 *
 * Duplicates the first @n bytes of a string, returning a newly-allocated
 * buffer @n + 1 bytes long which will always be nul-terminated. If @str
 * is less than @n bytes long the buffer is padded with nuls. If @str is
 * %NULL it returns %NULL. The returned value should be freed when no longer
 * needed.
 *
 * To copy a number of characters from a UTF-8 encoded string,
 * use g_utf8_strncpy() instead.
 *
 * Returns: a newly-allocated buffer containing the first @n bytes
 *     of @str, nul-terminated
 */
static inline gchar *g_strndup (const gchar *str, gsize n)
{
  gchar *new_str;

  if (str)
    {
      new_str = g_new (gchar, n + 1);
      strncpy (new_str, str, n);
      new_str[n] = '\0';
    }
  else
    new_str = NULL;

  return new_str;
}

/**
 * g_ascii_tolower:
 * @c: any character
 *
 * Convert a character to ASCII lower case.
 *
 * Unlike the standard C library tolower() function, this only
 * recognizes standard ASCII letters and ignores the locale, returning
 * all non-ASCII characters unchanged, even if they are lower case
 * letters in a particular character set. Also unlike the standard
 * library function, this takes and returns a char, not an int, so
 * don't call it on %EOF but no need to worry about casting to #guchar
 * before passing a possibly non-ASCII character in.
 *
 * Returns: the result of converting @c to lower case. If @c is
 *     not an ASCII upper case letter, @c is returned unchanged.
 */
static inline gchar g_ascii_tolower (gchar c)
{
	return (c >= 'A' && c <= 'Z') ? c - 'A' + 'a' : c;
}
/**
 * g_ascii_toupper:
 * @c: any character
 *
 * Convert a character to ASCII upper case.
 *
 * Unlike the standard C library toupper() function, this only
 * recognizes standard ASCII letters and ignores the locale, returning
 * all non-ASCII characters unchanged, even if they are upper case
 * letters in a particular character set. Also unlike the standard
 * library function, this takes and returns a char, not an int, so
 * don't call it on %EOF but no need to worry about casting to #guchar
 * before passing a possibly non-ASCII character in.
 *
 * Returns: the result of converting @c to upper case. If @c is not
 *    an ASCII lower case letter, @c is returned unchanged.
 */
static inline gchar g_ascii_toupper (gchar c)
{
	  return (c >= 'a' && c <= 'z') ? c - 'a' + 'A' : c;
}

/**
 * g_ascii_strup:
 * @str: a string
 * @len: length of @str in bytes, or -1 if @str is nul-terminated
 *
 * Converts all lower case ASCII letters to upper case ASCII letters.
 *
 * Returns: a newly allocated string, with all the lower case
 *     characters in @str converted to upper case, with semantics that
 *     exactly match g_ascii_toupper(). (Note that this is unlike the
 *     old g_strup(), which modified the string in place.)
 */
static inline gchar *g_utf8_strup (const gchar *str, gssize len)
{
  gchar *result, *s;

  g_return_val_if_fail (str != NULL, NULL);

  if (len < 0)
    len = strlen (str);

  result = g_strndup (str, len);
  for (s = result; *s; s++) 
    *s = g_ascii_toupper (*s);
  

  return result;
}

/**
 * g_ascii_strdown:
 * @str: a string
 * @len: length of @str in bytes, or -1 if @str is nul-terminated
 *
 * Converts all upper case ASCII letters to lower case ASCII letters.
 *
 * Returns: a newly-allocated string, with all the upper case
 *     characters in @str converted to lower case, with semantics that
 *     exactly match g_ascii_tolower(). (Note that this is unlike the
 *     old g_strdown(), which modified the string in place.)
 */
static inline gchar *g_utf8_strdown (const gchar *str, gssize len)
{
  gchar *result, *s;

  g_return_val_if_fail (str != NULL, NULL);

  if (len < 0)
    len = strlen (str);

  result = g_strndup (str, len);
  for (s = result; *s; s++)
    *s = g_ascii_tolower (*s);

  return result;
}

/**
 * g_strreverse:
 * @string: the string to reverse
 *
 * Reverses all of the bytes in a string. For example,
 * `g_strreverse ("abcdef")` will result in "fedcba".
 *
 * Note that g_strreverse() doesn't work on UTF-8 strings
 * containing multibyte characters. For that purpose, use
 * g_utf8_strreverse().
 *
 * Returns: the same pointer passed in as @string
 */
static inline gchar *g_utf8_strreverse (const gchar *str, gssize len)
{
  	gchar *result, *s, *t;

  	g_return_val_if_fail (str != NULL, NULL);

  	if (len < 0) len = strlen (str);
		result = g_strndup (str, len);
		s = result;
		t = result + strlen (result) - 1;

    while (s < t)
    {
          gchar c;

          c = *s;
          *s = *t;
          s++;
          *t = c;
          t--;
    }
  return result;
}
/**
 * g_stpcpy:
 * @dest: destination buffer.
 * @src: source string.
 *
 * Copies a nul-terminated string into the dest buffer, include the
 * trailing nul, and return a pointer to the trailing nul byte.
 * This is useful for concatenating multiple strings together
 * without having to repeatedly scan for the end.
 *
 * Returns: a pointer to trailing nul byte.
 **/
static inline gchar *g_stpcpy (gchar *dest, const gchar *src)
{
#ifdef HAVE_STPCPY
  g_return_val_if_fail (dest != NULL, NULL);
  g_return_val_if_fail (src != NULL, NULL);
  return stpcpy (dest, src);
#else
  gchar *d = dest;
  const gchar *s = src;

  g_return_val_if_fail (dest != NULL, NULL);
  g_return_val_if_fail (src != NULL, NULL);
  do
    *d++ = *s;
  while (*s++ != '\0');

  return d - 1;
#endif
}

/**
 * g_strjoin:
 * @separator: (nullable): a string to insert between each of the
 *     strings, or %NULL
 * @...: a %NULL-terminated list of strings to join
 *
 * Joins a number of strings together to form one long string, with the
 * optional @separator inserted between each of them. The returned string
 * should be freed with g_free().
 *
 * Returns: a newly-allocated string containing all of the strings joined
 *     together, with @separator between them
 */
static inline gchar *g_strjoin (const gchar *separator, ...)
{
  gchar *string, *s;
  va_list args;
  gsize len;
  gsize separator_len;
  gchar *ptr;

  if (separator == NULL)
    separator = "";

  separator_len = strlen (separator);

  va_start (args, separator);

  s = va_arg (args, gchar*);

  if (s)
    {
      /* First part, getting length */
      len = 1 + strlen (s);

      s = va_arg (args, gchar*);
      while (s)
        {
          len += separator_len + strlen (s);
          s = va_arg (args, gchar*);
        }
      va_end (args);

      /* Second part, building string */
      string = g_new (gchar, len);

      va_start (args, separator);

      s = va_arg (args, gchar*);
      ptr = g_stpcpy (string, s);

      s = va_arg (args, gchar*);
      while (s)
        {
          ptr = g_stpcpy (ptr, separator);
          ptr = g_stpcpy (ptr, s);
          s = va_arg (args, gchar*);
        }
    }
  else
    string = g_strdup ("");

  va_end (args);

  return string;
}


/**
 * g_strsplit:
 * @string: a string to split
 * @delimiter: a string which specifies the places at which to split
 *     the string. The delimiter is not included in any of the resulting
 *     strings, unless @max_tokens is reached.
 * @max_tokens: the maximum number of pieces to split @string into.
 *     If this is less than 1, the string is split completely.
 *
 * Splits a string into a maximum of @max_tokens pieces, using the given
 * @delimiter. If @max_tokens is reached, the remainder of @string is
 * appended to the last token.
 *
 * As an example, the result of g_strsplit (":a:bc::d:", ":", -1) is a
 * %NULL-terminated vector containing the six strings "", "a", "bc", "", "d"
 * and "".
 *
 * As a special case, the result of splitting the empty string "" is an empty
 * vector, not a vector containing a single string. The reason for this
 * special case is that being able to represent a empty vector is typically
 * more useful than consistent handling of empty elements. If you do need
 * to represent empty elements, you'll need to check for the empty string
 * before calling g_strsplit().
 *
 * Returns: a newly-allocated %NULL-terminated array of strings. Use
 *    g_strfreev() to free it.
 */
static inline gchar**
g_strsplit (const gchar *string,
            const gchar *delimiter,
            gint         max_tokens)
{
  GSList *string_list = NULL, *slist;
  gchar **str_array, *s;
  guint n = 0;
  const gchar *remainder;

  g_return_val_if_fail (string != NULL, NULL);
  g_return_val_if_fail (delimiter != NULL, NULL);
  g_return_val_if_fail (delimiter[0] != '\0', NULL);

  if (max_tokens < 1)
    max_tokens = G_MAXINT;

  remainder = string;
  s = strstr (remainder, delimiter);
  if (s)
    {
      gsize delimiter_len = strlen (delimiter);

      while (--max_tokens && s)
        {
          gsize len;

          len = s - remainder;
          string_list = g_slist_prepend (string_list,
                                         g_strndup (remainder, len));
          n++;
          remainder = s + delimiter_len;
          s = strstr (remainder, delimiter);
        }
    }
  if (*string)
    {
      n++;
      string_list = g_slist_prepend (string_list, g_strdup (remainder));
    }

  str_array = g_new (gchar*, n + 1);

  str_array[n--] = NULL;
  for (slist = string_list; slist; slist = slist->next)
    str_array[n--] = slist->data;

  g_slist_free (string_list);

  return str_array;
}


#endif /* __GLIB_STRFUNC2_H__ */

