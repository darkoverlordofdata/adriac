//  /* ******************************************************************************
//   * Copyright 2017 darkoverlordofdata.
//   * 
//   * Licensed under the Apache License, Version 2.0 (the "License");
//   * you may not use this file except in compliance with the License.
//   * You may obtain a copy of the License at
//   * 
//   *   http://www.apache.org/licenses/LICENSE-2.0
//   * 
//   * Unless required by applicable law or agreed to in writing, software
//   * distributed under the License is distributed on an "AS IS" BASIS,
//   * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   * See the License for the specific language governing permissions and
//   * limitations under the License.
//   ******************************************************************************/
/**
 * Sdx Ui
 * 
 * UI Components -
 * Label, Button, etc
 * 
 */
namespace Sdx.Ui 
{
//      /**
//       * A Button is like a label with events
//       */
//      public class Button : Component 
//      {
//          public Button()
//          {
//              base();
//  			Sdx.SetInputProcessor(InputProcessor() 
//  			{ 
//  				TouchDown = (x, y, pointer, button) => 
//  				{
//                      //  if (Test(x, y)) OnMouseClick();
//  					return false;
//  				},

//  				TouchUp = (x, y, pointer, button) => 
//  				{
//  					return false;
//  				},

//  				TouchDragged = (x, y, pointer) => 
//  				{
//                      Test(x, y);
//  					return false;
//  				},

//  				MouseMoved = (x, y) => 
//  				{
//                      Test(x, y);
//  					return false;
//                  }
//              });
            
//          }

//          public bool Test(int x, int y)
//          {
//              var test = bounds.HasIntersection({ x, y, 1, 1 });
//              if (test && index == 0) index = 1;
//              if (!test && index == 1) index = 0;
//              return test;
//          }

//          public class Text : Button {
//              public Text(string text, Font font, SDL.Video.Color fg, SDL.Video.Color? bg = null) 
//              {
//                  base();
//                  this.text = text;
//                  this.font = font;
//                  foreground = fg;
//                  background = bg;
//                  index = 0;
//                  image = { 
//                      new Sdx.Graphics.Sprite.TextSprite(this.text, this.font, foreground, background) 
//                  };
//                  image[0].SetCentered(false);
//                  bounds.w = image[0].width;
//                  bounds.h = image[0].height;
//              }
//          }

//          public class NinePatch : Button {
//              public NinePatch(string text, Font font, SDL.Video.Color fg, string img, string alt) 
//              {
//                  base();
//                  this.text = text;
//                  this.font = font;
//                  foreground = fg;
//                  index = 0;
//                  image = { 
//                      new Sdx.Graphics.Sprite.UISprite(Sdx.atlas.CreatePatch(img), this.text, this.font, foreground, 100, 40),
//                      new Sdx.Graphics.Sprite.UISprite(Sdx.atlas.CreatePatch(alt), this.text, this.font, foreground, 100, 40) 
//                  };
//                  image[0].SetCentered(false);
//                  image[1].SetCentered(false);
//                  bounds.w = image[0].width;
//                  bounds.h = image[0].height;
//              }
//          }
//      }


    
}