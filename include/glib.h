/* GLIB - Library of useful routines for C programming
 * Copyright (C) 1995-1997  Peter Mattis, Spencer Kimball and Josh MacDonald
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Modified by the GLib Team and others 1997-2000.  See the AUTHORS
 * file for a list of people on the GLib Team.  See the ChangeLog
 * files for a list of changes.  These files are distributed with
 * GLib at ftp://ftp.gtk.org/pub/gtk/.
 */

/*
 *
 *
 *      __________                    ________ 
 *      \____    /___________  ____  /  _____/ 
 *        /     // __ \_  __ \/  _ \/   \  ___ 
 *       /     /\  ___/|  | \(  <_> )    \_\  \
 *      /_______ \___  >__|   \____/ \______  /
 *              \/   \/                     \/ 
 *
 *
 * ZeroG Copyright 2017 LGPL3 - darkoverlordofdata 
 *
 * Alternate runtime for vala on desktop, emscripten and android
 */
#ifndef _GLIB_H_
#define _GLIB_H_

#ifdef __cplusplus
 #define G_BEGIN_DECLS	extern "C" {
 #define G_END_DECLS	}
#else
 #define G_BEGIN_DECLS
 #define G_END_DECLS
#endif /* __cplusplus */

G_BEGIN_DECLS

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <stdint.h>
#include <limits.h>
#include <assert.h>
#include <time.h>
#include <glib/gmacros.h>

#include <glibconfig.h>
#include <glib/gversionmacros.h>
#include <glib/gtypes.h>
#include <glib/gatomic.h>
static gpointer g_malloc         (gsize	 n_bytes) G_GNUC_MALLOC G_GNUC_ALLOC_SIZE(1);
#include <glib/gquark.h>
#include <glib/gtestutils.h>
#include <glib/gmessages.h>
#include <glib/gthread.h>
#include <glib/gslice.h>
#include <glib/gstrfuncs.h>
#include <glib/gmem.h>
#include <glib/gnode.h>
#include <glib/garray.h>
#include <glib/glist.h>
#include <glib/gslist.h>
#include <glib/gstrfunc2.h>
#include <glib/gstring.h>
#include <glib/gerror.h>
#include <glib/ghash.h>
#include <glib/gque.h>

G_END_DECLS

#endif /* _GLIB_H_ */
