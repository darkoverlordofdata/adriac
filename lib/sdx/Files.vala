using sdx.files;

namespace sdx {

	public enum FileType {
		Parent,		/* Placeholder for the parent path  */
		Resource,	/* Path to memory GResource */
		Asset,		/* Android asset folder */
		Absolute,	/* Absolute filesystem path.  */
		Relative	/* Path relative to the pwd */
	}
	
	public class Files : Object {

		public bool isResource;
		public string resourcePath;

		public Files(string resourcePath) { 
			this.resourcePath = resourcePath;
		}

	}
}
