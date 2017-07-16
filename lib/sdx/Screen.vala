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
namespace Sdx 
{
    /** <p>
     * Represents one of many application screens, such as a main menu, a settings menu, the game screen and so on.
     * </p>
     * <p>
     * Note that {@link #dispose()} is not called automatically.
     * </p>
     * @see Game */
	public struct Screen 
	{ 
		public ScreenShow Show;
		public ScreenRender Render;
		public ScreenResize Resize;
		public ScreenPause Pause;
		public ScreenResume Resume;
		public ScreenHide Hide;
		public ScreenDispose Dispose;
	}

	
	/** Called when this screen becomes the current screen for a {@link Game}. */
	public delegate void ScreenShow();
	
	/** Called when the screen should render itself.
	 * @param delta The time in seconds since the last render. */
	public delegate void ScreenRender(float delta);

	/** @see ApplicationListener#resize(int, int) */
	public delegate void ScreenResize(int width, int height);

	/** @see ApplicationListener#pause() */
	public delegate void ScreenPause();

	/** @see ApplicationListener#resume() */
	public delegate void ScreenResume();

	/** Called when this screen is no longer the current screen for a {@link Game}. */
	public delegate void ScreenHide();

	/** Called when this screen should release all resources. */
	public delegate void ScreenDispose();
	

    
}