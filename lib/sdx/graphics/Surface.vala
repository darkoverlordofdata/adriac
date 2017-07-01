namespace sdx.graphics {

	/**
	 * a reference counted wrapper for surface
	 * 
	 */
	
	public class Surface : Object {
		public static int uniqueId = 0;
		public SDL.Video.Surface? surface;
		public int id = ++uniqueId;
		public string path;

        public int width {
            get { return surface.w; }
        }
        public int height {
            get { return surface.h; }
        }
		public SDL.Video.Surface getSurface(string ext, SDL.RWops raw) {
			// warning : case statement fails here
			if (ext == ".png") return SDLImage.load_png(raw);
			else if (ext == ".cur") return SDLImage.load_cur(raw);
			else if (ext == ".ico") return SDLImage.load_ico(raw);
			else if (ext == ".bmp") return SDLImage.load_bmp(raw);
			else if (ext == ".pnm") return SDLImage.load_pnm(raw);
			else if (ext == ".xpm") return SDLImage.load_xpm(raw);
			else if (ext == ".xcf") return SDLImage.load_xcf(raw);
			else if (ext == ".pvx") return SDLImage.load_pcx(raw);
			else if (ext == ".gif") return SDLImage.load_gif(raw);
			else if (ext == ".jpg") return SDLImage.load_jpg(raw);
			else if (ext == ".tif") return SDLImage.load_tif(raw);
			else if (ext == ".tga") return SDLImage.load_tga(raw);
			else if (ext == ".lbm") return SDLImage.load_lbm(raw);
			else if (ext == ".xv") return SDLImage.load_xv(raw);
			else if (ext == ".webp") return SDLImage.load_webp(raw);
			else throw new SdlException.UnableToLoadSurface(ext);
		}
		/**
		 *  Load a Surface from raw memory
		 *
		 * @param ext file extension (encoding)
		 * @param raw RWops memory ptr
		 * @param the new Surface
		 */
		//  public SDL.Video.Surface getSurface(string ext, SDL.RWops raw) {
		//  	// warning : if statement fails here
		//  	switch (ext) {
		//  		case ".cur": return SDLImage.load_cur(raw);
		//  		case ".ico": return SDLImage.load_ico(raw);
		//  		case ".bmp": return SDLImage.load_bmp(raw);
		//  		case ".pnm": return SDLImage.load_pnm(raw);
		//  		case ".xpm": return SDLImage.load_xpm(raw);
		//  		case ".xcf": return SDLImage.load_xcf(raw);
		//  		case ".pvx": return SDLImage.load_pcx(raw);
		//  		case ".gif": return SDLImage.load_gif(raw);
		//  		case ".jpg": return SDLImage.load_jpg(raw);
		//  		case ".tif": return SDLImage.load_tif(raw);
		//  		case ".png": return SDLImage.load_png(raw);
		//  		case ".tga": return SDLImage.load_tga(raw);
		//  		case ".lbm": return SDLImage.load_lbm(raw);
		//  		case ".xv":  return SDLImage.load_xv(raw);
		//  		case ".webp": return SDLImage.load_webp(raw);
		//  		default: throw new SdlException.UnableToLoadSurface(ext);
		//  	}
		//  	return null;
		//  }

		/** 
		 * Cached Surface
		 * 
		 * a locally owned/cached surface
		 */

		public class CachedSurface : Surface {
			public static sdx.graphics.Surface[] cache;

			public CachedSurface(sdx.files.FileHandle file) {

				var ext = file.getExt();
				var raw = file.getRWops();
				path = file.getPath();
				surface = getSurface(ext, raw);
				surface.set_alphamod(0xff);
			}

			public static int indexOfPath(string path) {
				if (cache.length == 0) cache = new sdx.graphics.Surface[Pool.Count];
				for (var i=0; i<cache.length; i++) {
					if (cache[i] == null) {
						cache[i] = new CachedSurface(sdx.files.@default(path));
						return i;
					}
					if (cache[i].path == path) return i;
				}
				throw new SdlException.UnableToLoadSurface("Cache is full");
			}
		}
		
		/**
		 * Texture Surface
		 * 
		 * a parent for TextureRegions
		 * an externally owned/cached surface
		 */
		public class TextureSurface : Surface {

			public TextureSurface(sdx.files.FileHandle file) {
				path = file.getPath();
				var raw = file.getRWops();
				surface = getSurface(file.getExt(), raw);
				surface.set_alphamod(0xff);
			}


			public void setFilter(int minFilter, int magFilter) {}
			public void setWrap(int u, int v) {}

		}

	}

}

