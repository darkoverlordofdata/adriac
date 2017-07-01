/**
 * BitmapFont.gs
 *
 */
using sdx;
using sdx.files;
using sdx.utils;
/**
 * parse the *.fnt file
 * use angelcode.com format
 */
namespace sdx.graphics {

    public class BitmapFont : Object {

        public const int LOG2_PAGE_SIZE = 9;
        public const int PAGE_SIZE = 1 << LOG2_PAGE_SIZE;
        public const int PAGES = 0x10000 / PAGE_SIZE;

        public sdx.utils.Json? dummy2;
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
        public double u;
        public double v;
        public double u2;
        public double v2;
        public int xoffset;
        public int yoffset;
        public int xadvance;
        public char[,] kerning; 
        public bool fixedWidth;
        public int page = 0;

        public int getKerning(char ch) {
            if (kerning != null) {
                var i = ch >> BitmapFont.LOG2_PAGE_SIZE;
                var j = ch & BitmapFont.PAGE_SIZE - 1;
                return kerning[i,j];
            }
            return 0;
        }

        public void setKerning(int ch, int value) {
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
        public double padTop;
        public double padRight;
        public double padBottom;
        public double padLeft;
        public double lineHeight;
        public double capHeight = 1;
        public double ascent;
        public double descent;
        public double down;
        public double blankLineScale = 1;
        public double scaleX = 1;
        public double scaleY = 1;
        public bool markupEnabled;
        public double cursorX;
        public Glyph[,] glyphs = new Glyph[BitmapFont.PAGES,BitmapFont.PAGE_SIZE];
        public Glyph missingGlyph;
        public double spaceWidth;
        public double xHeight = 1;
        public char[] breakChars;
        public char[] xChars = {'x', 'e', 'a', 'o', 'n', 's', 'r', 'c', 'u', 'm', 'v', 'w', 'z'};
        public char[] capChars = {'M', 'N', 'B', 'D', 'C', 'E', 'F', 'K', 'A', 'G', 'H', 'I', 'J', 'L', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};

        public BitmapFontData(FileHandle? fontFile = null, bool flip = false) {
            if (fontFile != null) {
                this.fontFile = fontFile;
                this.flipped = flip;
                load(fontFile, flip);
            }
        }

        public void load(FileHandle fontFile, bool flip) {
            if (imagePaths != null) throw new SdlException.IllegalStateException("Already loaded.");

            var json = sdx.utils.Json.parse(fontFile.read());
            var padding = json.member("font").member("info").member("padding").@string.split(",", 4);
            if (padding.length != 4) throw new SdlException.RuntimeException("Invalid padding.");
            padTop = int.parse(padding[0]);
            padRight = int.parse(padding[1]);
            padBottom = int.parse(padding[2]);
            padLeft = int.parse(padding[3]);
            var padY = padTop + padBottom;

            lineHeight = (int)json.member("font").member("common").member("lineHeight").number;
            var baseLine = (int)json.member("font").member("common").member("base").number;

            var pages = json.member("font").member("pages").@object.get_keys_as_array();
            var pageCount = pages.length;
            imagePaths = new string[pageCount];
            // Read each page definition.
            for (var p = 0; p<pageCount; p++) {
                var node = json.member("font").member("pages").member(pages[p]);
                var filename = node.member("file").@string;
                imagePaths[p] = fontFile.getParent().child(filename).getPath();
            }

            descent = 0;
            foreach (var ch in json.member("font").member("chars").member("char").array) {
                var glyph = new Glyph();
                    glyph.id = int.parse(ch.member("id").@string);
                    glyph.x = int.parse(ch.member("x").@string);
                    glyph.y = int.parse(ch.member("y").@string);
                    glyph.width = int.parse(ch.member("width").@string);
                    glyph.height = int.parse(ch.member("height").@string);
                    glyph.xoffset = int.parse(ch.member("xoffset").@string);
                    if (flip)
                        glyph.yoffset = int.parse(ch.member("yoffset").@string);
                    else
                        glyph.yoffset = -(glyph.height + int.parse(ch.member("yoffset").@string));
                    glyph.xadvance = int.parse(ch.member("xadvance").@string);

                    if (glyph.width > 0 && glyph.height > 0) descent = Math.fmin(baseLine + glyph.yoffset, descent);
            }
            descent += padBottom;
                
            var spaceGlyph = getGlyph(' ');
            if (spaceGlyph == null) {
                spaceGlyph = new Glyph();
                spaceGlyph.id = (int)' ';
                var xadvanceGlyph = getGlyph('l');
                if (xadvanceGlyph == null) xadvanceGlyph = getFirstGlyph();
                spaceGlyph.xadvance = xadvanceGlyph.xadvance;
                setGlyph(' ', spaceGlyph);
            }
            
            if (spaceGlyph.width == 0) {
                spaceGlyph.width = (int)(padLeft + spaceGlyph.xadvance + padRight);
                spaceGlyph.xoffset = (int)(-padLeft);
            }
            
            spaceWidth = spaceGlyph.width;

            Glyph xGlyph = null;

            foreach (var xChar in xChars) {
                xGlyph = getGlyph(xChar);
                if (xGlyph != null) break;
            }
            if (xGlyph == null) xGlyph = getFirstGlyph();
            xHeight = xGlyph.height - padY;

            Glyph capGlyph = null;
            foreach (var capChar in capChars) {
                capGlyph = getGlyph(capChar);
                if (capGlyph != null) break;
            }
            if (capGlyph == null) {
                for (var p = 0; p<BitmapFont.PAGES; p++) {
                    for (var g = 0; g<BitmapFont.PAGE_SIZE; g++) {
                        var glyph = glyphs[p,g];
                        if (glyph == null || glyph.height == 0 || glyph.width == 0) continue;
                        capHeight = Math.fmax(capHeight, glyph.height);
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

        public void setGlyphRegion(Glyph glyph, TextureRegion region) {
            var texture = region.texture;
            var invTexWidth = 1.0 / texture.width;
            var invTexHeight = 1.0 / texture.height;

            var offsetX = 0;
            var offsetY = 0;
            var u = region.u;
            var v = region.v;
            var regionWidth = region.getRegionWidth();
            var regionHeight = region.getRegionHeight();
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

        public void setLineHeight(double height) {
            lineHeight = height * scaleY;
            down = flipped ? lineHeight : -lineHeight;
        }

        public void setGlyph(int ch, Glyph glyph) {
            glyphs[ch / BitmapFont.PAGE_SIZE, ch & BitmapFont.PAGE_SIZE - 1] = glyph;
        }

        public Glyph getFirstGlyph() {
            for (var p = 0; p<BitmapFont.PAGES; p++) {
                for (var g = 0; g<BitmapFont.PAGE_SIZE; g++) {
                    var glyph = glyphs[p,g];
                    if (glyph == null || glyph.height == 0 || glyph.width == 0) continue;
                    return glyph;
                }
            }
            throw new SdlException.RuntimeException("No glyphs found.");
        }
            
        public bool hasGlyph(char ch) {
            if (missingGlyph != null) return true;
            return getGlyph(ch) != null;
        }
            
        public Glyph getGlyph(char ch) {
            return glyphs[ch / BitmapFont.PAGE_SIZE, ch & BitmapFont.PAGE_SIZE - 1];
        }

        //  public getGlyphs(run: GlyphLayout.GlyphRun, str: string, start: int, end: int, tightBounds: bool)
        //      pass

        public int getWrapIndex(int start, List<Glyph> glyphs) {
            return 0;
        }

        public bool isBreakChar(char c) {
            return false;
        }


        public string getImagePath(int index) {
            return imagePaths[index];
        }

        //  public setScale(scaleX: double, scaleY: double)
        //      pass

        //  public scale(amount: double)
        //      pass
    }
    //  }
}




            


