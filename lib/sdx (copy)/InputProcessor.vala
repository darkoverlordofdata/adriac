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
	public class InputListener : Object
	{
		public InputProcessorKeyDown KeyDown;
		public InputProcessorKeyUp KeyUp;
		public InputProcessorKeyTyped KeyTyped;
		public InputProcessorTouchDown TouchDown;
		public InputProcessorTouchUp TouchUp;
		public InputProcessorTouchDragged TouchDragged;
		public InputProcessorMouseMoved MouseMoved;
		public InputProcessorScrolled Scrolled;
		public InputListener()
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
	}

	public class InputMultiplexer : Object
	{
		public GenericArray<InputProcessor?> processors;

		public InputMultiplexer() 
		{
			processors = new GenericArray<InputProcessor?>(4);
		}
		public void Add(InputProcessor processor)
		{
			processors.Add(processor);
		}
		public void Remove(InputProcessor processor)
		{
			processors.Remove(processor);
		}
		public bool KeyDown(int keycode)
		{
			for (var i=0; i<processors.length; i++)
				if (processors.Get(i).KeyDown(keycode)) return true;
			return false;
		}
		public bool KeyUp(int keycode)
		{
			for (var i=0; i<processors.length; i++)
				if (processors.Get(i).KeyUp(keycode)) return true;
			return false;
		}
		public bool KeyTyped(char character)
		{
			for (var i=0; i<processors.length; i++)
				if (processors.Get(i).KeyTyped(character)) return true;
			return false;
		}
		public bool TouchDown(int x, int y, int pointer, int button)
		{
			for (var i=0; i<processors.length; i++)
				if (processors.Get(i).TouchDown(x, y, pointer, button)) return true;
			return false;
		}
		public bool TouchUp(int x, int y, int pointer, int button)
		{
			for (var i=0; i<processors.length; i++)
				if (processors.Get(i).TouchUp(x, y, pointer, button)) return true;
			return false;
		}
		public bool TouchDragged(int x, int y, int pointer)
		{
			for (var i=0; i<processors.length; i++)
				if (processors.Get(i).TouchDragged(x, y, pointer)) return true;
			return false;
		}
		public bool MouseMoved(int x, int y)
		{
			for (var i=0; i<processors.length; i++)
				if (processors.Get(i).MouseMoved(x, y)) return true;
			return false;
		}
		public bool Scrolled(int amount)
		{
			for (var i=0; i<processors.length; i++)
				if (processors.Get(i).Scrolled(amount)) return true;
			return false;
		}
	}

	/** An InputProcessor is used to receive input events from the keyboard and the touch screen (mouse on the desktop). For this it
	 * has to be registered with the {@link Input#setInputProcessor(InputProcessor)} method. It will be called each frame before the
	 * call to {@link ApplicationListener#render()}. Each method returns a boolean in case you want to use this with the
	 * {@link InputMultiplexer} to chain input processors.
	 * 
	 * @author mzechner */
	public struct InputProcessor 
	{ 
		public InputProcessorKeyDown KeyDown;
		public InputProcessorKeyUp KeyUp;
		public InputProcessorKeyTyped KeyTyped;
		public InputProcessorTouchDown TouchDown;
		public InputProcessorTouchUp TouchUp;
		public InputProcessorTouchDragged TouchDragged;
		public InputProcessorMouseMoved MouseMoved;
		public InputProcessorScrolled Scrolled;

		public void SetTouchDown(InputProcessorTouchDown touchDown)
		{
			TouchDown = touchDown;
		}
		
		
	}
	InputProcessor CreateInputProcessor()
	{
		return InputProcessor()
		{
			KeyDown = (keycode) => { return false; },
			KeyUp = (keycode) => { return false; },
			KeyTyped = (character) => { return false; },
			TouchDown = (screenX, screenY, pointer, button) => { return false; },
			TouchUp = (screenX, screenY, pointer, button) => { return false; },
			TouchDragged = (screenX, screenY, pointer) => { return false; },
			MouseMoved = (screenX, screenY) => { return false; },
			Scrolled = (amount) => { return false; }
		};
	}
	/** Called when a key was pressed
	 * 
	 * @param keycode one of the constants in {@link Input.Keys}
	 * @return whether the input was processed */
	public delegate bool InputProcessorKeyDown(int keycode);

	/** Called when a key was released
	 * 
	 * @param keycode one of the constants in {@link Input.Keys}
	 * @return whether the input was processed */
	public delegate bool InputProcessorKeyUp(int keycode);

	/** Called when a key was typed
	 * 
	 * @param character The character
	 * @return whether the input was processed */
	public delegate bool InputProcessorKeyTyped(char character);

	/** Called when the screen was touched or a mouse button was pressed. The button parameter will be {@link Buttons#LEFT} on iOS.
	 * @param screenX The x coordinate, origin is in the upper left corner
	 * @param screenY The y coordinate, origin is in the upper left corner
	 * @param pointer the pointer for the event.
	 * @param button the button
	 * @return whether the input was processed */
	public delegate bool InputProcessorTouchDown(int x, int y, int pointer, int button);

	/** Called when a finger was lifted or a mouse button was released. The button parameter will be {@link Buttons#LEFT} on iOS.
	 * @param pointer the pointer for the event.
	 * @param button the button
	 * @return whether the input was processed */
	public delegate bool InputProcessorTouchUp(int x, int y, int pointer, int button);

	/** Called when a finger or the mouse was dragged.
	 * @param pointer the pointer for the event.
	 * @return whether the input was processed */
	public delegate bool InputProcessorTouchDragged(int x, int y, int pointer);

	/** Called when the mouse was moved without any buttons being pressed. Will not be called on iOS.
	 * @return whether the input was processed */
	public delegate bool InputProcessorMouseMoved(int x, int y);

	/** Called when the mouse wheel was scrolled. Will not be called on iOS.
	 * @param amount the scroll amount, -1 or 1 depending on the direction the wheel was scrolled.
	 * @return whether the input was processed. */
	public delegate bool InputProcessorScrolled(int amount);


}
