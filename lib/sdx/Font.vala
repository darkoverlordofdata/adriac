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
namespace Sdx 
{
	
	public class Font : Object 
	{
		public static int uniqueId = 0;
		public int id = ++uniqueId;
		public string path;
		public int size;
		public SDLTTF.Font innerFont;
		public SDL.RWops raw;


		public Font(string path, int size) 
		{
			var file = Sdx.Files.Default(path);
			raw = file.GetRWops();
			innerFont = new SDLTTF.Font.RW(raw, 0, size);
			this.path = path;
			this.size = size;
		}


		/**
		 *  Render text for Sprite.fromRenderedText
		 *
		 * @param text to generate surface from
		 * @param fg foreground color of text
		 * @param bg background color of sprite
		 * @return new Surface
		 */
		public SDL.Video.Surface Render(string text, SDL.Video.Color fg, SDL.Video.Color? bg = null) 
		{
			if (bg == null)
			{
				return innerFont.Render(text, fg);
			}
			else
			{
				return innerFont.RenderShaded(text, fg, bg);
			}
		}
	}
}

