/**
 * TextureRegion.gs
 *
 */
using GLib;
using sdx.graphics;

namespace sdx.graphics {

    public class TextureRegion : Object {
        public Surface.TextureSurface? texture;
        public int top;
        public int left;
        public int width;
        public int height;
        public int regionWidth;
        public int regionHeight;
        public double u;
        public double v;
        public double u2;
        public double v2;

        public TextureRegion(Surface.TextureSurface texture, int x=0, int y=0, int width=0, int height=0) {
            width = width == 0 ? texture.width : width;
            height = height == 0 ? texture.height : height;
            this.texture = texture;
            this.top = x;
            this.left = y;
            this.width = width;
            this.height = height; 
            setRegionXY(x, y, width, height);
        }

        public void setRegion(double u, double v, double u2, double v2) {
            var texWidth = this.width;
            var texHeight = this.height;
            regionWidth =(int)Math.round(Math.fabs(u2 - u) * texWidth);
            regionHeight =(int)Math.round(Math.fabs(v2 - v) * texHeight);
            if (regionWidth == 1 && regionHeight == 1) {
                var adjustX = 0.25 / texWidth;
                u = adjustX;
                u2 = adjustX;
                var adjustY = 0.25 / texHeight;
                v = adjustY;
                v2 = adjustY;
            }
        }

        public void setRegionXY(int x, int y, int width, int height) {
            var invTexWidth = 1 / this.width;
            var invTexHeight = 1 / this.height;
            setRegion(x * invTexWidth, y * invTexHeight,(x + width) * invTexWidth,(y + height) * invTexHeight);
            regionWidth =(int)Math.fabs(width);
            regionHeight =(int)Math.fabs(height);
        }

        public void setByRegion(TextureRegion region) {
            texture = region.texture;
            setRegion(region.u, region.v, region.u2, region.v2);
        }

        public void setByRegionXY(TextureRegion region, int x, int y, int width, int height) {            
            texture = region.texture;
            setRegionXY(region.getRegionX()+x, region.getRegionY()+y, width, height);
        }

        public void flip(bool x, bool y) {
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

        public double getU() { 
            return u;
        }

        public void setU(double u) { 
            this.u = u;
            regionWidth = (int)Math.round(Math.fabs(u2 - u) * this.width);
        }

        public double getV() {
            return v;
        }

        public void setV(double v) { 
            this.v = v;
            regionHeight = (int)Math.round(Math.fabs(v2 - v) * this.height);
        }

        public double getU2() {
            return u2;
        }

        public void setU2(double u2) { 
            this.u2 = u2;
            regionWidth = (int)Math.round(Math.fabs(u2 - u) * this.width);
        }

        public double getV2() {
            return v2;
        }

        public void setV2(double v2) { 
            this.v2 = v2;
            regionHeight = (int)Math.round(Math.fabs(v2 - v) * this.height);
        }

        public int getRegionX() {
            return (int)Math.round(u * this.width);
        }

        public void setRegionX(int x) {
            setU(x /(double)this.width);
        }

        public int getRegionY() {
            return (int)Math.round(v * this.height);
        }        

        public void setRegionY(int y) {
            setV(y /this.height);
        }

        /** Returns the region's width. */
        public int getRegionWidth() {
            return regionWidth;
        }

        public void setRegionWidth(int width) {
            if (isFlipX())
                setU(u2 + width /(double)this.width);
             else 
                setU2(u + width /(double)this.width);
        }
        

        /** Returns the region's height. */
        public int getRegionHeight() {
            return regionHeight;
        }

        public void setRegionHeight(int height) { 
            if (isFlipY())
                setV(v2 + height /(double)this.height);	
             else 
                setV2(v + height /(double)this.height);
        }
        
        public bool isFlipX() {
            return u > u2;
        }

        public bool isFlipY() {
            return v > v2;
        }
    }
}