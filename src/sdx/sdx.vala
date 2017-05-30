using SDL;
using SDL.Video;
using SDLImage;

namespace sdx {

	public struct Blit {
		SDL.Video.Rect source;
		SDL.Video.Rect dest;
		SDL.Video.RendererFlip flip;
	}
	
	public delegate Blit[] Compositor(int x, int y);	

	/**
	 * Global vars
	 * 
	 */
	Renderer renderer;
	sdx.Font font;
	sdx.Font smallFont;
	sdx.Font largeFont;
	SDL.Video.Display display;
	SDL.Video.DisplayMode displayMode;
	SDL.Video.Color fpsColor;
	SDL.Video.Color bgdColor;
	sdx.graphics.Sprite fpsSprite;
	long pixelFactor;
	bool showFps;
	double fps;
	double delta;
	double mouseX;
	double mouseY;
	bool mouseDown;
	bool running;
	uint8[] keys;
	bool[] direction;
	string resourceBase;

	int _frames;
	Event _evt;
	double _elapsed;
	double _freq;
	double _mark1;
	double _mark2;
	int _width;
	int _height;

	public enum Direction {
		NONE, LEFT, RIGHT, UP, DOWN
	}

	/**
	 * Initialization
	 * 
	 */
	Window initialize(int width, int height, string name) {
		keys = new uint8[256];
		direction = new bool[5];

		if (SDL.init(SDL.InitFlag.VIDEO | SDL.InitFlag.TIMER | SDL.InitFlag.EVENTS) < 0)
			throw new SdlException.Initialization(SDL.get_error());
 

		if (SDLImage.init(SDLImage.InitFlags.PNG) < 0)
			throw new SdlException.ImageInitialization(SDL.get_error());

		if (!SDL.Hint.set_hint(Hint.RENDER_SCALE_QUALITY, "1"))	
			throw new SdlException.TextureFilteringNotEnabled(SDL.get_error());

		if (SDLTTF.init() == -1)
			throw new SdlException.TtfInitialization(SDL.get_error());

		display = 0;
		display.get_mode(0, out displayMode);
		if (display.get_dpi(null, null, null) == -1) {
			pixelFactor = 2;
		} else {
			pixelFactor = 1;
		}

#if (ANDROID)    

		_width = displayMode.w;
		_height = displayMode.h;
		var window = new Window(name, Window.POS_CENTERED, Window.POS_CENTERED, 0, 0, WindowFlags.SHOWN);
#else
		var window = new Window(name, Window.POS_CENTERED, Window.POS_CENTERED, width, height, WindowFlags.SHOWN);
#endif	
		if (window == null)
			throw new SdlException.OpenWindow(SDL.get_error());
		
		sdx.renderer = Renderer.create(window, -1, RendererFlags.ACCELERATED | RendererFlags.PRESENTVSYNC);
		if (sdx.renderer == null)
			throw new SdlException.CreateRenderer(SDL.get_error());

		_freq = SDL.Timer.get_performance_frequency();
		fpsColor = sdx.Color.AntiqueWhite;
		bgdColor = { 0, 0, 0, 0 };

		MersenneTwister.init_genrand((ulong)SDL.Timer.get_performance_counter());
		return window;
	}

	double getRandom() {
		return MersenneTwister.genrand_real2();
	}

	void setResource(string path) {
		sdx.resourceBase = path;
	}

	void setDefaultFont(string path, int size) {
		font = new sdx.Font(path, size);
	}

	void setSmallFont(string path, int size) {
		smallFont = new sdx.Font(path, size);
	}

	void setLargeFont(string path, int size) {
		largeFont = new sdx.Font(path, size);
	}

	void setShowFps(bool value) {
		showFps = value;
		if (showFps == true) {
			fpsSprite = sdx.graphics.Sprite.fromText("%2.2f".printf(60), font, fpsColor);
			fpsSprite.centered = false;
		} else {
			fpsSprite = null;
		}
	}

	void drawFps() {
		if (showFps) {
			fpsSprite.setText("%2.2f".printf(fps), font, fpsColor);
			fpsSprite.render(0, 0);
		}
	}

	double getNow() {
		return (double)SDL.Timer.get_performance_counter()/_freq;
	} 

	void start() {
		running = true;
		_mark1 = (double)SDL.Timer.get_performance_counter()/_freq;
	}

	void update() {
		_mark2 = (double)SDL.Timer.get_performance_counter()/_freq;
		delta = _mark2 - _mark1;
		_mark1 = _mark2;
		_frames++;
		_elapsed = _elapsed + delta;
		if (_elapsed > 1.0) {
			fps = (int)((double)_frames / _elapsed);
			_elapsed = 0.0;
			_frames = 0;
		}
	}

	void processEvents() {
		while (SDL.Event.poll(out _evt) != 0) {
			switch (_evt.type) {
				case SDL.EventType.QUIT:
					running = false;
					break;
				case SDL.EventType.KEYDOWN:
					switch (_evt.key.keysym.scancode) {
						case SDL.Input.Scancode.LEFT: 	direction[Direction.LEFT] = true; break;
						case SDL.Input.Scancode.RIGHT: 	direction[Direction.RIGHT] = true; break;
						case SDL.Input.Scancode.UP: 	direction[Direction.UP] = true; break;
						case SDL.Input.Scancode.DOWN: 	direction[Direction.DOWN] = true; break;
					}
					if (_evt.key.keysym.sym < 0 || _evt.key.keysym.sym > 255) break;
					keys[_evt.key.keysym.sym] = 1;
					break;
				case SDL.EventType.KEYUP:
					switch (_evt.key.keysym.scancode) {
						case SDL.Input.Scancode.LEFT: 	direction[Direction.LEFT] = false; break;
						case SDL.Input.Scancode.RIGHT: 	direction[Direction.RIGHT] = false; break;
						case SDL.Input.Scancode.UP: 	direction[Direction.UP] = false; break;
						case SDL.Input.Scancode.DOWN: 	direction[Direction.DOWN] = false; break;
					}
					if (_evt.key.keysym.sym < 0 || _evt.key.keysym.sym > 255) break;
					keys[_evt.key.keysym.sym] = 0;
					break;
				case SDL.EventType.MOUSEMOTION:
					mouseX = _evt.motion.x;
					mouseY = _evt.motion.y;
					break;
				case SDL.EventType.MOUSEBUTTONDOWN:
					mouseDown = true;
					break;
				case SDL.EventType.MOUSEBUTTONUP:
					mouseDown = false;
					break;
#if (!ANDROID)
				case SDL.EventType.FINGERMOTION:
#if (DESKTOP)					
					mouseX = _evt.tfinger.x;
					mouseY = _evt.tfinger.y;
#else
					mouseX = _evt.tfinger.x * (double)_width;
					mouseY = _evt.tfinger.y * (double)_height;
#endif
					break;
				case SDL.EventType.FINGERDOWN:
					mouseDown = true;
					break;
				case SDL.EventType.FINGERUP:
					mouseDown = false;
					break;
#endif
			}
		}
	}
	
	void begin() {
		renderer.set_draw_color(bgdColor.r, bgdColor.g, bgdColor.b, bgdColor.a);
		renderer.clear();
	}

	void end() {
		sdx.renderer.present();
	}

}