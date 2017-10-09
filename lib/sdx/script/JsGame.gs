/**
 * JsGame
 *
 * Basic game object for javascript
 */
[indent=4]
#if NODEJS

uses SDL
uses SDL.Video
uses Gee
uses Sdx.Graphics
namespace Sdx 

    class JsGame : Object //implements IApplication

        prop yieldForEventsMs: int = 1000
        prop profile: bool = false
        prop mouseDown: bool
        prop mouseX: int = 0
        prop mouseY: int = 0
        prop running:bool = false    
        prop name:string
        prop base: string
        prop fps: int
        prop showFps: bool = false
        prop deltaTime: double
        prop width: int = 800
        prop height: int = 640
        prop font: Font
        prop renderer : unowned Renderer
            get
                return _renderer

        window : Window
        _renderer : Renderer
        keys : array of uint8// = new array of uint8[255]
        evt : private Event
        frames: int
        fpsSprite: private Sprite
        scale: double = 1.0
        pixelFactor: double = 1.0
        defaultFont:string = "fonts/OpenDyslexic-Bold.otf"
        sprites : list of Sprite = new list of Sprite
        onetime : list of Sprite = new list of Sprite
        app: private ApplicationListener

        lastTime: private double //= (double)GLib.get_real_time()/1000000.0
        currentTime: private double = 0 
        elapsed: private double = 0


        k: int
        t: double
        t1: double = 0.0
        t2: double = 0.0
        t3: double = 0.0


        construct(name:string, height:int, width:int, base:string)
            new Sdx(this, width, height, base) 
            this.name = name
            this.width = width
            this.height = height
            this.base = base
            initialize()

        /**
         * addSprite
         * @param sprite to add
         *
         * Insert a sprite in layer order
         */
        def addSprite(sprite:Object)
            var ordinal = ((Sprite)sprite).layer
            if sprites.size == 0
                sprites.add((Sprite)sprite)
            else
                var i = 0
                for s in sprites
                    if ordinal <= s.layer
                        sprites.insert(i, (Sprite)sprite)
                        return
                    else
                        i++
                sprites.add((Sprite)sprite)


        def addOnce(sprite:Object)
            onetime.add((Sprite)sprite)

        /**
         * removeSprite
         * @param sprite to remove
         */
        def removeSprite(sprite:Object)
            sprites.remove((Sprite)sprite)

        def setApplicationListener(listener: ApplicationListener)
            app = listener

        /**
         * initialize SDL
         */
        def initialize()
            sdlFailIf(SDL.init(SDL.InitFlag.VIDEO | SDL.InitFlag.TIMER | SDL.InitFlag.EVENTS) < 0, 
                "SDL could not initialize! SDL Error: %s")

            sdlFailIf(SDLImage.init(SDLImage.InitFlags.PNG) < 0, 
                "SDL_image could not initialize!")

            sdlFailIf(!SDL.Hint.set_hint(Hint.RENDER_SCALE_QUALITY, "1"), 
                "Warning: Linear texture filtering not enabled!!")

            window = new Window(name, Window.POS_CENTERED, Window.POS_CENTERED, width, height, WindowFlags.SHOWN)
            sdlFailIf(window == null, "Window could not be created!")

            _renderer = Renderer.create(window, -1, RendererFlags.ACCELERATED | RendererFlags.PRESENTVSYNC)
            sdlFailIf(_renderer == null, "Renderer could not be created!")

            _renderer.set_draw_color(0xFF, 0xFF, 0xFF, 0)

            sdlFailIf(SDLTTF.init() == -1, "SDL_ttf could not initialize!")

            if defaultFont != ""
                var f = Sdx.files.resource(defaultFont)
                font = new Font(Sdx.files.resource(defaultFont), 16)
                if font == null
                    showFps = false
                    print "Failed to load font, show_fps set to false. SDL Error: %s", SDL.get_error()
                else
                    showFps = true
            
            sdlFailIf(SDLMixer.open(22050, SDL.Audio.AudioFormat.S16LSB, 2, 4096) == -1,
                "SDL_mixer unable to initialize!")

            keys = new array of uint8[255]
            print "Game Initialized "

        /**
         * start
         */
        def start()
            running = true
            lastTime = (double)GLib.get_real_time()/1000000.0        
                
        /**
         * getKey
         *
         * @param code of key (ascii)
         * @return 1 - pressed | 0 - not pressed
         */
        def getKey(code:int):int
            return keys[code]

        /**
         * handleEvents
         *
         * collect the event information for this frame
         * also update time info
         */
        def handleEvents():int

            while Event.poll(out evt) != 0
                case evt.type // patch for keyboardGetState
                    when SDL.EventType.KEYDOWN
                        if evt.key.keysym.sym < 256
                            keys[evt.key.keysym.sym] = 1
                    when SDL.EventType.KEYUP
                        if evt.key.keysym.sym < 256
                            keys[evt.key.keysym.sym] = 0
                    when  SDL.EventType.MOUSEMOTION
                        _mouseX = (int)evt.motion.x
                        _mouseY = (int)evt.motion.y
                    when  SDL.EventType.MOUSEBUTTONDOWN
                        _mouseDown = true
                    when  SDL.EventType.MOUSEBUTTONUP
                        _mouseDown = false
                    when SDL.EventType.QUIT
                        _running = false

            Sdx.graphics.updateTime()
            _deltaTime = Sdx.graphics.deltaTime
            if (_deltaTime > 1) do _deltaTime = 1.0/60.0
            _fps = Sdx.graphics.fps
            if profile do t1 = (double)GLib.get_real_time()/1000000.0
            
            return evt.type

        /**
         * draw
         *
         * draw the frame
         * do profiling
         */
        def draw()
            if profile
                t2 = (double)GLib.get_real_time()/1000000.0
                t3 = t2 - t1
                t = t + t3
                k += 1
                if k == 1000
                    k = 0
                    t = t / 1000.0
                    print "%f", t
                    t = 0
                    
            renderer.set_draw_color(0x0, 0x0, 0x0, 0x0)
            renderer.clear()

            for var sprite in sprites
                sprite.render(_renderer, sprite.x, sprite.y)

            if showFps && fpsSprite != null do fpsSprite.render(_renderer, 0, 0)

            for var sprite in onetime  
                sprite.render(_renderer, sprite.x, sprite.y)
                
            onetime = new list of Sprite           
            if yieldForEventsMs > 0 do GLib.Thread.usleep(yieldForEventsMs) 
            if showFps
                if fpsSprite != null do fpsSprite = null
                fpsSprite = new Sprite.text("%2.2f".printf(Sdx.graphics.fps), font, sdx.graphics.Color.AntiqueWhite)
                fpsSprite.centered = false
            renderer.present()



#endif
