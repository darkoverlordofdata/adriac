/*
The MIT License (MIT)

Copyright (c) <2016> <SDL2.0 vapi>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
//FOR: SDL2.0 - This is not official, to be futurely changed for the official binding
//Maintainer: PedroHLC, Txasatonga, Desiderantes

[CCode (cheader_filename = "SDL2/SDL_image.h")]
namespace SDLImage {
	//! Defines

	[CCode (cname = "IMG_InitFlags", cprefix = "IMG_INIT_")]
	public enum InitFlags {
	    JPG,
	    PNG,
	    TIF,
	    WEBP,
	    [CCode (cname = "IMG_INIT_JPG|IMG_INIT_PNG|IMG_INIT_TIF|IMG_INIT_WEBP")]
	    ALL
	}

	//! General

	[CCode (cname = "IMG_Linked_Version")]
	public static unowned SDL.Version linked ();

	[CCode (cname = "IMG_Init")]
	public static int Init (int flags);

	[CCode (cname = "IMG_Quit")]
	public static void Quit ();

	//! Loading

	[CCode (cname = "IMG_Load")]
	public static SDL.Video.Surface? Load (string file);

	[CCode (cname = "IMG_Load_RW")]
	public static SDL.Video.Surface? LoadRw (SDL.RWops src, bool freesrc = false);

	[CCode (cname = "IMG_LoadTyped_RW")]
	public static SDL.Video.Surface? LoadRwTyped (SDL.RWops src, bool freesrc, string type);

	[CCode (cname = "IMG_LoadTexture")]
	public static SDL.Video.Texture? LoadTexture (SDL.Video.Renderer renderer, string file);

	[CCode (cname = "IMG_LoadTexture_RW")]
	public static SDL.Video.Texture? LoadTextureRw (SDL.Video.Renderer renderer, SDL.RWops src, bool freesrc = false);

	[CCode (cname = "IMG_LoadTextureTyped_RW")]
	public static SDL.Video.Texture? LoadTextureRwTyped (SDL.Video.Renderer renderer, SDL.RWops src, bool freesrc, string type);

	[CCode (cname = "IMG_InvertAlpha")]
	public static int InvertAlpha (int on);

	[CCode (cname = "IMG_LoadCUR_RW")]
	public static SDL.Video.Surface? LoadCUR (SDL.RWops src);

	[CCode (cname = "IMG_LoadICO_RW")]
	public static SDL.Video.Surface? LoadICO (SDL.RWops src);

	[CCode (cname = "IMG_LoadBMP_RW")]
	public static SDL.Video.Surface? LoadBMP (SDL.RWops src);

	[CCode (cname = "IMG_LoadPNM_RW")]
	public static SDL.Video.Surface? LoadPNM (SDL.RWops src);

	[CCode (cname = "IMG_LoadXPM_RW")]
	public static SDL.Video.Surface? LoadXPM (SDL.RWops src);

	[CCode (cname = "IMG_LoadXCF_RW")]
	public static SDL.Video.Surface? LoadXCF (SDL.RWops src);

	[CCode (cname = "IMG_LoadPCX_RW")]
	public static SDL.Video.Surface? LoadPCX (SDL.RWops src);

	[CCode (cname = "IMG_LoadGIF_RW")]
	public static SDL.Video.Surface? LoadGIF (SDL.RWops src);

	[CCode (cname = "IMG_LoadJPG_RW")]
	public static SDL.Video.Surface? LoadJPG (SDL.RWops src);

	[CCode (cname = "IMG_LoadTIF_RW")]
	public static SDL.Video.Surface? LoadTIF (SDL.RWops src);

	[CCode (cname = "IMG_LoadPNG_RW")]
	public static SDL.Video.Surface? LoadPNG (SDL.RWops src);

	[CCode (cname = "IMG_LoadTGA_RW")]
	public static SDL.Video.Surface? LoadTGA (SDL.RWops src);

	[CCode (cname = "IMG_LoadLBM_RW")]
	public static SDL.Video.Surface? LoadLBM (SDL.RWops src);

	[CCode (cname = "IMG_LoadXV_RW")]
	public static SDL.Video.Surface? LoadXV (SDL.RWops src);

	[CCode (cname = "IMG_LoadWEBP_RW")]
	public static SDL.Video.Surface? LoadWEBP (SDL.RWops src);

	[CCode (cname = "IMG_ReadXPMFromArray")]
	public static SDL.Video.Surface? ReadXPM (string[] xpmdata);

	//!Info

	[CCode (cname = "IMG_isCUR")]
	public static bool IsCUR (SDL.RWops src);

	[CCode (cname = "IMG_isICO")]
	public static bool IsICO (SDL.RWops src);

	[CCode (cname = "IMG_isBMP")]
	public static bool IsBMP (SDL.RWops src);

	[CCode (cname = "IMG_isPNM")]
	public static bool IsPNM (SDL.RWops src);

	[CCode (cname = "IMG_isXPM")]
	public static bool IsXPM (SDL.RWops src);

	[CCode (cname = "IMG_isXCF")]
	public static bool IsXCF (SDL.RWops src);

	[CCode (cname = "IMG_isPCX")]
	public static bool IsPCX (SDL.RWops src);

	[CCode (cname = "IMG_isGIF")]
	public static bool IsGIF (SDL.RWops src);

	[CCode (cname = "IMG_isJPG")]
	public static bool IsJPG (SDL.RWops src);

	[CCode (cname = "IMG_isTIF")]
	public static bool IsTIF (SDL.RWops src);

	[CCode (cname = "IMG_isPNG")]
	public static bool IsPNG (SDL.RWops src);

	[CCode (cname = "IMG_isLBM")]
	public static bool IsLBM (SDL.RWops src);

	[CCode (cname = "IMG_isXV")]
	public static bool IsXV (SDL.RWops src);

	[CCode (cname = "IMG_isWEBP")]
	public static bool IsWEBP (SDL.RWops src);
} // SDLImage
