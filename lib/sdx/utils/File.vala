namespace sdx.utils {

	public const string pathSeparator  = "/";
	public const char pathSeparatorChar  = '/';
	/**
	 * Simple File handler
	 * 
	 */
	
	public class File : Object {

		//  public Posix.Stat? stat;
		public SDL.RWops file;
		public string path;
		public string[] files;

		public File(string path) {
			this.path = path;
    		file = new SDL.RWops.from_file(path, "r");
		} 

		public string getPath() {
			return path;
		}

		/**
		 * the name is everything after the final separator
		 */
		public string getName() {
			for (var i=path.length-1; i>0; i--)
				if (path[i] == pathSeparatorChar)
					return path.substring(i+1);
			return path;
		}

		/**
		 * the parent is everything prior to the final separator
		 */
		public string getParent() {
			var i = path.last_index_of(pathSeparator);
			return i < 0 ? "" : path.substring(0, i);
		}

		/**
		 * check if the represented struture exists on the virtual disk
		 */
		public bool exists() {
			return file != null;
		}

		/**
		 * is it a file?
		 */
		public bool isFile() {
			return file != null;
		}

		/**
		 * is it a folder?
		 */
		public bool isDirectory() {
			return false;
		}

		/**
		 * get the length of the file
		 */
		public int length() {
			return file != null ? (int)file.size : 0;
		}
		
		/**
		 * read the contents into a string buffer
		 */
		public string read() {
			if (!exists()) return "";
			var size = (int)file.size;
	    	var ioBuff = new char[size+2];
    
    		var stat = file.read((void*)ioBuff, 2, (size_t)size/2);
			var lines = "";
			lines = lines + (string)ioBuff;
			return lines;
		}
		
			/**
		 * return the list of files in the folder
		 */
		public string[] list() {
			files = new string[0];
			return files;
		}
	}
}