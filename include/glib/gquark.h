/* LGPL3 - posixvala glib replacement - 2013 - pancake@nopcode.org */

#define GQuark uintptr_t
#define g_quark_from_static_string(x) ((GQuark)(size_t)(x))

static inline GQuark  quark_new (gchar *string);
typedef struct _GHashTable GHashTable;

//G_LOCK_DEFINE_STATIC (quark_global);
static GHashTable    *quark_ht = NULL;
static gchar        **quarks = NULL;
static gint           quark_seq_id = 0;
static gchar         *quark_block = NULL;
static gint           quark_block_offset = 0;


/* HOLDS: quark_global_lock */
static inline GQuark
quark_from_string (const gchar *string,
                   gboolean     duplicate)
{
  GQuark quark = 0;

  //quark = GPOINTER_TO_UINT (g_hash_table_lookup (quark_ht, string));

  //if (!quark)
  //  {
  //    quark = quark_new (duplicate ? quark_strdup (string) : (gchar *)string);
  //    TRACE(GLIB_QUARK_NEW(string, quark));
  //  }

  return quark;
}


/**
 * g_quark_from_string:
 * @string: (nullable): a string
 *
 * Gets the #GQuark identifying the given string. If the string does
 * not currently have an associated #GQuark, a new #GQuark is created,
 * using a copy of the string.
 *
 * Returns: the #GQuark identifying the string, or 0 if @string is %NULL
 */
static inline GQuark
g_quark_from_string (const gchar *string)
{
  GQuark quark;

  if (!string)
    return 0;

  //G_LOCK (quark_global);
  quark = quark_from_string (string, TRUE);
  //G_UNLOCK (quark_global);

  return quark;
}


