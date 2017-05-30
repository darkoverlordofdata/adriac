
[CCode (cheader_filename = "android/log.h")]
namespace Android {

	[CCode (cname = "android_LogPriority", cprefix = "ANDROID_LOG_")]
	public enum LogPriority {
		UNKNOWN ,
		DEFAULT,    /* only for SetMinPriority() */
		VERBOSE,
		DEBUG,
		INFO,
		WARN,
		ERROR,
		FATAL,
		SILENT     /* only for SetMinPriority(); must be last */	
	}// LogPriority
	
	[CCode (cname="__android_log_write")]
	public int logWrite(LogPriority prio, string tag, string text);

	[PrintfFormat, CCode (cname="__android_log_print")]
	public int logPrint(LogPriority prio, string tag, string format, ...);

	[PrintfFormat, CCode (cname="__android_log_vprint")]
	public int logPrintv(LogPriority prio, string tag, string format, va_list args);

}