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
using SDL;
using SDL.Video;
using SDLImage;

namespace Sdx 
{

	public class AbstractPlatform : Object 
	{
		public int width;
		public int height;
		public delegate void AbstractUpdate(int tick);
		public delegate void AbstractDraw(int tick);
		public AbstractUpdate Update = (tick) => {};
		public AbstractDraw Draw = (tick) => {};
		public AbstractPlatform() 
		{
			// forces the subclassed lambda context to be reference counted
			var r = new AbstractReference();
		}
	}

	public class AbstractGame : Object 
	{
		public int width;
		public int height;
		public delegate void AbstractUpdate();
		public delegate void AbstractDraw();
		public AbstractUpdate Update = () => {};
		public AbstractDraw Draw = () => {};
		public AbstractGame() 
		{
			// forces the subclassed lambda context to be reference counted
			var r = new AbstractReference();
		}
		public void Start() 
		{
			Sdx.Start();
		}
	}

	public class AbstractReference: Object {}

	
	/**
	 * Global vars
	 * 
	 */
	const double MS_PER_UPDATE = 1.0/60.0;

#if (DESKTOP)
	FileType platform = FileType.Resource;
	const int pixelFactor = 1;
#elif (ANDROID)
	const int pixelFactor = 2;
	FileType platform = FileType.Asset;
#else
	const int pixelFactor = 1;
	FileType platform = FileType.Relative;
#endif
	Renderer renderer;
	Sdx.Font font;
	Sdx.Font smallFont;
	Sdx.Font largeFont;
	SDL.Video.Display display;
	SDL.Video.DisplayMode displayMode;
	SDL.Video.Color bgdColor;
	Sdx.Graphics.TextureAtlas atlas;
	float fps = 60f;
	float delta = 1.0f/60.0f;
	bool running;
	string resourceBase;
	double currentTime;
	double accumulator;
	double freq;
	int width;
	int height;
	Sdx.Ui.Window ui;
	Event evt;
	InputMultiplexer inputProcessor;
	Math.TweenManager? tweenManager;

	/**
	 * Initialization
	 * 
	 */
	Window Initialize(int width, int height, string name) 
	{
		Sdx.height = height;
		Sdx.width = width;

		if (SDL.Init(SDL.InitFlag.VIDEO | SDL.InitFlag.TIMER | SDL.InitFlag.EVENTS) < 0)
			throw new SdlException.Initialization(SDL.GetError());

		if (SDLImage.Init(SDLImage.InitFlags.PNG) < 0)
			throw new SdlException.ImageInitialization(SDL.GetError());

		if (!SDL.Hint.SetHint(Hint.RENDER_SCALE_QUALITY, "1"))	
			throw new SdlException.TextureFilteringNotEnabled(SDL.GetError());

		if (SDLTTF.Init() == -1)
			throw new SdlException.TtfInitialization(SDL.GetError());

#if (!EMSCRIPTEN) 
		if (SDLMixer.Open(22050, SDL.Audio.AudioFormat.S16LSB, 2, 4096) == -1)
			print("SDL_mixer unagle to initialize! SDL Error: %s\n", SDL.GetError());
#endif
		display = 0;
		display.GetMode(0, out displayMode);

#if (ANDROID)    

		width = displayMode.w;
		height = displayMode.h;
		var window = new Window(name, Window.POS_CENTERED, Window.POS_CENTERED, 0, 0, WindowFlags.SHOWN);
#else
		var window = new Window(name, Window.POS_CENTERED, Window.POS_CENTERED, width, height, WindowFlags.SHOWN);
#endif	
		if (window == null)
			throw new SdlException.OpenWindow(SDL.GetError());
		
		Sdx.renderer = Renderer.Create(window, -1, RendererFlags.ACCELERATED | RendererFlags.PRESENTVSYNC);
		if (Sdx.renderer == null)
			throw new SdlException.CreateRenderer(SDL.GetError());

		freq = SDL.Timer.GetPerformanceFrequency();
		bgdColor = Sdx.Color.Black; 
		
		MersenneTwister.InitGenrand((ulong)SDL.Timer.GetPerformanceCounter());
		inputProcessor = new InputMultiplexer();
		return window;
	}

	double GetRandom() 
	{
		return MersenneTwister.GenrandReal2();
	}

	public void SetAtlas(string path)
	{
		atlas = new Sdx.Graphics.TextureAtlas(Sdx.Files.Default(path));
	}

	public void SetTweenManager(Math.TweenManager manager)
	{
		tweenManager = manager;
	}

	public void AddInputProcessor(InputProcessor processor) 
	{
		inputProcessor.Add(processor);
	}

	public void RemoveInputProcessor(InputProcessor processor) 
	{
		inputProcessor.Remove(processor);
	}

	void SetResourceBase(string path) 
	{
		Sdx.resourceBase = path;
	}

	void SetDefaultFont(string path, int size) 
	{
		font = new Sdx.Font(path, size);
	}

	void SetSmallFont(string path, int size) 
	{
		smallFont = new Sdx.Font(path, size);
	}

	void SetLargeFont(string path, int size) 
	{
		largeFont = new Sdx.Font(path, size);
	}


	double GetNow() 
	{
		return (double)SDL.Timer.GetPerformanceCounter()/freq;
	} 

	void Start() 
	{
		currentTime = GetNow();
		running = true;
	}

	void GameLoop(AbstractGame game) 
	{
		
		double newTime = GetNow();
		double frameTime = newTime - currentTime;
		if (frameTime > 0.25) frameTime = 0.25;
		currentTime = newTime;

		accumulator += frameTime;

		ProcessEvents();
		while (accumulator >= MS_PER_UPDATE) 
		{
			if (tweenManager != null) tweenManager.Update((float)MS_PER_UPDATE);
			game.Update();
			accumulator -= MS_PER_UPDATE;
		}
		game.Draw();
	}


	void ProcessEvents() 
	{
		while (SDL.Event.poll(out evt) != 0) 
		{
			switch (evt.type) 
			{
				case SDL.EventType.QUIT:
					running = false;
					break;

				case SDL.EventType.KEYDOWN:
					if (evt.key.keysym.sym < 0 || evt.key.keysym.sym > 255) break;
                    if (inputProcessor.KeyDown != null)
						inputProcessor.KeyDown(evt.key.keysym.sym);
					break;

				case SDL.EventType.KEYUP:
					if (evt.key.keysym.sym < 0 || evt.key.keysym.sym > 255) break;
                    if (inputProcessor.KeyUp != null)
						inputProcessor.KeyUp(evt.key.keysym.sym);
					break;

				case SDL.EventType.MOUSEMOTION:
					if (inputProcessor.MouseMoved != null)
						inputProcessor.MouseMoved(evt.motion.x, evt.motion.y);

					break;

				case SDL.EventType.MOUSEBUTTONDOWN:
                    if (inputProcessor.TouchDown != null)
						if (inputProcessor.TouchDown(evt.motion.x, evt.motion.y, 0, 0)) return;
					break;

				case SDL.EventType.MOUSEBUTTONUP:
                    if (inputProcessor.TouchUp != null)
						if (inputProcessor.TouchUp(evt.motion.x, evt.motion.y, 0, 0)) return;
					break;
#if (!ANDROID)
				case SDL.EventType.FINGERMOTION:
#if (EMSCRIPTEN)					
					if (inputProcessor.TouchDragged != null)
						inputProcessor.TouchDragged(
							(int)(evt.tfinger.x * (float)width), 
							(int)(evt.tfinger.y * (float)height), 0);
#else
					if (inputProcessor.TouchDragged != null)
						inputProcessor.TouchDragged(
							(int)evt.tfinger.x, (int)evt.tfinger.y, 0);
#endif
					break;

				case SDL.EventType.FINGERDOWN:
#if (EMSCRIPTEN)					
                    if (inputProcessor.TouchDown != null)
						inputProcessor.TouchDown(
							(int)(evt.tfinger.x * (float)width), 
							(int)(evt.tfinger.y * (float)height), 0, 0);
#else
                    if (inputProcessor.TouchDown != null)
						inputProcessor.TouchDown(
							(int)evt.tfinger.x, (int)evt.tfinger.y, 0, 0);
#endif
					break;

				case SDL.EventType.FINGERUP:
#if (EMSCRIPTEN)					
                    if (inputProcessor.TouchUp != null)
						inputProcessor.TouchUp(
							(int)(evt.tfinger.x * (float)width), 
							(int)(evt.tfinger.y * (float)height), 0, 0);
#else
                    if (inputProcessor.TouchUp != null)
						inputProcessor.TouchUp(
							(int)evt.tfinger.x, (int)evt.tfinger.y, 0, 0);
#endif
					break;
#endif
			}
		}
	}
	
	void Begin() 
	{
		renderer.SetDrawColor(bgdColor.r, bgdColor.g, bgdColor.b, bgdColor.a);
		renderer.Clear();
	}

	void End() 
	{
		renderer.Present();
	}

	void Log(string text) 
	{
#if (ANDROID)
		Android.LogWrite(Android.LogPriority.ERROR, "SDX", text);
#else
		stdout.printf("%s\n", text);
#endif
	}

}

