/*
 * Copyright © 2011 Ryan Lortie
 *
 * This library is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * licence, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Author: Ryan Lortie <desrt@desrt.ca>
 */

#ifndef __G_ATOMIC_H__
#define __G_ATOMIC_H__

// #if !defined (__GLIB_H_INSIDE__) && !defined (GLIB_COMPILATION)
// #error "Only <glib.h> can be included directly."
// #endif

// #include <glib/gtypes.h>

G_BEGIN_DECLS

static gint                    g_atomic_int_get                      (const volatile gint *atomic);
static void                    g_atomic_int_set                      (volatile gint  *atomic,
                                                               gint            newval);
static void                    g_atomic_int_inc                      (volatile gint  *atomic);
static gboolean                g_atomic_int_dec_and_test             (volatile gint  *atomic);
static gboolean                g_atomic_int_compare_and_exchange     (volatile gint  *atomic,
                                                               gint            oldval,
                                                               gint            newval);
static gint                    g_atomic_int_add                      (volatile gint  *atomic,
                                                               gint            val);
static guint                   g_atomic_int_and                      (volatile guint *atomic,
                                                               guint           val);
static guint                   g_atomic_int_or                       (volatile guint *atomic,
                                                               guint           val);
static guint                   g_atomic_int_xor                      (volatile guint *atomic,
                                                               guint           val);

static gpointer                g_atomic_pointer_get                  (const volatile void *atomic);
static void                    g_atomic_pointer_set                  (volatile void  *atomic,
                                                               gpointer        newval);
static gboolean                g_atomic_pointer_compare_and_exchange (volatile void  *atomic,
                                                               gpointer        oldval,
                                                               gpointer        newval);
static gssize                  g_atomic_pointer_add                  (volatile void  *atomic,
                                                               gssize          val);
static gsize                   g_atomic_pointer_and                  (volatile void  *atomic,
                                                               gsize           val);
static gsize                   g_atomic_pointer_or                   (volatile void  *atomic,
                                                               gsize           val);
static gsize                   g_atomic_pointer_xor                  (volatile void  *atomic,
                                                               gsize           val);


G_END_DECLS

#if defined(G_ATOMIC_LOCK_FREE) && defined(__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4)

/* We prefer the new C11-style atomic extension of GCC if available */
#if defined(__ATOMIC_SEQ_CST) && !defined(__clang__)

/* This assumes sizeof(int) is 4: gatomic.c statically
 * asserts that (using G_STATIC_ASSERT at top-level in a header was
 * problematic, see #730932) */

#define g_atomic_int_get(atomic) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gint));                     \
    (void) (0 ? *(atomic) ^ *(atomic) : 0);                                  \
    (gint) __atomic_load_4 ((atomic), __ATOMIC_SEQ_CST);                     \
  }))
#define g_atomic_int_set(atomic, newval) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gint));                     \
    (void) (0 ? *(atomic) ^ (newval) : 0);                                   \
    __atomic_store_4 ((atomic), (newval), __ATOMIC_SEQ_CST);                 \
  }))

#if GLIB_SIZEOF_VOID_P == 8

#define g_atomic_pointer_get(atomic) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gpointer));                 \
    (gpointer) __atomic_load_8 ((atomic), __ATOMIC_SEQ_CST);                 \
  }))
#define g_atomic_pointer_set(atomic, newval) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gpointer));                 \
    (void) (0 ? (gpointer) *(atomic) : 0);                                   \
    __atomic_store_8 ((atomic), (gsize) (newval), __ATOMIC_SEQ_CST);         \
  }))

#else /* GLIB_SIZEOF_VOID_P == 8 */

/* This assumes that if sizeof(void *) is not 8, then it is 4:
 * gatomic.c statically asserts that (using G_STATIC_ASSERT
 * at top-level in a header was problematic, see #730932) */

#define g_atomic_pointer_get(atomic) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gpointer));                 \
    (gpointer) __atomic_load_4 ((atomic), __ATOMIC_SEQ_CST);                 \
  }))
#define g_atomic_pointer_set(atomic, newval) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gpointer));                 \
    (void) (0 ? (gpointer) *(atomic) : 0);                                   \
    __atomic_store_4 ((atomic), (gsize) (newval), __ATOMIC_SEQ_CST);         \
  }))

#endif /* GLIB_SIZEOF_VOID_P == 8 */

#else /* defined(__ATOMIC_SEQ_CST) */

#define g_atomic_int_get(atomic) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gint));                     \
    (void) (0 ? *(atomic) ^ *(atomic) : 0);                                  \
    __sync_synchronize ();                                                   \
    (gint) *(atomic);                                                        \
  }))
#define g_atomic_int_set(atomic, newval) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gint));                     \
    (void) (0 ? *(atomic) ^ (newval) : 0);                                   \
    *(atomic) = (newval);                                                    \
    __sync_synchronize ();                                                   \
  }))
#define g_atomic_pointer_get(atomic) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gpointer));                 \
    __sync_synchronize ();                                                   \
    (gpointer) *(atomic);                                                    \
  }))
#define g_atomic_pointer_set(atomic, newval) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gpointer));                 \
    (void) (0 ? (gpointer) *(atomic) : 0);                                   \
    *(atomic) = (__typeof__ (*(atomic))) (gsize) (newval);                   \
    __sync_synchronize ();                                                   \
  }))

#endif /* !defined(__ATOMIC_SEQ_CST) */

#define g_atomic_int_inc(atomic) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gint));                     \
    (void) (0 ? *(atomic) ^ *(atomic) : 0);                                  \
    (void) __sync_fetch_and_add ((atomic), 1);                               \
  }))
#define g_atomic_int_dec_and_test(atomic) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gint));                     \
    (void) (0 ? *(atomic) ^ *(atomic) : 0);                                  \
    __sync_fetch_and_sub ((atomic), 1) == 1;                                 \
  }))
#define g_atomic_int_compare_and_exchange(atomic, oldval, newval) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gint));                     \
    (void) (0 ? *(atomic) ^ (newval) ^ (oldval) : 0);                        \
    (gboolean) __sync_bool_compare_and_swap ((atomic), (oldval), (newval));  \
  }))
#define g_atomic_int_add(atomic, val) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gint));                     \
    (void) (0 ? *(atomic) ^ (val) : 0);                                      \
    (gint) __sync_fetch_and_add ((atomic), (val));                           \
  }))
#define g_atomic_int_and(atomic, val) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gint));                     \
    (void) (0 ? *(atomic) ^ (val) : 0);                                      \
    (guint) __sync_fetch_and_and ((atomic), (val));                          \
  }))
#define g_atomic_int_or(atomic, val) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gint));                     \
    (void) (0 ? *(atomic) ^ (val) : 0);                                      \
    (guint) __sync_fetch_and_or ((atomic), (val));                           \
  }))
#define g_atomic_int_xor(atomic, val) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gint));                     \
    (void) (0 ? *(atomic) ^ (val) : 0);                                      \
    (guint) __sync_fetch_and_xor ((atomic), (val));                          \
  }))

#define g_atomic_pointer_compare_and_exchange(atomic, oldval, newval) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gpointer));                 \
    (void) (0 ? (gpointer) *(atomic) : 0);                                   \
    (gboolean) __sync_bool_compare_and_swap ((atomic), (oldval), (newval));  \
  }))
#define g_atomic_pointer_add(atomic, val) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gpointer));                 \
    (void) (0 ? (gpointer) *(atomic) : 0);                                   \
    (void) (0 ? (val) ^ (val) : 0);                                          \
    (gssize) __sync_fetch_and_add ((atomic), (val));                         \
  }))
#define g_atomic_pointer_and(atomic, val) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gpointer));                 \
    (void) (0 ? (gpointer) *(atomic) : 0);                                   \
    (void) (0 ? (val) ^ (val) : 0);                                          \
    (gsize) __sync_fetch_and_and ((atomic), (val));                          \
  }))
#define g_atomic_pointer_or(atomic, val) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gpointer));                 \
    (void) (0 ? (gpointer) *(atomic) : 0);                                   \
    (void) (0 ? (val) ^ (val) : 0);                                          \
    (gsize) __sync_fetch_and_or ((atomic), (val));                           \
  }))
#define g_atomic_pointer_xor(atomic, val) \
  (G_GNUC_EXTENSION ({                                                       \
    G_STATIC_ASSERT (sizeof *(atomic) == sizeof (gpointer));                 \
    (void) (0 ? (gpointer) *(atomic) : 0);                                   \
    (void) (0 ? (val) ^ (val) : 0);                                          \
    (gsize) __sync_fetch_and_xor ((atomic), (val));                          \
  }))

#else /* defined(G_ATOMIC_LOCK_FREE) && defined(__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4) */

#define g_atomic_int_get(atomic) \
  (g_atomic_int_get ((gint *) (atomic)))
#define g_atomic_int_set(atomic, newval) \
  (g_atomic_int_set ((gint *) (atomic), (gint) (newval)))
#define g_atomic_int_compare_and_exchange(atomic, oldval, newval) \
  (g_atomic_int_compare_and_exchange ((gint *) (atomic), (oldval), (newval)))
#define g_atomic_int_add(atomic, val) \
  (g_atomic_int_add ((gint *) (atomic), (val)))
#define g_atomic_int_and(atomic, val) \
  (g_atomic_int_and ((guint *) (atomic), (val)))
#define g_atomic_int_or(atomic, val) \
  (g_atomic_int_or ((guint *) (atomic), (val)))
#define g_atomic_int_xor(atomic, val) \
  (g_atomic_int_xor ((guint *) (atomic), (val)))
#define g_atomic_int_inc(atomic) \
  (g_atomic_int_inc ((gint *) (atomic)))
#define g_atomic_int_dec_and_test(atomic) \
  (g_atomic_int_dec_and_test ((gint *) (atomic)))

#define g_atomic_pointer_get(atomic) \
  (g_atomic_pointer_get (atomic))
#define g_atomic_pointer_set(atomic, newval) \
  (g_atomic_pointer_set ((atomic), (gpointer) (newval)))
#define g_atomic_pointer_compare_and_exchange(atomic, oldval, newval) \
  (g_atomic_pointer_compare_and_exchange ((atomic), (gpointer) (oldval), (gpointer) (newval)))
#define g_atomic_pointer_add(atomic, val) \
  (g_atomic_pointer_add ((atomic), (gssize) (val)))
#define g_atomic_pointer_and(atomic, val) \
  (g_atomic_pointer_and ((atomic), (gsize) (val)))
#define g_atomic_pointer_or(atomic, val) \
  (g_atomic_pointer_or ((atomic), (gsize) (val)))
#define g_atomic_pointer_xor(atomic, val) \
  (g_atomic_pointer_xor ((atomic), (gsize) (val)))

#endif /* defined(__GNUC__) && defined(G_ATOMIC_OP_USE_GCC_BUILTINS) */

/*
 * Copyright © 2011 Ryan Lortie
 *
 * This library is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * licence, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Author: Ryan Lortie <desrt@desrt.ca>
 */


static inline gint
(g_atomic_int_get) (const volatile gint *atomic)
{
  gint value;

  // pthread_mutex_lock (&g_atomic_lock);
  value = *atomic;
  // pthread_mutex_unlock (&g_atomic_lock);

  return value;
}

static inline void
(g_atomic_int_set) (volatile gint *atomic,
                    gint           value)
{
  // pthread_mutex_lock (&g_atomic_lock);
  *atomic = value;
  // pthread_mutex_unlock (&g_atomic_lock);
}

static inline void
(g_atomic_int_inc) (volatile gint *atomic)
{
  // pthread_mutex_lock (&g_atomic_lock);
  (*atomic)++;
  // pthread_mutex_unlock (&g_atomic_lock);
}

static inline gboolean
(g_atomic_int_dec_and_test) (volatile gint *atomic)
{
  gboolean is_zero;

  // pthread_mutex_lock (&g_atomic_lock);
  is_zero = --(*atomic) == 0;
  // pthread_mutex_unlock (&g_atomic_lock);

  return is_zero;
}

static inline gboolean
(g_atomic_int_compare_and_exchange) (volatile gint *atomic,
                                     gint           oldval,
                                     gint           newval)
{
  gboolean success;

  // pthread_mutex_lock (&g_atomic_lock);

  if ((success = (*atomic == oldval)))
    *atomic = newval;

  // pthread_mutex_unlock (&g_atomic_lock);

  return success;
}

static inline gint
(g_atomic_int_add) (volatile gint *atomic,
                    gint           val)
{
  gint oldval;

  // pthread_mutex_lock (&g_atomic_lock);
  oldval = *atomic;
  *atomic = oldval + val;
  // pthread_mutex_unlock (&g_atomic_lock);

  return oldval;
}

static inline guint
(g_atomic_int_and) (volatile guint *atomic,
                    guint           val)
{
  guint oldval;

  // pthread_mutex_lock (&g_atomic_lock);
  oldval = *atomic;
  *atomic = oldval & val;
  // pthread_mutex_unlock (&g_atomic_lock);

  return oldval;
}

static inline guint
(g_atomic_int_or) (volatile guint *atomic,
                   guint           val)
{
  guint oldval;

  // pthread_mutex_lock (&g_atomic_lock);
  oldval = *atomic;
  *atomic = oldval | val;
  // pthread_mutex_unlock (&g_atomic_lock);

  return oldval;
}

static inline guint
(g_atomic_int_xor) (volatile guint *atomic,
                    guint           val)
{
  guint oldval;

  // pthread_mutex_lock (&g_atomic_lock);
  oldval = *atomic;
  *atomic = oldval ^ val;
  // pthread_mutex_unlock (&g_atomic_lock);

  return oldval;
}


static inline gpointer
(g_atomic_pointer_get) (const volatile void *atomic)
{
  const volatile gpointer *ptr = atomic;
  gpointer value;

  // pthread_mutex_lock (&g_atomic_lock);
  value = *ptr;
  // pthread_mutex_unlock (&g_atomic_lock);

  return value;
}

static inline void
(g_atomic_pointer_set) (volatile void *atomic,
                        gpointer       newval)
{
  volatile gpointer *ptr = atomic;

  // pthread_mutex_lock (&g_atomic_lock);
  *ptr = newval;
  // pthread_mutex_unlock (&g_atomic_lock);
}

static inline gboolean
(g_atomic_pointer_compare_and_exchange) (volatile void *atomic,
                                         gpointer       oldval,
                                         gpointer       newval)
{
  volatile gpointer *ptr = atomic;
  gboolean success;

  // pthread_mutex_lock (&g_atomic_lock);

  if ((success = (*ptr == oldval)))
    *ptr = newval;

  // pthread_mutex_unlock (&g_atomic_lock);

  return success;
}

static inline gssize
(g_atomic_pointer_add) (volatile void *atomic,
                        gssize         val)
{
  volatile gssize *ptr = atomic;
  gssize oldval;

  // pthread_mutex_lock (&g_atomic_lock);
  oldval = *ptr;
  *ptr = oldval + val;
  // pthread_mutex_unlock (&g_atomic_lock);

  return oldval;
}

static inline gsize
(g_atomic_pointer_and) (volatile void *atomic,
                        gsize          val)
{
  volatile gsize *ptr = atomic;
  gsize oldval;

  // pthread_mutex_lock (&g_atomic_lock);
  oldval = *ptr;
  *ptr = oldval & val;
  // pthread_mutex_unlock (&g_atomic_lock);

  return oldval;
}

static inline gsize
(g_atomic_pointer_or) (volatile void *atomic,
                       gsize          val)
{
  volatile gsize *ptr = atomic;
  gsize oldval;

  // pthread_mutex_lock (&g_atomic_lock);
  oldval = *ptr;
  *ptr = oldval | val;
  // pthread_mutex_unlock (&g_atomic_lock);

  return oldval;
}

static inline gsize
(g_atomic_pointer_xor) (volatile void *atomic,
                        gsize          val)
{
  volatile gsize *ptr = atomic;
  gsize oldval;

  // pthread_mutex_lock (&g_atomic_lock);
  oldval = *ptr;
  *ptr = oldval ^ val;
  // pthread_mutex_unlock (&g_atomic_lock);

  return oldval;
}

/**
 * g_atomic_int_exchange_and_add:
 * @atomic: a pointer to a #gint
 * @val: the value to add
 *
 * This function existed before g_atomic_int_add() returned the prior
 * value of the integer (which it now does).  It is retained only for
 * compatibility reasons.  Don't use this function in new code.
 *
 * Returns: the value of @atomic before the add, signed
 * Since: 2.4
 * Deprecated: 2.30: Use g_atomic_int_add() instead.
 **/
static inline gint
g_atomic_int_exchange_and_add (volatile gint *atomic,
                               gint           val)
{
  return (g_atomic_int_add) (atomic, val);
}


#endif /* __G_ATOMIC_H__ */
