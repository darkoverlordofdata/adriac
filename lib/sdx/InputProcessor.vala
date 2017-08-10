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
	 * An InputProcessor is used to receive input events from the keyboard and the touch screen (mouse on the desktop). For this it
	 * has to be registered with the {@link Sdx.AddInputProcessor} method. It will be called each frame before the
	 * call to {@link ApplicationListener.Render}. Each method returns a boolean in case you want to use this with the
	 * {@link InputMultiplexer} to chain input processors.
	 * 
	 * based on code by  mzechner 
	 */
	public class InputProcessor : Object
	{
		/** 
		 * Called when a key was pressed
		 * 
		 * @param keycode one of the constants in {@link SDL.Input.Keycode}
		 * @return whether the input was processed 
		 */
		public delegate bool InputProcessorKeyDown(int keycode);

		/** 
		 * Called when a key was released
		 * 
		 * @param keycode one of the constants in {@link SDL.Input.Keycode}
		 * @return whether the input was processed 
		 */
		public delegate bool InputProcessorKeyUp(int keycode);

		/** 
		 * Called when a key was typed
		 * 
		 * @param character The character
		 * @return whether the input was processed 
		 */
		public delegate bool InputProcessorKeyTyped(char character);

		/** 
		 * Called when the screen was touched or a mouse button was pressed. 
		 * @param x The x coordinate, origin is in the upper left corner
		 * @param x The y coordinate, origin is in the upper left corner
		 * @param pointer the pointer for the event.
		 * @param button the button
		 * @return whether the input was processed 
		 */
		public delegate bool InputProcessorTouchDown(int x, int y, int pointer, int button);

		/** 
		 * Called when a finger was lifted or a mouse button was released. 
		 * @param pointer the pointer for the event.
		 * @param button the button
		 * @return whether the input was processed 
		 */
		public delegate bool InputProcessorTouchUp(int x, int y, int pointer, int button);

		/** 
		 * Called when a finger or the mouse was dragged.
		 * @param pointer the pointer for the event.
		 * @return whether the input was processed 
		 */
		public delegate bool InputProcessorTouchDragged(int x, int y, int pointer);

		/** 
		 * Called when the mouse was moved without any buttons being pressed. Will not be called on iOS.
		 * @return whether the input was processed 
		 */
		public delegate bool InputProcessorMouseMoved(int x, int y);

		/** 
		 * Called when the mouse wheel was scrolled. Will not be called on iOS.
		 * @param amount the scroll amount, -1 or 1 depending on the direction the wheel was scrolled.
		 * @return whether the input was processed. 
		 */
		public delegate bool InputProcessorScrolled(int amount);
		public InputProcessorKeyDown KeyDown;
		public InputProcessorKeyUp KeyUp;
		public InputProcessorKeyTyped KeyTyped;
		public InputProcessorTouchDown TouchDown;
		public InputProcessorTouchUp TouchUp;
		public InputProcessorTouchDragged TouchDragged;
		public InputProcessorMouseMoved MouseMoved;
		public InputProcessorScrolled Scrolled;
		public InputProcessor()
		{
			KeyDown = (keycode) => { return false; };
			KeyUp = (keycode) => { return false; };
			KeyTyped = (character) => { return false; };
			TouchDown = (screenX, screenY, pointer, button) => { return false; };
			TouchUp = (screenX, screenY, pointer, button) => { return false; };
			TouchDragged = (screenX, screenY, pointer) => { return false; };
			MouseMoved = (screenX, screenY) => { return false; };
			Scrolled = (amount) => { return false; };
		}
		public InputProcessor SetKeyDown(InputProcessorKeyDown keyDown)
		{
			KeyDown = keyDown;
			return this;
		}
		public InputProcessor SetKeyUp(InputProcessorKeyUp keyUp)
		{
			KeyUp = keyUp;
			return this;
		}
		public InputProcessor SetKeyTyped(InputProcessorKeyTyped keyTyped)
		{
			KeyTyped = keyTyped;
			return this;
		}
		public InputProcessor SetTouchDown(InputProcessorTouchDown touchDown)
		{
			TouchDown = touchDown;
			return this;
		}
		public InputProcessor SetTouchUp(InputProcessorTouchUp touchUp)
		{
			TouchUp = touchUp;
			return this;
		}
		public InputProcessor SetTouchDragged(InputProcessorTouchDragged touchDragged)
		{
			TouchDragged = touchDragged;
			return this;
		}
		public InputProcessor SetMouseMoved(InputProcessorMouseMoved mouseMoved)
		{
			MouseMoved = mouseMoved;
			return this;
		}
		public InputProcessor SetScrolled(InputProcessorScrolled scrolled)
		{
			Scrolled = scrolled;
			return this;
		}
	}

}
