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

/**
 * Sdx
 * 
 * An SDL2 wrapper inspired by libGDX 
 */
namespace Sdx 
{
	private const double MS_PER_UPDATE = 1.0/60.0;
#if (DESKTOP)
	private const int pixelFactor = 1;
	FileType platform = FileType.Resource;
#elif (ANDROID)
	private const int pixelFactor = 2;
	FileType platform = FileType.Asset;
#else
	private const int pixelFactor = 1;
	FileType platform = FileType.Relative;
#endif
	private SDL.Event evt;
	private SDL.Video.DisplayMode displayMode;
	private SDL.Video.Renderer? renderer;
	private SDL.Video.Display? display;
	private SDL.Video.Color? bgdColor;
	private Sdx.Font? font;
	private Sdx.Font? smallFont;
	private Sdx.Font? largeFont;
	private Sdx.Graphics.TextureAtlas? atlas;
	private Sdx.Ui.Window? ui;
	private Sdx.InputMultiplexer? inputProcessor;
	private Sdx.Math.TweenManager? tweenManager;
	private float fps = 60f;
	private float delta = 1.0f/60.0f;
	private bool running;
	private string resourceBase;
	private double currentTime;
	private double accumulator;
	private double freq;
	private int width;
	private int height;

	/**
	 * Initialization
	 * 
	 */
	public Window Initialize(int width, int height, string name) 
	{
		print("How did I get here? %s\n", name);
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
		
		renderer = Renderer.Create(window, -1, RendererFlags.ACCELERATED | RendererFlags.PRESENTVSYNC);
		if (renderer == null)
			throw new SdlException.CreateRenderer(SDL.GetError());

		freq = SDL.Timer.GetPerformanceFrequency();
		bgdColor = Sdx.Color.Black; 
		
		MersenneTwister.InitGenrand((ulong)SDL.Timer.GetPerformanceCounter());
		inputProcessor = new InputMultiplexer();
		return window;
	}


	public int Render(Video.Texture texture, Video.Rect? srcrect, Video.Rect? dstrect)
	{
		return renderer.Copy(texture, srcrect, dstrect);
	}
	
	public double GetRandom() 
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

	public void SetResourceBase(string path) 
	{
		Sdx.resourceBase = path;
	}

	public void SetDefaultFont(string path, int size) 
	{
		font = new Sdx.Font(path, size);
	}

	public void SetSmallFont(string path, int size) 
	{
		smallFont = new Sdx.Font(path, size);
	}

	public void SetLargeFont(string path, int size) 
	{
		largeFont = new Sdx.Font(path, size);
	}


	public double GetNow() 
	{
		return (double)SDL.Timer.GetPerformanceCounter()/freq;
	} 

	public void Start() 
	{
		currentTime = GetNow();
		running = true;
	}

	public void GameLoop(AbstractGame game) 
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


	public void ProcessEvents() 
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
	
	public void Begin() 
	{
		renderer.SetDrawColor(bgdColor.r, bgdColor.g, bgdColor.b, bgdColor.a);
		renderer.Clear();
	}

	public void End() 
	{
		renderer.Present();
	}

	public void Log(string text) 
	{
#if (ANDROID)
		Android.LogWrite(Android.LogPriority.ERROR, "SDX", text);
#else
		stdout.printf("%s\n", text);
#endif
	}

}

