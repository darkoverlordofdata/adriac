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
/**
 * BitmapFont.gs
 *
 */
using Sdx;
using Sdx.Files;
using Sdx.Utils;
/**
 * Parse the *.fnt file
 * use angelcode.com format
 */
namespace Sdx.Graphics {

    public class BitmapFont : Object {

        public const int LOG2_PAGE_SIZE = 9;
        public const int PAGE_SIZE = 1 << LOG2_PAGE_SIZE;
        public const int PAGES = 0x10000 / PAGE_SIZE;

        public Sdx.Utils.Json? dummy2;
        public TextureRegion? dummy; // generic reference doesn't trigger forward reference.
        
        public BitmapFontData? data;
        public List<TextureRegion> regions;
    }

    public class Glyph : Object {
        public int id;
        public int x;
        public int y;
        public int width;
        public int height;
        public float u;
        public float v;
        public float u2;
        public float v2;
        public int xoffset;
        public int yoffset;
        public int xadvance;
        public char[,] kerning; 
        public bool fixedWidth;
        public int page = 0;

        public int GetKerning(char ch) {
            if (kerning != null) {
                var i = ch >> BitmapFont.LOG2_PAGE_SIZE;
                var j = ch & BitmapFont.PAGE_SIZE - 1;
                return kerning[i,j];
            }
            return 0;
        }

        public void SetKerning(int ch, int value) {
            if (kerning == null) kerning = new char[BitmapFont.PAGES,BitmapFont.PAGE_SIZE];
            var i = ch >> BitmapFont.LOG2_PAGE_SIZE;
            var j = ch & BitmapFont.PAGE_SIZE - 1;
            kerning[i,j] = (char)value;
        }
    }
            
    public class BitmapFontData : Object {
        public string[] imagePaths;
        public FileHandle fontFile;
        public bool flipped;
        public float padTop;
        public float padRight;
        public float padBottom;
        public float padLeft;
        public float lineHeight;
        public float capHeight = 1;
        public float ascent;
        public float descent;
        public float down;
        public float blankLineScale = 1;
        public float scaleX = 1;
        public float scaleY = 1;
        public bool markupEnabled;
        public float cursorX;
        public Glyph[,] glyphs = new Glyph[BitmapFont.PAGES,BitmapFont.PAGE_SIZE];
        public Glyph missingGlyph;
        public float spaceWidth;
        public float xHeight = 1;
        public char[] breakChars;
        public char[] xChars = {'x', 'e', 'a', 'o', 'n', 's', 'r', 'c', 'u', 'm', 'v', 'w', 'z'};
        public char[] capChars = {'M', 'N', 'B', 'D', 'C', 'E', 'F', 'K', 'A', 'G', 'H', 'I', 'J', 'L', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};

        public BitmapFontData(FileHandle? fontFile = null, bool flip = false) {
            if (fontFile != null) {
                this.fontFile = fontFile;
                this.flipped = flip;
                Load(fontFile, flip);
            }
        }

        public void Load(FileHandle fontFile, bool flip) {
            if (imagePaths != null) throw new SdlException.IllegalStateException("Already loaded.");

            var json = Sdx.Utils.Json.Parse(fontFile.Read());
            var padding = json.Member("font").Member("info").Member("padding").string.Split(",", 4);
            if (padding.length != 4) throw new SdlException.RuntimeException("Invalid padding: %d.", padding.length);
            padTop = int.Parse(padding[0]);
            padRight = int.Parse(padding[1]);
            padBottom = int.Parse(padding[2]);
            padLeft = int.Parse(padding[3]);
            var padY = padTop + padBottom;

            lineHeight = (int)json.Member("font").Member("common").Member("lineHeight").number;
            var baseLine = (int)json.Member("font").Member("common").Member("base").number;


            var pages = json.Member("font").Member("pages").object.GetKeysAsArray();
            var pageCount = pages.length;
            imagePaths = new string[pageCount];
            // Read each page definition.
            for (var p = 0; p<pageCount; p++) {
                var node = json.Member("font").Member("pages").Member(pages[p]);
                var filename = node.Member("file").string;
                imagePaths[p] = fontFile.GetParent().Child(filename).GetPath();
            }

            descent = 0;
            foreach (var ch in json.Member("font").Member("chars").Member("char").array) {
                var glyph = new Glyph();
                    glyph.id = int.Parse(ch.Member("id").string);
                    glyph.x = int.Parse(ch.Member("x").string);
                    glyph.y = int.Parse(ch.Member("y").string);
                    glyph.width = int.Parse(ch.Member("width").string);
                    glyph.height = int.Parse(ch.Member("height").string);
                    glyph.xoffset = int.Parse(ch.Member("xoffset").string);
                    if (flip)
                        glyph.yoffset = int.Parse(ch.Member("yoffset").string);
                    else
                        glyph.yoffset = -(glyph.height + int.Parse(ch.Member("yoffset").string));
                    glyph.xadvance = int.Parse(ch.Member("xadvance").string);

                    if (glyph.width > 0 && glyph.height > 0) descent = GLib.Math.fminf(baseLine + glyph.yoffset, descent);
            }
            descent += padBottom;
                
            var spaceGlyph = GetGlyph(' ');
            if (spaceGlyph == null) {
                spaceGlyph = new Glyph();
                spaceGlyph.id = (int)' ';
                var xadvanceGlyph = GetGlyph('l');
                if (xadvanceGlyph == null) xadvanceGlyph = GetFirstGlyph();
                spaceGlyph.xadvance = xadvanceGlyph.xadvance;
                SetGlyph(' ', spaceGlyph);
            }
            
            if (spaceGlyph.width == 0) {
                spaceGlyph.width = (int)(padLeft + spaceGlyph.xadvance + padRight);
                spaceGlyph.xoffset = (int)(-padLeft);
            }
            
            spaceWidth = spaceGlyph.width;

            Glyph xGlyph = null;

            foreach (var xChar in xChars) {
                xGlyph = GetGlyph(xChar);
                if (xGlyph != null) break;
            }
            if (xGlyph == null) xGlyph = GetFirstGlyph();
            xHeight = xGlyph.height - padY;

            Glyph capGlyph = null;
            foreach (var capChar in capChars) {
                capGlyph = GetGlyph(capChar);
                if (capGlyph != null) break;
            }
            if (capGlyph == null) {
                for (var p = 0; p<BitmapFont.PAGES; p++) {
                    for (var g = 0; g<BitmapFont.PAGE_SIZE; g++) {
                        var glyph = glyphs[p,g];
                        if (glyph == null || glyph.height == 0 || glyph.width == 0) continue;
                        capHeight = GLib.Math.fmaxf(capHeight, glyph.height);
                    }
                }
            } else {
                capHeight = capGlyph.height;
            }
            capHeight -= padY;

            ascent = baseLine - capHeight;
            down = -lineHeight;
            if (flip) {
                ascent = -ascent;
                down = -down;
            }
        }

        public void SetGlyphRegion(Glyph glyph, TextureRegion region) {
            var texture = region.texture;
            var invTexWidth = 1.0f / texture.width;
            var invTexHeight = 1.0f / texture.height;

            var offsetX = 0;
            var offsetY = 0;
            var u = region.u;
            var v = region.v;
            var regionWidth = region.GetRegionWidth();
            var regionHeight = region.GetRegionHeight();
            //  if (region is TextureAtlas.AtlasRegion) {
            //      // Compensate for whitespace stripped from left and top edges.
            //      var atlasRegion = (TextureAtlas.AtlasRegion)region;
            //      offsetX = atlasRegion.offsetX;
            //      offsetY = atlasRegion.originalHeight - atlasRegion.packedHeight - atlasRegion.offsetY;
            //  }

            var x = glyph.x;
            var x2 = glyph.x + glyph.width;
            var y = glyph.y;
            var y2 = glyph.y + glyph.height;

            // Shift glyph for left and top edge stripped whitespace. Clip glyph for right and bottom edge stripped whitespace.
            if (offsetX > 0) {
                x -= offsetX;
                if (x < 0) {
                    glyph.width += x;
                    glyph.xoffset -= x;
                    x = 0;
                }
                
                x2 -= offsetX;
                if (x2 > regionWidth) {
                    glyph.width -= x2 - regionWidth;
                    x2 = regionWidth;
                }
            }
            if (offsetY > 0) {
                y -= offsetY;
                if (y < 0) {
                    glyph.height += y;
                    y = 0;
                }
                y2 -= offsetY;
                if (y2 > regionHeight) {
                    var amount = y2 - regionHeight;
                    glyph.height -= amount;
                    glyph.yoffset += amount;
                    y2 = regionHeight;
                }
            }
            glyph.u = u + x * invTexWidth;
            glyph.u2 = u + x2 * invTexWidth;
            if (flipped) {
                glyph.v = v + y * invTexHeight;
                glyph.v2 = v + y2 * invTexHeight;
            } else {
                glyph.v2 = v + y * invTexHeight;
                glyph.v = v + y2 * invTexHeight;
            }
        }

        public void SetLineHeight(float height) {
            lineHeight = height * scaleY;
            down = flipped ? lineHeight : -lineHeight;
        }

        public void SetGlyph(int ch, Glyph glyph) {
            glyphs[ch / BitmapFont.PAGE_SIZE, ch & BitmapFont.PAGE_SIZE - 1] = glyph;
        }

        public Glyph GetFirstGlyph() {
            for (var p = 0; p<BitmapFont.PAGES; p++) {
                for (var g = 0; g<BitmapFont.PAGE_SIZE; g++) {
                    var glyph = glyphs[p,g];
                    if (glyph == null || glyph.height == 0 || glyph.width == 0) continue;
                    return glyph;
                }
            }
            throw new SdlException.RuntimeException("No glyphs found.");
        }
            
        public bool HasGlyph(char ch) {
            if (missingGlyph != null) return true;
            return GetGlyph(ch) != null;
        }
            
        public Glyph GetGlyph(char ch) {
            return glyphs[ch / BitmapFont.PAGE_SIZE, ch & BitmapFont.PAGE_SIZE - 1];
        }

        //  public getGlyphs(run: GlyphLayout.GlyphRun, str: string, start: int, end: int, tightBounds: bool)
        //      pass

        public int GetWrapIndex(int start, List<Glyph> glyphs) {
            return 0;
        }

        public bool IsBreakChar(char c) {
            return false;
        }


        public string GetImagePath(int index) {
            return imagePaths[index];
        }

        //  public setScale(scaleX: float, scaleY: float)
        //      pass

        //  public scale(amount: float)
        //      pass
    }
    //  }
}




            


