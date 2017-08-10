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
using SDL.Video;

 namespace  Sdx.Math 
{ 

    /**
     * Float (x,y) multiplier
     */
    [SimpleType]
	public struct Scale 
	{
		public float x;
		public float y;
	}

    /**
     * int (x,y) position
     */
    [SimpleType]
    public struct Point2 
    {
        public int x;
        public int y;
    }
    
    
    /**
     * Ensures a value is within a range
     * 
     * @param value to check
     * @param low lower range limit
     * @param hi upper range limit
     * @return value adjusted to range
     */
    public inline float Clamp(float value, float low, float hi) 
    {
	    return value < low ? low : value > hi ? hi : value;
    }
    
    /**
     * Float (x,y) Vector math
     */
    public struct Vector2 
    {

        public float x;
        public float y;

        public static Vector2 Zero  { get {return {  0,  0 }; } }
        public static Vector2 One   { get {return {  1,  1 }; } }
        public static Vector2 Down  { get {return {  0, -1 }; } }
        public static Vector2 Left  { get {return { -1,  0 }; } }
        public static Vector2 Right { get {return {  1,  0 }; } }
        public static Vector2 Up    { get {return {  0,  1 }; } }

        public static float Distance(Vector2 a, Vector2 b) 
        {
            return GLib.Math.sqrtf( (a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y) );
        }

        public Vector2(float x = 0, float y = 0) 
        {
            this.x = x;
            this.y = y;
        }

        public inline Vector2 Mul(float f) 
        {
            return { x*f, y*f };
        }

        public inline Vector2 Div(float f) 
        {
            return { x/f, y/f };
        }

        public inline float Len() 
        {
            return GLib.Math.sqrtf(x*x + y*y);
        }

        public inline Vector2 Add(Vector2 v) 
        {
            return { x+v.x, y+v.y };
        }

        public inline Vector2 Sub(Vector2 v) 
        {
            return { x-v.x, y-v.y };
        }            
    }
}