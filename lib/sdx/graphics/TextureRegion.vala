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
 * TextureRegion.gs
 *
 */
using GLib;
using Sdx.Graphics;

namespace Sdx.Graphics {

    public class TextureRegion : Object {
        public Surface.TextureSurface? texture;
        public int top;
        public int left;
        public int width;
        public int height;
        public int regionWidth;
        public int regionHeight;
        public float u;
        public float v;
        public float u2;
        public float v2;

        /**
         * extra fields for use by subclass AtlasRegion
         * They need to be declared here because subclasses can't 
         * add fields.
         */
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

        public class FromTexture : TextureRegion {
            public FromTexture(Surface.TextureSurface texture, int x=0, int y=0, int width=0, int height=0) {
                width = width == 0 ? texture.width : width;
                height = height == 0 ? texture.height : height;
                this.texture = texture;
                this.top = x;
                this.left = y;
                this.width = width;
                this.height = height; 
                SetRegionXY(x, y, width, height);
            }


        }
        public class FromRegion : TextureRegion {
            public FromRegion(TextureRegion region, int x=0, int y=0, int width=0, int height=0) {
                width = width == 0 ? region.texture.width : width;
                height = height == 0 ? region.texture.height : height;
                this.texture = region.texture;
                this.top = x;
                this.left = y;
                this.width = width;
                this.height = height; 
                SetRegionXY(region.GetRegionX() + x, region.GetRegionY() + y, width, height);
            }


        }

        //  public TextureRegion(Surface.TextureSurface texture, int x=0, int y=0, int width=0, int height=0) {
        //      width = width == 0 ? texture.width : width;
        //      height = height == 0 ? texture.height : height;
        //      this.texture = texture;
        //      this.top = x;
        //      this.left = y;
        //      this.width = width;
        //      this.height = height; 
        //      SetRegionXY(x, y, width, height);
        //  }

        public void SetRegion(float u, float v, float u2, float v2) {
            var texWidth = this.width;
            var texHeight = this.height;
            regionWidth =(int)GLib.Math.round(GLib.Math.fabs(u2 - u) * texWidth);
            regionHeight =(int)GLib.Math.round(GLib.Math.fabs(v2 - v) * texHeight);
            if (regionWidth == 1 && regionHeight == 1) {
                var adjustX = 0.25f / texWidth;
                u = adjustX;
                u2 = adjustX;
                var adjustY = 0.25f / texHeight;
                v = adjustY;
                v2 = adjustY;
            }
        }

        public void SetRegionXY(int x, int y, int width, int height) {
            var invTexWidth = 1 / this.width;
            var invTexHeight = 1 / this.height;
            SetRegion(x * invTexWidth, y * invTexHeight,(x + width) * invTexWidth,(y + height) * invTexHeight);
            regionWidth =(int)GLib.Math.fabs(width);
            regionHeight =(int)GLib.Math.fabs(height);
        }

        public void SetByRegion(TextureRegion region) {
            texture = region.texture;
            SetRegion(region.u, region.v, region.u2, region.v2);
        }

        public void SetByRegionXY(TextureRegion region, int x, int y, int width, int height) {            
            texture = region.texture;
            SetRegionXY(region.GetRegionX()+x, region.GetRegionY()+y, width, height);
        }

        public void Flip(bool x, bool y) {
            if (x) {
                var temp = u;
                u = u2;
                u2 = temp;
            }
            if (y) {
                var temp = v;
                v = v2;
                v2 = temp;
            }
        }

        public float GetU() { 
            return u;
        }

        public void SetU(float u) { 
            this.u = u;
            regionWidth = (int)GLib.Math.round(GLib.Math.fabs(u2 - u) * this.width);
        }

        public float GetV() {
            return v;
        }

        public void SetV(float v) { 
            this.v = v;
            regionHeight = (int)GLib.Math.round(GLib.Math.fabs(v2 - v) * this.height);
        }

        public float GetU2() {
            return u2;
        }

        public void SetU2(float u2) { 
            this.u2 = u2;
            regionWidth = (int)GLib.Math.round(GLib.Math.fabs(u2 - u) * this.width);
        }

        public float GetV2() {
            return v2;
        }

        public void SetV2(float v2) { 
            this.v2 = v2;
            regionHeight = (int)GLib.Math.round(GLib.Math.fabs(v2 - v) * this.height);
        }

        public int GetRegionX() {
            return (int)GLib.Math.round(u * this.width);
        }

        public void SetRegionX(int x) {
            SetU(x /(float)this.width);
        }

        public int GetRegionY() {
            return (int)GLib.Math.round(v * this.height);
        }        

        public void SetRegionY(int y) {
            SetV(y /this.height);
        }

        /** Returns the region's width. */
        public int GetRegionWidth() {
            return regionWidth;
        }

        public void SetRegionWidth(int width) {
            if (IsFlipX())
                SetU(u2 + width /(float)this.width);
             else 
                SetU2(u + width /(float)this.width);
        }
        

        /** Returns the region's height. */
        public int GetRegionHeight() {
            return regionHeight;
        }

        public void SetRegionHeight(int height) { 
            if (IsFlipY())
                SetV(v2 + height /(float)this.height);	
             else 
                SetV2(v + height /(float)this.height);
        }
        
        public bool IsFlipX() {
            return u > u2;
        }

        public bool IsFlipY() {
            return v > v2;
        }
    }
}