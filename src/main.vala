using SDL;
using SDL.Video;


public void gameLoop(HelloWorld hello) {
	hello.draw();
	hello.processEvents();
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
		renderer = Renderer.create(window, -1, Video.RendererFlags.ACCELERATED | Video.RendererFlags.PRESENTVSYNC);
		surface = new Surface.from_bmp("assets/sample.bmp");
		texture = Texture.create_from_surface(renderer, surface);
	}

	public void draw() {
		renderer.set_draw_color(0xff, 0x00, 0x00, 0xff);
		renderer.clear();
		renderer.copy(texture, null, { 100, 100, surface.w, surface.h  });
		renderer.present();
		
	}

	public void processEvents () {
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
public void game() {
	SDL.init(InitFlag.EVERYTHING);

	var hello = new HelloWorld();
	Emscripten.emscripten_set_main_loop_arg(mainloop, hello, 0, 1);
	return;
}
/**
 * the main loop
 */
public void mainloop(void* arg) {
	gameLoop((HelloWorld*)arg);
}
#else
public int main(string[] args){
	SDL.init(InitFlag.EVERYTHING);

	var hello = new HelloWorld();
	while(!hello.done) {
		gameLoop(hello);
	}
	SDL.quit();
	return 0;
}
#endif	

