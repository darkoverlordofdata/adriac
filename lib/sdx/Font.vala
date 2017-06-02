namespace sdx {
	
	public class Font : Object {
		public static int uniqueId = 0;
		public int id = ++uniqueId;
		public string path;
		public int size;
		public SDLTTF.Font innerFont;
		public SDL.RWops raw;


		public Font(string path, int size) {
			
#if (DESKTOP)			
			var file = sdx.files.resource(path);
#elif (ANDROID)
			var file = sdx.files.asset(path);
#else
			var file = sdx.files.relative(path);
#endif
			raw = file.getRWops();
			innerFont = new SDLTTF.Font.RW(raw, 0, size);
			this.path = path;
			this.size = size;
		}


		/**
		 *  Render text for Sprite.fromRenderedText
		 *
		 * @param text to generate surface from
		 * @param color foreground color of text
		 * @return new Surface
		 */
		public SDL.Video.Surface render(string text, SDL.Video.Color color) {
			return innerFont.render(text, color);
		}
	}
}

