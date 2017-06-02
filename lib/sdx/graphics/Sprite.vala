namespace sdx.graphics {

	public struct Scale {
		double x;
		double y;
	}
	
	public class Sprite : Object {
		public static sdx.graphics.Surface[] cache;
		public static int uniqueId = 0;
		public SDL.Video.Texture texture;
		public SDL.Video.Surface surface;
		public int width;
		public int height;
		public int x;
		public int y;
		public Scale scale = Scale() { x = 1.0, y = 1.0 };
		public SDL.Video.Color color = sdx.Color.White;
		public bool centered = true;
		public int layer = 0;
		public int id = ++uniqueId;
		public string path;
		public bool isText;

		public Sprite(string? path=null) {
			if (path != null) {
				isText = false;
				var i = indexOfPath(path);
				if (i<0) { 
					stdout.printf("Ran out of surface cache\n");
				} else {
					texture = SDL.Video.Texture.create_from_surface(renderer, cache[i].surface);
					if (texture == null)
						stdout.printf("Unable to load image texture %s\n", path);
					texture.set_blend_mode(SDL.Video.BlendMode.BLEND);
					width = cache[i].width;
					height = cache[i].height;
					this.path = path;
				}
			}
		}


		public static Sprite composite(string path, Compositor builder) {
			var sprite = new Sprite();
			var h = 0;
			var w = 0;
			foreach (var segment in builder(0, 0)) {
				if (segment.dest.h > h) h = (int)segment.dest.h;
				if (segment.dest.w > w) w = (int)segment.dest.w;
			}

			var i = indexOfPath(path);
			if (i<0) { 
				stdout.printf("Ran out of surface cache\n");
			} 
			
			var flags = (uint32)0x00010000;
			var rmask = (uint32)0x000000ff; 
			var gmask = (uint32)0x0000ff00;
			var bmask = (uint32)0x00ff0000;
			var amask = (uint32)0xff000000;
			var surface = new SDL.Video.Surface.legacy_rgb(flags, h, w, 32, rmask, gmask, bmask, amask);
			foreach (var segment in builder(h/2, w/2)) {
				cache[i].surface.blit_scaled(segment.source, surface, segment.dest);
			}
			sprite.texture = SDL.Video.Texture.create_from_surface(renderer, surface);
			sprite.width = w;
			sprite.height = h;
			sprite.path = path;
			return sprite;
		}


		public static Sprite fromText(string path, sdx.Font font, SDL.Video.Color color) {
			var sprite = new Sprite();
			sprite.isText = true;
			sprite.centered = false;
			var surface = font.render(path, color);
			if (surface == null) {
				stdout.printf("Unable to load font surface %s\n", font.path);
			} else {
				surface.set_alphamod(color.a);
				sprite.texture = SDL.Video.Texture.create_from_surface(renderer, surface);
				if (sprite.texture == null) {
						stdout.printf("Unable to load image text %s\n", path);
				} else {
					sprite.texture.set_blend_mode(SDL.Video.BlendMode.BLEND);
					sprite.width = surface.w;
					sprite.height = surface.h;
					sprite.path = path;
				}
			}
			return sprite;
		}


		public static void initialize(int length) {
			if (cache.length == 0)
				cache = new sdx.graphics.Surface[length];
		}

		public static int indexOfPath(string path) {
			// if cache.length == 0 do cache = new array of sdx.graphics.Surface[Pool.Count]
			for (var i=0; i<cache.length; i++) {
				if (cache[i] == null) cache[i] = new sdx.graphics.Surface(path);
				if (cache[i].path == path) return i;
			}
			return -1;
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
			if (surface == null) {
				stdout.printf("Unable to set font surface %s\n", font.path);
			} else {
				texture = SDL.Video.Texture.create_from_surface(sdx.renderer, surface);
				if (texture == null) {
					stdout.printf("Unable to set image text %s\n", text);
				} else {
					texture.set_blend_mode(SDL.Video.BlendMode.BLEND);
					width = surface.w;
					height = surface.h;
					path = text;
				}
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
			renderer.copy(texture, clip, {x, y, w, h});
		}

		public void copy(SDL.Video.Rect? src = null, SDL.Video.Rect? dest = null) {
			renderer.copy(texture, src, dest);
		}
	}
}

