/**
 * api.gs
 *
 * Javascript API
 * 
 * Author: 
 *      bruce davidson
 */
[indent=4]
#if (LIBRARY)
uses SDL
uses SDL.Video
namespace Sdx

    interface IApplication: Object
        prop abstract width:int
        prop abstract height:int
        prop abstract readonly renderer : unowned Renderer

    def GetVersion(): string
        return "420.422"

    def CreateWindow(width: int, height: int, name: string):Object
        return (Object)(new Sdx.Ui.Window(width, height, name))

    // def CreateGame(window:Object, base:string):Object
    //     return (Object)(new JsGame((Sdx.Ui.Window)window, base))


    // class JsGame : Object

    //     construct(window:Sdx.Ui.Window, base:string)
    //         // new Sdx(this, width, height, base) 
    //         pass

#endif
