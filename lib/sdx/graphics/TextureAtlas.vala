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
using Sdx.Files;
using Sdx.Graphics;

namespace Sdx.Graphics 
{

    /**
     * load a libgdx format atlas
     */
    public class TextureAtlas : Object {
        public List<AtlasRegion> regions = new List<AtlasRegion>();
        /**
         * @param packFile handle
         * @param imageDir handle
         * @param flip images?
         */
        public TextureAtlas(FileHandle packFile, FileHandle? imageDir=null, bool flip=false) {
            Load(new TextureAtlasData(packFile, imageDir == null ? packFile.GetParent() : imageDir, flip));
        }


        public AtlasRegion? FindRegion(string name, int index=-1) {
            foreach (var region in regions) {   
                if (index == -1) {
                    if (region.name == name) return region;
                } else {
                    if (region.name == name && region.index == index) return region;
                }
            }
            return null;
        }

        public Sprite? CreateSprite(string name, int index=-1) { 
            foreach (var region in regions) {
                if (index == -1) {
                    if (region.name == name) {
                        return new Sprite.AtlasSprite(region);
                    }
                } else {    
                    if (region.name == name && region.index == index)
                        return new Sprite.AtlasSprite(region);
                }
            }
            return null;
        }
        
        public Sprite? CreateUI(string name, string text, Sdx.Font font, SDL.Video.Color color, int width = 125, int height = 80) { 
            return new Sprite.UISprite(CreatePatch(name), text, font, color, width, height);
        }

        public NinePatch? CreatePatch(string name) {
            foreach (var region in regions) {
                if (region.name == name) {
                    var splits = region.splits;
                    if (splits == null) throw new SdlException.IllegalArgumentException("Region does not have ninepatch splits: " + name);
                    var patch = new NinePatch(region, splits[0], splits[1], splits[2], splits[3]);
                    //  if (region.pads != null) patch.SetPadding(region.pads[0], region.pads[1], region.pads[2], region.pads[3]);
                    return patch;
                }
            }
            return null;
        }

        private void Load(TextureAtlasData data) {
        
            Surface.TextureSurface? texture = null;
            var pageToTexture = new Surface.TextureSurface[0];

            foreach (var page in data.pages) {

                if (page.texture == null) {
                    texture = new Surface.TextureSurface(page.textureFile); //, page.format, page.useMipMaps)
                } else {    
                    texture = page.texture;
                }
                texture.SetFilter(page.minFilter, page.magFilter);
                texture.SetWrap(page.uWrap, page.vWrap);
                pageToTexture += texture;
            }

            foreach (var region in data.regions) {
                var width = region.width;
                var height = region.height;
                var atlasRegion = new AtlasRegion(pageToTexture[region.page.id], region.left, region.top,
				    region.rotate ? height : width, region.rotate ? width : height);

                atlasRegion.index = region.index;
                atlasRegion.name = region.name;
                atlasRegion.offsetX = region.offsetX;
                atlasRegion.offsetY = region.offsetY;
                atlasRegion.originalHeight = region.originalHeight;
                atlasRegion.originalWidth = region.originalWidth;
                atlasRegion.rotate = region.rotate;
                atlasRegion.splits = region.splits;
                atlasRegion.pads = region.pads;
                if (region.flip) atlasRegion.Flip(false, true);
                regions.Add(atlasRegion);
            }
        }

    }

    /** 
     * Describes the region of a packed image and provides information about the original image before it was packed. 
     */
    public class AtlasRegion : TextureRegion.FromTexture {
        
        /** 
         * The number at the end of the original image file name, or -1 if none.
         * 
         * When sprites are packed, if the original file name ends with a number, it is stored as the index and is not considered as
         * part of the sprite's name. This is useful for keeping animation frames in order.
         * @see TextureAtlas.FindRegion
         */
        public AtlasRegion(Surface.TextureSurface texture, int x, int y, int width, int height) {
            base(texture, x, y, width, height);
        }


    }
    /**
     * povo - one for each atlas file 
     */
    public class Page : Object {
        public static int uniqueId;
        public int id;
        public FileHandle? textureFile;
        public Surface.TextureSurface? texture;
        public int height;
        public int width;
        public bool useMipMaps;
        public Format format;
        public int minFilter;
        public int magFilter;
        public int uWrap;
        public int vWrap;
        public Page(FileHandle handle, int width, int height, bool useMipMaps, Format format, int minFilter,
            int magFilter, int uWrap, int vWrap) {
            this.id = uniqueId++;
            this.textureFile = handle;
            this.height = height;
            this.width = width;
            this.useMipMaps = useMipMaps;
            this.format = format;
            this.minFilter = minFilter;
            this.magFilter = magFilter;
            this.uWrap = uWrap;
            this.vWrap = vWrap;
        }
    }

    /**
     * povo - one for each region in the atlas file 
     */
    public class Region : Object {
        public Page page;
        public int index;
        public string name;
        public int offsetX;
        public int offsetY;
        public int originalWidth;
        public int originalHeight;
        public bool rotate;
        public int left;
        public int top;
        public int width;
        public int height;
        public bool flip;
        public int[] splits;
        public int[] pads;
        public bool slice9;
        public Region(Page page, int left, int top, int width, int height, string name, bool rotatate) {
            this.page = page;
            this.left = left;
            this.top = top;
            this.width = width;
            this.height = height;
            this.name = name;
            this.rotate = rotate;
            this.slice9 = false;
        }
    }

    public class TextureAtlasData : Object {
        /** 
         * tuple used to return the parsed values 
         */
        public static TextureAtlasData instance;
        public static string[] tuple;
	    /** 
         * Returns the number of tuple values read (1, 2 or 4). 
         */
        public static int ReadTuple(DataInputStream reader) {
            var line = reader.ReadLine();
            var ts = line.Split(":");
            if (ts.length == 0) throw new IOException.InvalidData("invalid line: %s", line);
            tuple = ts[1].Split(",");
            for (var i=0; i<tuple.length; i++) {
                tuple[i] = tuple[i];
            }
            return tuple.length;
        }

        /** 
         * Returns the single value 
         */
        public static string ReadValue(DataInputStream reader) {
            var line = reader.ReadLine();
            var ts = line.Split(":");
            if (ts.length == 0) throw new IOException.InvalidData("invalid line: %s ", line);
            return ts[1];
        }

        public List<Page> pages;
        public List<Region> regions;

        /**
         * @param packFile the atlas file
         * @param imagesDir for the bitmap(s)
         * @param flip vert|horz|none
         */
        public TextureAtlasData(FileHandle packFile, FileHandle imagesDir, bool flip) {
            pages = new List<Page>();
            regions = new List<Region>();
            var reader = new DataInputStream(packFile.Read());
            try {
                Page pageImage = null;
                while (true) {
                    var line = reader.ReadLine();
                    if (line == null) break;
                    line = line.Replace("\r", "");
                    if (line.length == 0) { 
                        pageImage = null;
                    } else if (pageImage == null) {
                        var file = imagesDir.Child(line);
                        var width = 0;
                        var height = 0;
                        if (ReadTuple(reader) == 2) {
                            width = int.Parse(tuple[0]);
                            height = int.Parse(tuple[1]);
                            ReadTuple(reader);
                        }
                        var format = Format.from(tuple[0].strip());
                        ReadTuple(reader);
                        var min = TextureFilter.from(tuple[0].strip());
                        var max = TextureFilter.from(tuple[1].strip());
                        var direction = ReadValue(reader);
                        var repeatX = TextureWrap.ClampToEdge;
                        var repeatY = TextureWrap.ClampToEdge;
                        if (direction == "x") {
                            repeatX = TextureWrap.Repeat;
                        } else if (direction == "y") {
                            repeatY = TextureWrap.Repeat;
                        } else if (direction == "xy") {
                            repeatX = TextureWrap.Repeat;
                            repeatY = TextureWrap.Repeat;
                        }

                        pageImage = new Page(file, width, height, min.isMipMap(), format, min, max, repeatX, repeatY);
                        pages.Add(pageImage);
                    } else {
                        var rotate = bool.Parse(ReadValue(reader));

                        ReadTuple(reader);
                        var left = int.Parse(tuple[0]);
                        var top = int.Parse(tuple[1]);

                        ReadTuple(reader);
                        var width = int.Parse(tuple[0]);
                        var height = int.Parse(tuple[1]);

                        var region = new Region(pageImage, left, top, width, height, line, rotate);

                        if (ReadTuple(reader) == 4) {
                            region.slice9 = true;
                            region.splits = { int.Parse(tuple[0]), int.Parse(tuple[1]), 
                                int.Parse(tuple[2]), int.Parse(tuple[3]) };

                            if (ReadTuple(reader) == 4) {
                                region.pads = { int.Parse(tuple[0]), int.Parse(tuple[1]), 
                                    int.Parse(tuple[2]), int.Parse(tuple[3]) };

                                ReadTuple(reader);
                            }
                        }

                        region.originalWidth = int.Parse(tuple[0]);
                        region.originalHeight = int.Parse(tuple[1]);

                        ReadTuple(reader);
                        region.offsetX = int.Parse(tuple[0]);
                        region.offsetY = int.Parse(tuple[1]);

                        region.index = int.Parse(ReadValue(reader));

                        if (flip) region.flip = true;

                        regions.Add(region);
                    }
                }
            } catch (Error e) {
                print(e.message);
            }
        }


    }
    
}
