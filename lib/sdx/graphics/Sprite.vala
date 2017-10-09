/* ******************************************************************************
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
using Sdx.Math;
namespace Sdx.Graphics 
{

	/**
	 * base Sprite
	 */
	public class Sprite : Object 
	{
		public enum Kind 
		{
			AnimatedSprite, TextureSprite, AtlasSprite, 
			NineSliceSprite, CompositeSprite, TextSprite
		}
		public static int uniqueId = 0;

		public Class* klass = Class.Register("Sdx.Graphics.Sprite");
		public Kind kind;
		public int id = ++uniqueId;
		public SDL.Video.Texture texture;
		public int width;
		public int height;
		public int x;
		public int y;
		public int index;
		public int frame = -1;
		public double angle = 0.0;
		public Scale scale = Scale() { x = 1, y = 1 };
		public SDL.Video.Color color = Sdx.Color.White;
		public SDL.Video.RendererFlip flip = SDL.Video.RendererFlip.NONE;
		public SDL.Video.Point center;
		public bool centered = true;
		public int layer = 0;
		public string path;

		public int Width {
			get { return width; }
			set { width = value; }
		} 

		//  public Sprite()
		//  {
		//  	var h = (void*)this;
		//  	print("Sprite %08x\n", (uint32)h);
		//  }

		public class AnimatedSprite : Sprite 
		{
			/**
			 * Animated Sprite
			 * 
			 * For each cell in spritesheet, draw the image from a cell
			 * 
			 * @param path to sprite sheet
			 * @param width count of sprites horizontally on sheet
			 * @param height count of sprites vertially on sheet
			 */
			public AnimatedSprite(string path, int width, int height) 
			{
				index = Surface.CachedSurface.IndexOfPath(path);
				this.height = height;
				this.width = width;
				this.center = { width / 2, height / 2 };
				this.path = path;
				this.kind = Kind.AnimatedSprite;
				SetFrame(0);
			}
			/**
			 * setFrame
			 * 
			 * @param frame index of frame to draw
			 */
			public void SetFrame(int frame) 
			{
				if (frame == this.frame) return;
				this.frame = frame;
				var rmask = (uint32)0x000000ff; 
				var gmask = (uint32)0x0000ff00;
				var bmask = (uint32)0x00ff0000;
				var amask = (uint32)0xff000000;
				var wf = Surface.CachedSurface.cache[index].surface.w / width;
				var hf = Surface.CachedSurface.cache[index].surface.h / height;

				x = (frame % wf) * width;
				y = (int)(frame / wf) * height;
				var surface = new SDL.Video.Surface.LegacyRgb(0, width, height, 32, rmask, gmask, bmask, amask);
				Surface.CachedSurface.cache[index].surface.BlitScaled({ x, y, width, height }, surface, { 0, 0, width, height });
				this.texture = SDL.Video.Texture.CreateFromSurface(renderer, surface);

			}

		}

		public class TextureSprite : Sprite 
		{
			/**
			 * TextureSprite
			 * 
			 * Simple sprite, 1 image per file
			 * @param path to single surface
			 */
			public TextureSprite(string path) 
			{
				var index = Surface.CachedSurface.IndexOfPath(path);
				texture = SDL.Video.Texture.CreateFromSurface(renderer, Surface.CachedSurface.cache[index].surface);
				if (texture == null) throw new SdlException.UnableToLoadTexture(path);
				texture.SetBlendMode(SDL.Video.BlendMode.BLEND);
				width = Surface.CachedSurface.cache[index].width;
				height = Surface.CachedSurface.cache[index].height;
				this.center = { width / 2, height / 2 };
				this.path = path;
				this.kind = Kind.TextureSprite;
			}
		}
		
		public class AtlasSprite : Sprite 
		{
			/**
			 * AtlasSprite
			 * 
			 * @param region to load sprite from
			 * 
			 */
			public AtlasSprite(AtlasRegion region) 
			{

				var path = region.texture.path;
				var index = Surface.CachedSurface.IndexOfPath(region.texture.path);
				var rmask = (uint32)0x000000ff; 
				var gmask = (uint32)0x0000ff00;
				var bmask = (uint32)0x00ff0000;
				var amask = (uint32)0xff000000;
				var x = region.top;
				var y = region.left;
				var w = region.width;
				var h = region.height;
				var surface = new SDL.Video.Surface.LegacyRgb(0, w, h, 32, rmask, gmask, bmask, amask);
				Surface.CachedSurface.cache[index].surface.BlitScaled({ x, y, w, h }, surface, { 0, 0, w, h });
				this.texture = SDL.Video.Texture.CreateFromSurface(renderer, surface);
				this.width = w;
				this.height = h;
				this.center = { width / 2, height / 2 };
				this.path = region.name;
				this.kind = Kind.AtlasSprite;
			}
		}

		public class CompositeSprite : Sprite 
		{
			/**
			 * CompositeSprite
			 * 
			 * @param path to custom atlas
			 * @param builder factory delegate
			 * @param x offset in pixels
			 * @param y offset in pixels
			 * 
			 */
			public CompositeSprite(string path, Compositor builder, int x = 0, int y = 0) 
			{
				var h = 0;
				var w = 0;
				foreach (var segment in builder(x, y)) 
				{
					if (segment.dest.h > h) h = (int)segment.dest.h;
					if (segment.dest.w > w) w = (int)segment.dest.w;
				}
				var index = Surface.CachedSurface.IndexOfPath(path);
				var rmask = (uint32)0x000000ff; 
				var gmask = (uint32)0x0000ff00;
				var bmask = (uint32)0x00ff0000;
				var amask = (uint32)0xff000000;
				var surface = new SDL.Video.Surface.LegacyRgb(0, h, w, 32, rmask, gmask, bmask, amask);
				foreach (var segment in builder(h/2, w/2)) 
				{
					Surface.CachedSurface.cache[index].surface.BlitScaled(segment.source, surface, segment.dest);
				}
				texture = SDL.Video.Texture.CreateFromSurface(renderer, surface);
				width = w;
				height = h;
				this.center = { width / 2, height / 2 };
				this.path = path;
				kind = Kind.CompositeSprite;
			}
		}

		public class NineSliceSprite : Sprite 
		{
			/**
			 * CompositeSprite
			 * 
			 * @param patch 9slice object
			 * @param width in pixels
			 * @param height in pixels
			 * 
			 */
			public NineSliceSprite(NinePatch patch, int width = 100, int height = 100) 
			{
				var w = (int)patch.GetTotalWidth()+width;
				var h = (int)patch.GetTotalHeight()+height;

				var rmask = (uint32)0x000000ff; 
				var gmask = (uint32)0x0000ff00;
				var bmask = (uint32)0x00ff0000;
				var amask = (uint32)0xff000000;
				var dest = new SDL.Video.Rect[9];
				var surface = new SDL.Video.Surface.LegacyRgb(0, w, h, 32, rmask, gmask, bmask, amask);
				var i = 0;

				for (i=0; i<9; i++) 
					dest[i] = { patch.slice[i].dest.x, patch.slice[i].dest.y, patch.slice[i].dest.w, patch.slice[i].dest.h };
				
				var offsetWidth = width - (dest[1].w + dest[2].w + dest[3].w);
				var offsetHeight = height - (dest[1].h + dest[4].h + dest[7].h);

				dest[1].w += offsetWidth;
				dest[4].w += offsetWidth;
				dest[7].w += offsetWidth;

				dest[2].x += (int)offsetWidth;
				dest[5].x += (int)offsetWidth;
				dest[8].x += (int)offsetWidth;

				dest[3].h += offsetHeight;
				dest[4].h += offsetHeight;
				dest[5].h += offsetHeight;

				dest[6].y += (int)offsetHeight;
				dest[7].y += (int)offsetHeight;
				dest[8].y += (int)offsetHeight;

				i = 0;
				foreach (var segment in patch.slice) 
				{
					patch.texture.surface.BlitScaled(segment.source, surface, dest[i++]);
				}
				texture = SDL.Video.Texture.CreateFromSurface(renderer, surface);
				this.width = width;
				this.height = height;
				this.center = { width / 2, height / 2 };
				//this.path = path;
				kind = Kind.NineSliceSprite;
			}
		}

		public class UISprite : Sprite 
		{
			/**
			 * CompositeSprite
			 * 
			 * @param patch 9slice patch object
			 * @param text to generate
			 * @param font to use
			 * @param color to use for foreground
			 * @param width in pixels
			 * @param height in pixels
			 * 
			 */
			public UISprite(NinePatch patch, string text, Sdx.Font font, SDL.Video.Color color, int width = 50, int height = 20) 
			{

				var textSurface = font.Render(text, color);
				
				width = (int)GLib.Math.fmax(width, textSurface.w);
				height = (int)GLib.Math.fmax(height, textSurface.h);

				//  width = (int)textSurface.w;
				//  height = (int)textSurface.h;

				var w = (int)patch.GetTotalWidth()+width;
				var h = (int)patch.GetTotalHeight()+height;
				var rmask = (uint32)0x000000ff; 
				var gmask = (uint32)0x0000ff00;
				var bmask = (uint32)0x00ff0000;
				var amask = (uint32)0xff000000;
				var dest = new SDL.Video.Rect[9];
				var surface = new SDL.Video.Surface.LegacyRgb(0, w, h, 32, rmask, gmask, bmask, amask);
				var i = 0;

				for (i=0; i<9; i++) 
					dest[i] = 
						{ 
							patch.slice[i].dest.x, 
							patch.slice[i].dest.y, 
							patch.slice[i].dest.w, 
							patch.slice[i].dest.h 
						};

				var offsetWidth = (int)GLib.Math.fmax(0, (int)width - (int)(dest[1].w + dest[2].w + dest[3].w))+8;
				var offsetHeight = (int)GLib.Math.fmax(0, (int)height - (int)(dest[1].h + dest[4].h + dest[7].h));

				dest[1].w += offsetWidth;
				dest[4].w += offsetWidth;
				dest[7].w += offsetWidth;

				dest[2].x += (int)offsetWidth;
				dest[5].x += (int)offsetWidth;
				dest[8].x += (int)offsetWidth;

				dest[3].h += offsetHeight;
				dest[4].h += offsetHeight;
				dest[5].h += offsetHeight;

				dest[6].y += (int)offsetHeight;
				dest[7].y += (int)offsetHeight;
				dest[8].y += (int)offsetHeight;

				i = 0;
				foreach (var segment in patch.slice) 
				{
					patch.texture.surface.BlitScaled(segment.source, surface, dest[i++]);
				}
				textSurface.BlitScaled(
					{ 0, 0, width, height },
					surface, 
					{ patch.bottom, patch.right, width, height }
				);


				texture = SDL.Video.Texture.CreateFromSurface(renderer, surface);

				texture.SetBlendMode(SDL.Video.BlendMode.BLEND);
				this.width = width;
				this.height = height;
				this.center = { width / 2, height / 2 };
				kind = Kind.NineSliceSprite;
			}
		}

		public class TextSprite : Sprite 
		{
			/**
			 * TextSprite
			 * 
			 * @param text string of text to generate
			 * @param font used to generate text
			 * @param fg foregound text color 
			 * @param bg background color, null = transparent
			 * 
			 */
			public TextSprite(string text, Sdx.Font font, SDL.Video.Color fg, SDL.Video.Color? bg = null) 
			{
				SetText(text, font, fg, bg);
				centered = false;
				center = { 0, 0 };
				kind = Kind.TextSprite;
			}

			/**
			 *  Change the text value of a Sprite.fromRenderedText
			 *
			 * @param text string of text to generate
			 * @param font used to generate text
			 * @param fg foregound text color 
			 * @param bg background color, null = transparent
			 */
			public void SetText(string text, Sdx.Font font, SDL.Video.Color fg, SDL.Video.Color? bg = null) 
			{
				var surface = font.Render(text, fg, bg);
				texture = SDL.Video.Texture.CreateFromSurface(renderer, surface);
				texture.SetBlendMode(SDL.Video.BlendMode.BLEND);
				width = surface.w;
				height = surface.h;
				path = text;

			}
		}
		
		/**
		 *  Render the sprite on the Video.Renderer context
		 *
		 * @param x display coordinate
		 * @param y display coordinate
		 * @param clip optional clipping rectangle
		 */
		public void Render(int x, int y, SDL.Video.Rect? clip = null) 
		{
			/* do clipping? */
			var w = (int)((clip == null ? width : clip.w) * scale.x);
			var h = (int)((clip == null ? height : clip.h) * scale.y);

			/* center in display? */
			x = centered ? x-(w/2) : x;
			y = centered ? y-(h/2) : y;

			/* apply current tint */
			texture.SetColorMod(color.r, color.g, color.b);
			texture.SetAlphaMod(color.a);
			/* copy to the rendering context */
			//  renderer.Copy(texture, clip, { x, y, w, h });
			renderer.CopyEx(texture, clip, { x, y, w, h }, angle, center, flip);
		}

		public void Copy(SDL.Video.Rect? src = null, SDL.Video.Rect? dest = null) 
		{
			renderer.Copy(texture, src, dest);
		}

		public Sprite SetColor(SDL.Video.Color color)
		{
			this.color = color;
			return this;
		}
		public Sprite SetScale(float x, float y) 
		{
			this.scale = { x, y };
			return this;
		}

		public Sprite SetPosition(int x, int y) 
		{
			this.x = x;
			this.y = y;
			return this;
		}

		public Sprite SetCentered(bool value) 
		{
			centered = value;
			if (centered)
				center = { width / 2, height / 2 };
			else
				center = { 0, 0 };

			return this;
		}
	}
}

