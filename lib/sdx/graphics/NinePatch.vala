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
namespace Sdx.Graphics 
{
    /**
     * patch image
     * 
     */
    public class NinePatch : Object {
 

        private const int TOP_LEFT = 0;
        private const int TOP_CENTER = 1;
        private const int TOP_RIGHT = 2;
        private const int MIDDLE_LEFT = 3;
        private const int MIDDLE_CENTER = 4;
        private const int MIDDLE_RIGHT = 5;
        private const int BOTTOM_LEFT = 6;
        private const int BOTTOM_CENTER = 7;
        private const int BOTTOM_RIGHT = 8;

        public Surface.TextureSurface? texture;
        private int bottomLeft = -1;
        private int bottomCenter = -1;
        private int bottomRight = -1;
        private int middleLeft = -1;
        private int middleCenter = -1;
        private int middleRight = -1;
        private int topLeft = -1;
        private int topCenter = -1;
        private int topRight = -1;
        public int top;
        public int left;
        public int right;
        public int bottom;

        private float leftWidth;
        private float rightWidth;
        private float middleWidth;
        private float middleHeight;
        private float topHeight;
        private float bottomHeight;

        public Blit slice[9];
        private int idx;
        private SDL.Video.Color color = Color.White;
        private float padLeft = -1;
        private float padRight = -1;
        private float padTop = -1;
        private float padBottom = -1;

        private int sourceTop;
        private int sourceLeft;

        public NinePatch(TextureRegion region, int left, int right, int top, int bottom)
        {
            idx = 0;
            sourceTop = region.top;
            sourceLeft = region.left;
            this.top = top;
            this.left = left;
            this.right = right;
            this.bottom = bottom;
            if (region == null) throw new SdlException.IllegalArgumentException("region cannot be null.");
            var middleWidth = region.GetRegionWidth() - left - right;
            var middleHeight = region.GetRegionHeight() - top - bottom;

            var patches = new TextureRegion[9];
            if (top > 0)
            {
                if (left > 0) patches[TOP_LEFT] = new TextureRegion.FromRegion(region, 0, 0, left, top);
                if (middleWidth > 0) patches[TOP_CENTER] = new TextureRegion.FromRegion(region, left, 0, middleWidth, top);
                if (right > 0) patches[TOP_RIGHT] = new TextureRegion.FromRegion(region, left + middleWidth, 0, right, top);
            }
            if (middleHeight > 0)
            {
                if (left > 0) patches[MIDDLE_LEFT] = new TextureRegion.FromRegion(region, 0, top, left, middleHeight);
                if (middleWidth > 0) patches[MIDDLE_CENTER] = new TextureRegion.FromRegion(region, left, top, middleWidth, middleHeight);
                if (right > 0) patches[MIDDLE_RIGHT] = new TextureRegion.FromRegion(region, left + middleWidth, top, right, middleHeight);
            }
            if (bottom > 0) 
            {
                if (left > 0) patches[BOTTOM_LEFT] = new TextureRegion.FromRegion(region, 0, top + middleHeight, left, bottom);
                if (middleWidth > 0) patches[BOTTOM_CENTER] = new TextureRegion.FromRegion(region, left, top + middleHeight, middleWidth, bottom);
                if (right > 0) patches[BOTTOM_RIGHT] = new TextureRegion.FromRegion(region, left + middleWidth, top + middleHeight, right, bottom);
            }

            // If split only vertical, move splits from right to center.
            if (left == 0 && middleWidth == 0)
            {
                patches[TOP_CENTER] = patches[TOP_RIGHT];
                patches[MIDDLE_CENTER] = patches[MIDDLE_RIGHT];
                patches[BOTTOM_CENTER] = patches[BOTTOM_RIGHT];
                patches[TOP_RIGHT] = null;
                patches[MIDDLE_RIGHT] = null;
                patches[BOTTOM_RIGHT] = null;
            }
            // If split only horizontal, move splits from bottom to center.
            if (top == 0 && middleHeight == 0)
            {
                patches[MIDDLE_LEFT] = patches[BOTTOM_LEFT];
                patches[MIDDLE_CENTER] = patches[BOTTOM_CENTER];
                patches[MIDDLE_RIGHT] = patches[BOTTOM_RIGHT];
                patches[BOTTOM_LEFT] = null;
                patches[BOTTOM_CENTER] = null;
                patches[BOTTOM_RIGHT] = null;
            }
            Load(patches);
        }   

        private void Load(TextureRegion[] patches) 
        {
            var color = Color.White;

            if (patches[TOP_LEFT] != null)
            { 
                topLeft = Add(patches[TOP_LEFT], color, false, false);
                leftWidth = (int)GLib.Math.fmax(leftWidth, patches[TOP_LEFT].GetRegionWidth());
                topHeight = (int)GLib.Math.fmax(topHeight, patches[TOP_LEFT].GetRegionHeight());
            }
            if (patches[TOP_CENTER] != null)
            { 
                topCenter = Add(patches[TOP_CENTER], color, true, false);
                middleWidth = (int)GLib.Math.fmax(middleWidth, patches[TOP_CENTER].GetRegionWidth());
                topHeight = (int)GLib.Math.fmax(topHeight, patches[TOP_CENTER].GetRegionHeight());
            }
            if (patches[TOP_RIGHT] != null)
            { 
                topRight = Add(patches[TOP_RIGHT], color, false, false);
                rightWidth = (int)GLib.Math.fmax(rightWidth, patches[TOP_RIGHT].GetRegionWidth());
                topHeight = (int)GLib.Math.fmax(topHeight, patches[TOP_RIGHT].GetRegionHeight());
            }
            if (patches[MIDDLE_LEFT] != null)
            { 
                middleLeft = Add(patches[MIDDLE_LEFT], color, false, true);
                leftWidth = (int)GLib.Math.fmax(leftWidth, patches[MIDDLE_LEFT].GetRegionWidth());
                middleHeight = (int)GLib.Math.fmax(middleHeight, patches[MIDDLE_LEFT].GetRegionHeight());
            }            
            if (patches[MIDDLE_CENTER] != null)
            { 
                middleCenter = Add(patches[MIDDLE_CENTER], color, true, true);
                middleWidth = (int)GLib.Math.fmax(middleWidth, patches[MIDDLE_CENTER].GetRegionWidth());
                middleHeight = (int)GLib.Math.fmax(middleHeight, patches[MIDDLE_CENTER].GetRegionHeight());
            }
            if (patches[MIDDLE_RIGHT] != null)
            { 
                middleRight = Add(patches[MIDDLE_RIGHT], color, false, true);
                rightWidth = (int)GLib.Math.fmax(rightWidth, patches[MIDDLE_RIGHT].GetRegionWidth());
                middleHeight = (int)GLib.Math.fmax(middleHeight, patches[MIDDLE_RIGHT].GetRegionHeight());
            }
            if (patches[BOTTOM_LEFT] != null)
            {
                bottomLeft = Add(patches[BOTTOM_LEFT], color, false, false);
                leftWidth = patches[BOTTOM_LEFT].GetRegionWidth();
                bottomHeight = patches[BOTTOM_LEFT].GetRegionHeight();
            }
            if (patches[BOTTOM_CENTER] != null)
            { 
                bottomCenter = Add(patches[BOTTOM_CENTER], color, true, false);
                middleWidth = (int)GLib.Math.fmax(middleWidth, patches[BOTTOM_CENTER].GetRegionWidth());
                bottomHeight = (int)GLib.Math.fmax(bottomHeight, patches[BOTTOM_CENTER].GetRegionHeight());
            }
            if (patches[BOTTOM_RIGHT] != null)
            { 
                bottomRight = Add(patches[BOTTOM_RIGHT], color, false, false);
                rightWidth = (int)GLib.Math.fmax(rightWidth, patches[BOTTOM_RIGHT].GetRegionWidth());
                bottomHeight = (int)GLib.Math.fmax(bottomHeight, patches[BOTTOM_RIGHT].GetRegionHeight());
            }
        }
            
        
        private int Add(TextureRegion region, SDL.Video.Color color, bool isStretchW, bool isStretchH) {
            if (texture == null)
                texture = region.texture;
            else if (texture != region.texture) //
                throw new SdlException.IllegalArgumentException("All regions must be from the same texture.");

            var u = region.u;
            var v = region.v2;
            var u2 = region.u2;
            var v2 = region.v;

            // Add half pixel offsets on stretchable dimensions to acolor bleeding when GL_LINEAR
            // filtering is used for the texture. This nudges the texture coordinate to the center
            // of the texel where the neighboring pixel has 0% contribution in linear blending mode.
            if (isStretchW) 
            {
                var halfTexelWidth = 0.5f * 1.0f / texture.width;
                u += halfTexelWidth;
                u2 -= halfTexelWidth;
            }
            
            if (isStretchH)
            {
                var halfTexelHeight = 0.5f * 1.0f / texture.height;
                v -= halfTexelHeight;
                v2 += halfTexelHeight;
            }

            slice[idx] = { 
                SDL.Video.Rect() { y = region.left + sourceLeft, x = region.top + sourceTop, w = region.width, h = region.height },
                SDL.Video.Rect() { y = region.left, x = region.top, w = region.width, h = region.height },
                0
            };

            return idx++;
        }
            
        public void SetColor(SDL.Video.Color color) 
        {
            this.color = color;
        }

        public SDL.Video.Color GetColor()
        {
            return color;
        }

        public float GetLeftWidth()
        { 
            return leftWidth;
        }

        /** 
         * Set the draw-time width of the three left edge patches 
         */
        public void SetLeftWidth(float leftWidth) 
        { 
            this.leftWidth = leftWidth;
        }

        public float GetRightWidth()
        {
            return rightWidth;
        }

        /** 
         * Set the draw-time width of the three right edge patches 
         */
        public void SetRightWidth(float rightWidth)
        { 
            this.rightWidth = rightWidth;
        }

        public float GetTopHeight()
        {
            return topHeight;
        }

        /** 
         * Set the draw-time height of the three top edge patches 
         */
        public void SetTopHeight(float topHeight)
        { 
            this.topHeight = topHeight;
        }

        public float GetBottomHeight()
        {
            return bottomHeight;
        }

        /** 
         * Set the draw-time height of the three bottom edge patches 
         */
        public void SetBottomHeight(float bottomHeight)
        { 
            this.bottomHeight = bottomHeight;
        }

        public float GetMiddleWidth()
        {
            return middleWidth;
        }

        /** 
         * Set the width of the middle column of the patch. At render time, this is implicitly the requested render-width of the
         * entire nine patch, minus the left and right width. This value is only used for computing the link #GetTotalWidth() default
         * total width. 
         */
        public void SetMiddleWidth(float middleWidth)
        { 
            this.middleWidth = middleWidth;
        }

        public float GetMiddleHeight()
        {
            return middleHeight;
        }

        /** 
         * Set the height of the middle row of the patch. At render time, this is implicitly the requested render-height of the entire
         * nine patch, minus the top and bottom height. This value is only used for computing the link #GetTotalHeight() default
         * total height. 
         */
        public void SetMiddleHeight(float middleHeight) 
        { 
            this.middleHeight = middleHeight;
        }

        public float GetTotalWidth()
        {
            return leftWidth + middleWidth + rightWidth;
        }

        public float GetTotalHeight()
        {
            return topHeight + middleHeight + bottomHeight;
        }

        /** 
         * Set the padding for content inside this ninepatch. By default the padding is set to match the exterior of the ninepatch, so
         * the content should fit exactly within the middle patch. 
         */
        public void SetPadding(float left, float right, float top, float bottom)
        { 
            this.padLeft = left;
            this.padRight = right;
            this.padTop = top;
            this.padBottom = bottom;
        }

        /** 
         * Returns the left padding if set, else returns link #GetLeftWidth(). 
         */
        public float GetPadLeft()
        {
            if (padLeft == -1) return GetLeftWidth();
            return padLeft;
        }

        /** 
         * See link #setPadding(float, float, float, float) 
         */
        public void SetPadLeft(float left)
        { 
            this.padLeft = left;
        }

        /** 
         * Returns the right padding if set, else returns link #GetRightWidth(). 
         */
        public float GetPadRight()
        {
            if (padRight == -1) return GetRightWidth();
            return padRight;
        }

        /** 
         * See link #setPadding(float, float, float, float) 
         */
        public void SetPadRight(float right)
        { 
            this.padRight = right;
        }

        /** 
         * Returns the top padding if set, else returns link #GetTopHeight(). 
         */
        public float GetPadTop()
        {
            if (padTop == -1) return GetTopHeight();
            return padTop;
        }

        /** 
         * See link #setPadding(float, float, float, float) 
         */
        public void SetPadTop(float top)
        { 
            this.padTop = top;
        }

        /** 
         * Returns the bottom padding if set, else returns link #GetBottomHeight(). 
         */
        public float GetPadBottom()
        {
            if (padBottom == -1) return GetBottomHeight();
            return padBottom;
        }

        /** 
         * See link #setPadding(float, float, float, float) 
         */
        public void SetPadBottom(float bottom)
        { 
            this.padBottom = bottom;
        }

        /** 
         * Multiplies the top/left/bottom/right sizes and padding by the specified amount. 
         */
        public void Scale(float scaleX, float scaleY) 
        { 
            leftWidth *= scaleX;
            rightWidth *= scaleX;
            topHeight *= scaleY;
            bottomHeight *= scaleY;
            middleWidth *= scaleX;
            middleHeight *= scaleY;
            if (padLeft != -1) padLeft *= scaleX;
            if (padRight != -1) padRight *= scaleX;
            if (padTop != -1) padTop *= scaleY;
            if (padBottom != -1) padBottom *= scaleY;
        }
    }
}