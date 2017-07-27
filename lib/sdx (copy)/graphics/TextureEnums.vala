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

namespace Sdx.Graphics {

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
                default: return Nearest;
                //  default: throw new SdlException.NotReached("TextureFilter.from["+value+"]");
            }
        }

        public bool isMipMap() {
            return this != TextureFilter.Nearest && this != TextureFilter.Linear;
        }


        public string ToString() {
            switch (this) {
                case Nearest: return "Nearest";
                case Linear: return "Linear";
                case MipMap: return "MipMap";
                case MipMapNearestNearest: return "MipMapNearestNearest";
                case MipMapLinearNearest: return "MipMapLinearNearest";
                case MipMapNearestLinear: return "MipMapNearestLinear";
                case MipMapLinearLinear: return "MipMapLinearLinear";
                default: return "Nearest";
                //  default: throw new SdlException.NotReached("TextureFilter.ToString["+this.ToString()+"]");
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
                default: return ClampToEdge;
                //  default: throw new SdlException.NotReached("TextureWrap.from[%s]", value);
            }
        }
        public string ToString() {
            switch (this) {
                case ClampToEdge: return "ClampToEdge";
                case Repeat: return "Repeat";
                default: return "ClampToEdge";
                //  default: throw new SdlException.NotReached("TextureWrap.ToString[%s]", this.ToString());
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
                //  default: throw new SdlException.NotReached("Format.from["+value+"]");
                default: return RGBA8888;
            }
        }
        public string ToString() {
            switch (this) {
                case Alpha: return "Alpha";
                case Intensity: return "Intensity";
                case LuminanceAlpha: return "LuminanceAlpha";
                case RGB565: return "RGB565";
                case RGBA4444: return "RGBA4444";
                case RGB888: return "RGB888";
                case RGBA8888: return "RGBA8888";
                //  default: throw new SdlException.NotReached("Format.ToString["+this.ToString()+"]");
                default: return "RGBA8888";
            }
        }

    }

}