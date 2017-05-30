
[CCode (cheader_filename = "emscripten.h")]
namespace Emscripten {
	[CCode (cname="em_callback_func", has_target=false)]
	public delegate void em_callback_func();

	[CCode (cname="em_arg_callback_func", has_target=false)]
	public delegate void em_arg_callback_func(void* arg);

	[CCode (cname="em_str_callback_func", has_target=false)]
	public delegate void em_str_callback_func(string str);

	[CCode (cname="emscripten_run_script_int")]
	public int emscripten_run_script_int(string script);

	[CCode (cname="emscripten_run_script_string")]
	public string emscripten_run_script_string(string script);

	[CCode (cname="emscripten_async_run_script")]
	public void emscripten_async_run_script(string script, int millis);

	[CCode (cname="emscripten_set_main_loop")]
	public void emscripten_set_main_loop(em_arg_callback_func fnc, int fps, int simulate_infinite_loop);

	[CCode (cname="emscripten_set_main_loop_arg")]
	public void emscripten_set_main_loop_arg(em_arg_callback_func fnc, void* arg, int fps, int simulate_infinite_loop);

	[CCode (cname="emscripten_cancel_main_loop")]
	public void emscripten_cancel_main_loop();

	[CCode (cname="emscripten_get_main_loop_timing")]
	public int emscripten_get_main_loop_timing(int* mode, int* value);

	[CCode (cname="emscripten_set_main_loop_timing")]
	public int emscripten_set_main_loop_timing(int mode, int value);

	[CCode (cname="emscripten_get_device_pixel_ratio")]
	public double emscripten_get_device_pixel_ratio();

	[CCode (cname="emscripten_hide_mouse")]
	public void emscripten_hide_mouse();

	[CCode (cname="emscripten_get_canvas_size")]
	public int emscripten_get_canvas_size(int* width, int* height);

	[CCode (cname="emscripten_set_canvas_size")]
	public int emscripten_set_canvas_size(int width, int height);

	[CCode (cname="emscripten_get_now")]
	public double emscripten_get_now();

	[CCode (cname="emscripten_random")]
	public float emscripten_random();

	[CCode (cname="emscripten_run_script")]
	public void emscripten_run_script(string script);

}
