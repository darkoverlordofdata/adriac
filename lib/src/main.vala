using SDL;
using SDL.Video;


public void GameLoop(HelloWorld hello) {
	hello.Draw();
	hello.ProcessEvents();
}


public class HelloWorld : Object {
	public Window window;
	public Renderer renderer;
	public Surface surface;
	public Texture texture;
	public bool done;

	public HelloWorld() {

#if (ANDROID)
		window = new Window("Hello World", Window.POS_CENTERED, Window.POS_CENTERED, 0, 0, WindowFlags.SHOWN);
#else
		window = new Window("Hello World", Window.POS_CENTERED, Window.POS_CENTERED, 600, 400, WindowFlags.SHOWN);
#endif		
		renderer = Renderer.Create(window, -1, Video.RendererFlags.ACCELERATED | Video.RendererFlags.PRESENTVSYNC);
		surface = SDLImage.Load("assets/sample.bmp");
		texture = Texture.CreateFromSurface(renderer, surface);
	}

	public void Draw() {
		renderer.SetDrawColor(0xff, 0x00, 0x00, 0xff);
		renderer.Clear();
		renderer.Copy(texture, null, { 100, 100, surface.w, surface.h  });
		renderer.Present();
		
	}

	public void ProcessEvents () {
        Event event;
        while (Event.poll (out event) == 1) {
            switch (event.type) {
            case EventType.QUIT:
                this.done = true;
                break;
            }
        }
    }
}

#if (EMSCRIPTEN)
public void Game() {
	SDL.Init(InitFlag.EVERYTHING);

	var hello = new HelloWorld();
	Emscripten.SetMainLoopArg(MainLoop, hello, 0, 1);
	return;
}
/**
 * the main loop
 */
public void MainLoop(void* arg) {
	GameLoop((HelloWorld*)arg);
}
#else
public int main(string[] args){
	SDL.Init(InitFlag.EVERYTHING);

	var hello = new HelloWorld();
	while(!hello.done) {
		GameLoop(hello);
	}
	SDL.Quit();
	return 0;
}
#endif	

