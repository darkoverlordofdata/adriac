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
namespace Sdx.Ui 
{
    public class Container : Component
    {
        public Container(Sdx.Graphics.Sprite sprite) 
        {
            base();
            image = { sprite };
            image[0].SetCentered(false);
            bounds.w = image[0].width;
            bounds.h = image[0].height;
        }
        
    }
    /**
     * A label is just a sprite that renders as a child of the components subsystem.
     * The sprite can be an image or generated from text, or ...
     */
    public class Label : Component 
    {
        public Label()
        {
            base();
            kind = Kind.Label;
        }

        public class Text : Label {
            public Text(string text, Font font, SDL.Video.Color fg, SDL.Video.Color? bg = null) 
            {
                base();
                this.text = text;
                this.font = font;
                foreground = fg;
                background = bg;
                image = { new Sdx.Graphics.Sprite.TextSprite(this.text, this.font, foreground, background) };
                image[0].SetCentered(false);
                bounds.w = image[0].width;
                bounds.h = image[0].height;
            }
        }

        public class NinePatch : Label {
            public NinePatch(string text, Font font, SDL.Video.Color fg, Sdx.Graphics.NinePatch bg) 
            {
                base();
                this.text = text;
                this.font = font;
                foreground = fg;
                image = { new Sdx.Graphics.Sprite.UISprite(bg, this.text, this.font, foreground, 100, 40) };
                image[0].SetCentered(false);
                bounds.w = image[0].width;
                bounds.h = image[0].height;
            }
        }
    }

}