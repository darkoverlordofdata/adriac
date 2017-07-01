
namespace sdx.graphics {

    public enum TextureFilter {
        Nearest,
        Linear,
        MipMap,
        MipMapNearestNearest,
        MipMapLinearNearest,
        MipMapNearestLinear,
        MipMapLinearLinear;
        public static TextureFilter from(string value) {
            switch (value)  {
                case "Nearest": return Nearest;
                case "Linear": return Linear;
                case "MipMap": return MipMap;
                case "MipMapNearestNearest": return MipMapNearestNearest;
                case "MipMapLinearNearest": return MipMapLinearNearest;
                case "MipMapNearestLinear": return MipMapNearestLinear;
                case "MipMapLinearLinear": return MipMapLinearLinear;
                default: throw new SdlException.NotReached("TextureFilter.from["+value+"]");
            }
        }

        public bool isMipMap() {
            return this != TextureFilter.Nearest && this != TextureFilter.Linear;
        }


        public string to_string() {
            switch (this) {
                case Nearest: return "Nearest";
                case Linear: return "Linear";
                case MipMap: return "MipMap";
                case MipMapNearestNearest: return "MipMapNearestNearest";
                case MipMapLinearNearest: return "MipMapLinearNearest";
                case MipMapNearestLinear: return "MipMapNearestLinear";
                case MipMapLinearLinear: return "MipMapLinearLinear";
                default: throw new SdlException.NotReached("TextureFilter.to_string["+this.to_string()+"]");
            }
        }
    }


    public enum TextureWrap {
        ClampToEdge = 1,
        Repeat = 2;
        public static TextureWrap from(string value) {
            switch (value)  {
                case "ClampToEdge": return ClampToEdge;
                case "Repeat": return Repeat;
                default: throw new SdlException.NotReached("TextureWrap.from["+value+"]");
            }
        }
        public string to_string() {
            switch (this) {
                case ClampToEdge: return "ClampToEdge";
                case Repeat: return "Repeat";
                default: throw new SdlException.NotReached("TextureWrap.to_string["+this.to_string()+"]");
            }
        }
    }

    public enum Format {
        Alpha,
        Intensity,
        LuminanceAlpha,
        RGB565,
        RGBA4444,
        RGB888,
        RGBA8888;
        public static Format from(string value) {
            switch (value)  {
                case "Alpha": return Alpha;
                case "Intensity": return Intensity;
                case "LuminanceAlpha": return LuminanceAlpha;
                case "RGB565": return RGB565;
                case "RGBA4444": return RGBA4444;
                case "RGB888": return RGB888;
                case "RGBA8888": return RGBA8888;
                default: throw new SdlException.NotReached("Format.from["+value+"]");
            }
        }
        public string to_string() {
            switch (this) {
                case Alpha: return "Alpha";
                case Intensity: return "Intensity";
                case LuminanceAlpha: return "LuminanceAlpha";
                case RGB565: return "RGB565";
                case RGBA4444: return "RGBA4444";
                case RGB888: return "RGB888";
                case RGBA8888: return "RGBA8888";
                default: throw new SdlException.NotReached("Format.to_string["+this.to_string()+"]");
            }
        }

    }

}