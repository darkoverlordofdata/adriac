/**
 * TextureAtlas.gs
 *
 */
using sdx.files;
using sdx.graphics;

namespace sdx.graphics {

    /**
     *  load a libgdx format atlas
     */
    public class TextureAtlas : Object {
        public Surface.TextureSurface? texture;
        public List<AtlasRegion> regions = new List<AtlasRegion>();

        /**
         * @param root location of resources
         */
        public TextureAtlas(FileHandle packFile, FileHandle? imageDir=null, bool flip=false) {
            load(new TextureAtlasData(packFile, imageDir == null ? packFile.getParent() : imageDir, flip));
        }


        public AtlasRegion? findRegion(string name, int index=-1) {
            foreach (var region in regions) {   
                if (index == -1) {
                    if (region.name == name) return region;
                } else {
                    if (region.name == name && region.index == index) return region;
                }
            }
            return null;
        }

        public Sprite? createSprite(string name, int index=-1) { 
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
        

        /**
         * @param data config to load images from
         */
        public void load(TextureAtlasData data) {
        
            texture = null;
            var pageToTexture = new HashTable<string,Surface.TextureSurface>(str_hash, str_equal);
            foreach (var page in data.pages) {

                if (page.texture == null) {
                    texture = new Surface.TextureSurface(page.textureFile); //, page.format, page.useMipMaps)
                } else {    
                    texture = page.texture;
                }
                texture.setFilter(page.minFilter, page.magFilter);
                texture.setWrap(page.uWrap, page.vWrap);
                pageToTexture.insert(page.id.to_string(), texture);
            }

            foreach (var region in data.regions) {
                var width = region.width;
                var height = region.height;
                var atlasRegion = new AtlasRegion(pageToTexture.@get(region.page.id.to_string()), region.left, region.top,
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
                if (region.flip) atlasRegion.flip(false, true);
                regions.append(atlasRegion);
            }
        }

    }

    /** Describes the region of a packed image and provides information about the original image before it was packed. */
    public class AtlasRegion : Object {
        
        public TextureRegion rg;
        /** The number at the end of the original image file name, or -1 if none.<br>
        * <br>
        * When sprites are packed, if the original file name ends with a number, it is stored as the index and is not considered as
        * part of the sprite's name. This is useful for keeping animation frames in order.
        * @see TextureAtlas#findRegions(String) */
        public int index;
        /** The name of the original image file, up to the first underscore. Underscores denote special instructions to the texture
        * packer. */
        public string name;
        /** The offset from the left of the original image to the left of the packed image, after whitespace was removed for packing. */
        public int offsetX;
        /** The offset from the bottom of the original image to the bottom of the packed image, after whitespace was removed for
        * packing. */
        public int offsetY;
        /** The width of the image, after whitespace was removed for packing. */
        public int packedWidth;
        /** The height of the image, after whitespace was removed for packing. */
        public int packedHeight;
        /** The width of the image, before whitespace was removed and rotation was applied for packing. */
        public int originalWidth;
        /** The height of the image, before whitespace was removed for packing. */
        public int originalHeight;
        /** If true, the region has been rotated 90 degrees counter clockwise. */
        public bool rotate;
        /** The ninepatch splits, or null if not a ninepatch. Has 4 elements: left, right, top, bottom. */
        public int[] splits;
        /** The ninepatch pads, or null if not a ninepatch or the has no padding. Has 4 elements: left, right, top, bottom. */
        public int[] pads;

        public AtlasRegion(Surface.TextureSurface texture, int x, int y, int width, int height) {
            rg = new TextureRegion(texture, x, y, width, height);
        }


        public void flip(bool x, bool y) {
            rg.flip(x, y);
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
        public Region(Page page, int left, int top, int width, int height, string name, bool rotatate) {
            this.page = page;
            this.left = left;
            this.top = top;
            this.width = width;
            this.height = height;
            this.name = name;
            this.rotate = rotate;
        }
    }

    public class TextureAtlasData : Object {
        /** tuple used to return the parsed values */
        public static string[] tuple;
	    /** Returns the number of tuple values read (1, 2 or 4). */
        public static int readTuple(DataInputStream reader) {
            var line = reader.read_line();
            var ts = line.split(":");
            if (ts.length == 0) throw new IOException.InvalidData("invalid line "+line);
            tuple = ts[1].split(",");
            for (var i=0; i<tuple.length; i++) {
                tuple[i] = tuple[i];
            }
            return tuple.length;
        }

        /** Returns the single value */
        public static string readValue(DataInputStream reader) {
            var line = reader.read_line();
            var ts = line.split(":");
            if (ts.length == 0) throw new IOException.InvalidData("invalid line "+line);
            return ts[1];
        }

        public List<Page> pages;
        public List<Region> regions;

        /**
         * @param packFile the atlas file
         * @param imagesDir for the bitmap(s)
         * @param flip
         */
        public TextureAtlasData(FileHandle packFile, FileHandle imagesDir, bool flip) {
            pages = new List<Page>();
            regions = new List<Region>();
            var reader = new DataInputStream(packFile.read());
            try {
                Page pageImage = null;
                while (true) {
                    var line = reader.read_line();
                    if (line == null) break;
                    if (line.length == 0) { 
                        pageImage = null;
                    } else if (pageImage == null) {
                        var file = imagesDir.child(line);
                        var width = 0;
                        var height = 0;
                        if (readTuple(reader) == 2) {
                            width = int.parse(tuple[0]);
                            height = int.parse(tuple[1]);
                            readTuple(reader);
                        }
                        var format = Format.from(tuple[0].strip());
                        readTuple(reader);
                        var min = TextureFilter.from(tuple[0].strip());
                        var max = TextureFilter.from(tuple[1].strip());
                        var direction = readValue(reader);
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
                        pages.append(pageImage);
                    } else {
                        var rotate = bool.parse(readValue(reader));

                        readTuple(reader);
                        var left = int.parse(tuple[0]);
                        var top = int.parse(tuple[1]);

                        readTuple(reader);
                        var width = int.parse(tuple[0]);
                        var height = int.parse(tuple[1]);

                        var region = new Region(pageImage, left, top, width, height, line, rotate);

                        if (readTuple(reader) == 4) {
                            region.splits = { int.parse(tuple[0]), int.parse(tuple[1]), 
                                int.parse(tuple[2]), int.parse(tuple[3]) };

                            if (readTuple(reader) == 4) {
                                region.pads = { int.parse(tuple[0]), int.parse(tuple[1]), 
                                    int.parse(tuple[2]), int.parse(tuple[3]) };

                                readTuple(reader);
                            }
                        }

                        region.originalWidth = int.parse(tuple[0]);
                        region.originalHeight = int.parse(tuple[1]);

                        readTuple(reader);
                        region.offsetX = int.parse(tuple[0]);
                        region.offsetY = int.parse(tuple[1]);

                        region.index = int.parse(readValue(reader));

                        if (flip) region.flip = true;

                        regions.append(region);
                    }
                }
            } catch (Error e) {
                print(e.message);
            }
        }


    }
    
}
