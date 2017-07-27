/*******************************************************************************
 * Copyright 2017 darkoverlordofdata.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
namespace Sdx.Graphics 
{

	/**
	 * a reference counted wrapper for surface
	 * 
	 */
	
	public class Surface : Object 
	{
		public static int uniqueId = 0;
		public SDL.Video.Surface? surface;
		public int id = ++uniqueId;
		public string path;

        public int width 
		{
            get { return surface.w; }
        }
        public int height 
		{
            get { return surface.h; }
        }
		public SDL.Video.Surface GetSurface(string ext, SDL.RWops raw) 
		{
			// warning : case statement fails here with default exception
			if (ext == ".png") return SDLImage.LoadPNG(raw);
			else if (ext == ".cur") return SDLImage.LoadCUR(raw);
			else if (ext == ".ico") return SDLImage.LoadICO(raw);
			else if (ext == ".bmp") return SDLImage.LoadBMP(raw);
			else if (ext == ".pnm") return SDLImage.LoadPNM(raw);
			else if (ext == ".xpm") return SDLImage.LoadXPM(raw);
			else if (ext == ".xcf") return SDLImage.LoadXCF(raw);
			else if (ext == ".pvx") return SDLImage.LoadPCX(raw);
			else if (ext == ".gif") return SDLImage.LoadGIF(raw);
			else if (ext == ".jpg") return SDLImage.LoadJPG(raw);
			else if (ext == ".tif") return SDLImage.LoadTIF(raw);
			else if (ext == ".tga") return SDLImage.LoadTGA(raw);
			else if (ext == ".lbm") return SDLImage.LoadLBM(raw);
			else if (ext == ".xv") return SDLImage.LoadXV(raw);
			else if (ext == ".webp") return SDLImage.LoadWEBP(raw);
			else throw new SdlException.UnableToLoadSurface(ext);
		}

		/** 
		 * Cached Surface
		 * 
		 * a locally owned/cached surface
		 */

		public class CachedSurface : Surface 
		{
			public static Sdx.Graphics.Surface[] cache;
			public static void Initialize(int size) 
			{
				if (cache.length == 0) cache = new Sdx.Graphics.Surface[size];
			}

			public CachedSurface(Sdx.Files.FileHandle file) 
			{

				var ext = file.GetExt();
				var raw = file.GetRWops();
				path = file.GetPath();
				surface = GetSurface(ext, raw);
				surface.SetAlphaMod(0xff);
			}

			public static int IndexOfPath(string path) 
			{
				if (cache.length == 0) cache = new Sdx.Graphics.Surface[10];//Pool.Count];
				for (var i=0; i<cache.length; i++) 
				{
					if (cache[i] == null) 
					{
						cache[i] = new CachedSurface(Sdx.Files.Default(path));
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
		public class TextureSurface : Surface 
		{

			public TextureSurface(Sdx.Files.FileHandle file) 
			{
				path = file.GetPath();
				var raw = file.GetRWops();
				surface = GetSurface(file.GetExt(), raw);
				surface.SetAlphaMod(0xff);
			}


			public void SetFilter(int minFilter, int magFilter) {}
			public void SetWrap(int u, int v) {}

		}

	}

}

