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
namespace Sdx 
{

    /** 
     * An ``ApplicationListener`` is called when the Application is created, resumed, rendering, paused or destroyed.
     * All methods are called in a thread that has the OpenGL context current. You can thus safely create and manipulate graphics
     * resources.
     * 
     * The ``ApplicationListener`` interface follows the standard Android activity life-cycle and is emulated on the desktop
     * accordingly.
     * 
     * based on code by  mzechner 
	 */
	public struct ApplicationListener 
	{ 
		/** 
		 * Called when the Application is first created. 
		 */
		public ApplicationListenerCreate Create;
		/** 
		 * Called when the Application is resized. This can happen at any point during a non-paused state but will never happen
		 * before a call to {@link ApplicationListener.Create}.
		 * 
		 */
		public ApplicationListenerResize Resize;
		/** 
		 * Called when the Application should render itself. 
		 */
		public ApplicationListenerRender Render;
		/** 
		 * Called when the Application is paused, usually when it's not active or visible on screen. An Application is also
		 * paused before it is destroyed. 
		 */
		public ApplicationListenerPause Pause;
		/** 
		 * Called when the Application is resumed from a paused state, usually when it regains focus. 
		 */
		public ApplicationListenerResume Resume;
		/** 
		 * Called when the Application is destroyed. Preceded by a call to {@link Pause}. 
		 */
		public ApplicationListenerDispose Dispose;
	}
	/** 
	 * Called when the Application is first created. 
	 */
	public delegate void ApplicationListenerCreate();

	/** 
	 * Called when the Application is resized. This can happen at any point during a non-paused state but will never happen
	 * before a call to {@link ApplicationListener.Create}.
	 * 
	 * @param width the new width in pixels
	 * @param height the new height in pixels 
	 */
	public delegate void ApplicationListenerResize(int width, int height);

	/** 
	 * Called when the Application should render itself. 
	 */
	public delegate void ApplicationListenerRender();

	/** 
	 * Called when the Application is paused, usually when it's not active or visible on screen. An Application is also
	 * paused before it is destroyed. 
	 */
	public delegate void ApplicationListenerPause();

	/** 
	 * Called when the Application is resumed from a paused state, usually when it regains focus. 
	 */
	public delegate void ApplicationListenerResume();

	/** 
	 * Called when the Application is destroyed. Preceded by a call to {@link ApplicationListener.Pause}. 
	 */
	public delegate void ApplicationListenerDispose();

}