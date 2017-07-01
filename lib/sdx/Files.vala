using sdx.files;

namespace sdx {

	public enum FileType {
		Resource = 1,		/* Path to memory GResource */
		Asset,				/* Android asset folder */
		Absolute,			/* Absolute filesystem path.  */
		Relative			/* Path relative to the pwd */
		//  Parent = 0x10		/* Placeholder for the parent path  */
	}
	
	public class DataInputStream : Object {
		public string[] data; 
		public int ctr;
		public DataInputStream(string data) {
			this.data = data.split("\n");
			ctr = 0;
		}
		public string? read_line() {
			return ctr<data.length ? data[ctr++] : null;
		}
	}
}
