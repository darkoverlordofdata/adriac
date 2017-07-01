namespace sdx.graphics {

	public struct Scale {
		double x;
		double y;
	}
	/**
	 * base Sprite
	 */
	public class Sprite : Object {

		public enum Kind {
			AnimatedSprite, TextureSprite, AtlasSprite, CompositeSprite, TextSprite
		}
		public static int uniqueId = 0;
		public int id = ++uniqueId;
		public SDL.Video.Texture texture;
		public int width;
		public int height;
		public int x;
		public int y;
		public int index;
		public int frame = -1;
		public Scale scale = Scale() { x = 1.0, y = 1.0 };
		public SDL.Video.Color color = sdx.Color.White;
		public bool centered = true;
		public int layer = 0;
		public string path;
		public Kind kind;

		public class AnimatedSprite : Sprite {
			/**
			 * Animated Sprite
			 * 
			 * @param path to sprite sheet
			 * @param width count of sprites horizontally on sheet
			 * @param height count of sprites vertially on sheet
			 * 
			 * For each cell in spritesheet, draw the image from a cell
			 */
			public AnimatedSprite(string path, int width, int height) {
				index = Surface.CachedSurface.indexOfPath(path);
				this.height = height;
				this.width = width;
				this.path = path;
				this.kind = Kind.AnimatedSprite;
				setFrame(0);
			}
			/**
			 * setFrame
			 * 
			 * @param frame index of frame to draw
			 */
			public void setFrame(int frame) {
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
				var surface = new SDL.Video.Surface.legacy_rgb(0, width, height, 32, rmask, gmask, bmask, amask);
				Surface.CachedSurface.cache[index].surface.blit_scaled({ x, y, width, height }, surface, { 0, 0, width, height });
				this.texture = SDL.Video.Texture.create_from_surface(renderer, surface);

			}

		}

		public class TextureSprite : Sprite {
			/**
			 * TextureSprite
			 * 
			 * @param path to single surface
			 * 
			 * Simple sprite, 1 image per file
			 */
			public TextureSprite(string path) {
				var index = Surface.CachedSurface.indexOfPath(path);
				texture = SDL.Video.Texture.create_from_surface(renderer, Surface.CachedSurface.cache[index].surface);
				if (texture == null) throw new SdlException.UnableToLoadTexture(path);
				texture.set_blend_mode(SDL.Video.BlendMode.BLEND);
				width = Surface.CachedSurface.cache[index].width;
				height = Surface.CachedSurface.cache[index].height;
				this.path = path;
				this.kind = Kind.TextureSprite;
			}
		}
		
		public class AtlasSprite : Sprite {
			/**
			 * AtlasSprite
			 * 
			 * @param path to LibGDX TexturePacker Atlas
			 * 
			 */
			public AtlasSprite(AtlasRegion region) {

				var path = region.rg.texture.path;
				var index = Surface.CachedSurface.indexOfPath(region.rg.texture.path);
				var rmask = (uint32)0x000000ff; 
				var gmask = (uint32)0x0000ff00;
				var bmask = (uint32)0x00ff0000;
				var amask = (uint32)0xff000000;
				var x = region.rg.top;
				var y = region.rg.left;
				var w = region.rg.width;
				var h = region.rg.height;
				var surface = new SDL.Video.Surface.legacy_rgb(0, w, h, 32, rmask, gmask, bmask, amask);
				Surface.CachedSurface.cache[index].surface.blit_scaled({ x, y, w, h }, surface, { 0, 0, w, h });
				this.texture = SDL.Video.Texture.create_from_surface(renderer, surface);
				this.width = w;
				this.height = h;
				this.path = region.name;
				this.kind = Kind.AtlasSprite;
			}
		}

		public class CompositeSprite : Sprite {
			/**
			 * CompositeSprite
			 * 
			 * @param path to custom atlas
			 * @param function that returns a list of rectangles
			 * 
			 */
			public CompositeSprite(string path, Compositor builder) {
				var h = 0;
				var w = 0;
				foreach (var segment in builder(0, 0)) {
					if (segment.dest.h > h) h = (int)segment.dest.h;
					if (segment.dest.w > w) w = (int)segment.dest.w;
				}
				var index = Surface.CachedSurface.indexOfPath(path);
				var rmask = (uint32)0x000000ff; 
				var gmask = (uint32)0x0000ff00;
				var bmask = (uint32)0x00ff0000;
				var amask = (uint32)0xff000000;
				var surface = new SDL.Video.Surface.legacy_rgb(0, h, w, 32, rmask, gmask, bmask, amask);
				foreach (var segment in builder(h/2, w/2)) {
					Surface.CachedSurface.cache[index].surface.blit_scaled(segment.source, surface, segment.dest);
				}
				texture = SDL.Video.Texture.create_from_surface(renderer, surface);
				width = w;
				height = h;
				this.path = path;
				kind = Kind.CompositeSprite;
			}
		}

		public class TextSprite : Sprite {
			/**
			 * TextSprite
			 * 
			 * @param text string of text to generate
			 * @param font used to generate text
			 * @param color foregound text color (background transparent)
			 * 
			 */
			public TextSprite(string text, sdx.Font font, SDL.Video.Color color) {
				setText(text, font, color);
				centered = false;
				kind = Kind.TextSprite;
			}

			/**
			 *  Change the text value of a Sprite.fromRenderedText
			 *
			 * @param text string of text to generate
			 * @param font used to generate text
			 * @param color foregound text color (background transparent)
			 */
			public void setText(string text, sdx.Font font, SDL.Video.Color color) {
				var surface = font.render(text, color);
				texture = SDL.Video.Texture.create_from_surface(renderer, surface);
				texture.set_blend_mode(SDL.Video.BlendMode.BLEND);
				width = surface.w;
				height = surface.h;
				path = text;

			}
		}
		
		/**
		 *  Render the sprite on the Video.Renderer context
		 *
		 * @param renderer video context
		 * @param x display coordinate
		 * @param y display coordinate
		 * @param clip optional clipping rectangle
		 */
		public void render(int x, int y, SDL.Video.Rect? clip = null) {
			/* do clipping? */
			var w = (int)((clip == null ? width : clip.w) * scale.x);
			var h = (int)((clip == null ? height : clip.h) * scale.y);

			/* center in display? */
			x = centered ? x-(w/2) : x;
			y = centered ? y-(h/2) : y;

			/* apply current tint */
			texture.set_color_mod(color.r, color.g, color.b);
			/* copy to the rendering context */
			renderer.copy(texture, clip, { x, y, w, h });
		}

		public void copy(SDL.Video.Rect? src = null, SDL.Video.Rect? dest = null) {
			renderer.copy(texture, src, dest);
		}
	}
}

