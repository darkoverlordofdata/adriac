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
using Sdx.Math;
namespace Sdx.Graphics 
{

	public class Camera : Object 
    {
        
		public enum Kind 
        {
            FluidCamera, InnerCamera, SimpleCamera
		}
        
	    //  public delegate void CameraSetPosition(Point2d position);
	    public delegate void CameraSetPosition(Vector2 position);

		public Kind kind;
		public Vector2 position;
        public CameraSetPosition SetPosition = (position) => {};


        public class InnerCamera : Camera 
        {
            /**
             * InnerCamera
             * 
             */
            public InnerCamera(float x = 0, float y = 0) 
            {
                kind = Kind.InnerCamera;
                position = { x, y };

                SetPosition = (player) => 
                {
                    var area = player.x - (float)Sdx.width/2;
                    position = { Clamp(position.x, area-100, area+100), position.y };
                };
            }
        }
        
        public class FluidCamera : Camera 
        {
            /**
             * FluidCamera
             * 
             */
            public FluidCamera(float x = 0, float y = 0) 
            {
                kind = Kind.FluidCamera;
                position = { x, y };

                SetPosition = (player) => 
                {
                    var dist = position.x - player.x + (float)Sdx.width/2;
                    position = { position.x += (-0.05f * dist), position.y };
                };
            }
        }

        public class SimpleCamera : Camera 
        {
            /**
             * SimpleCamera
             * 
             */
            public SimpleCamera(float x = 0, float y = 0) 
            {
                kind = Kind.SimpleCamera;
                position = { x, y };

                SetPosition = (player) => 
                {
                    position = { player.x - (float)Sdx.width/2, position.y };
                };
            }
        }

    }
}
