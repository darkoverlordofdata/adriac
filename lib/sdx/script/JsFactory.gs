/**
 * Script facing factory methods
 */
[indent=4]
#if NODEJS

uses SDL
uses SDL.Video
uses Gee
uses Sdx.Graphics
namespace Sdx 

    /**
     * CreateJsGame
     *
     * @param name for title bar
     * @param height in pixels
     * @param width in pixels
     * @param base asset url
     * @return the new game
     */
    // def CreateJsGame(name:string, height:int, width:int, base:string):Object
    //     return (Object)(new JsGame(name, height, width, base))

    /**
     * CreateSprite
     *
     * @param path to asset
     * @return the new sprite
     */
    def CreateSprite(path:string):Object
        return (Object)(new Sprite(path))

    /**
     * CreateSound
     *
     * @param path to asset
     * @return the new sound chunk
     */
    def CreateSound(path:string):Object
        return (Object)Sdx.audio.newSound(Sdx.files.resource(path))

    /**
     * CreateFont
     *
     * @param path to asset
     * @param size
     * @return the new font
     */
    def CreateFont(path:string, size:int):Object
        return (Object)(new Font(Sdx.files.resource(path), size))


    /**
     * CreateText
     *
     * @param text
     * @param font
     * @param color
     * @return the new text sprite
     */
    def CreateText(text:string, font:Object, color:Object):Object
        return (Object)(new Sprite.text(text, (Font)font, (sdx.graphics.Color)color))
        

    /**
     * CreateColor
     *
     * @param r
     * @param g
     * @param b
     * @param a
     * @return the new color
     */
    def CreateColor(r:double, g:double, b:double, a:double):Object
        return (Object)(new sdx.graphics.Color.rgba(r, g, b, a))

    def CreateAtlas(path:string):Object
        var file = Sdx.files.resource(path)
        if !file.exists() do return null
        return new TextureAtlas.file(file)
       

#endif
