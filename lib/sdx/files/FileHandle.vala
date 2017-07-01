namespace sdx.files {

	/**
	 * get a better grip on the file object
	 */	
	public class FileHandle : Object {
		public utils.File file;
		public string path;
		public FileType type;

		public FileHandle(string path, FileType type) {
			this.path = path;
			this.type = type;
			this.file = new utils.File(path);
		}

		/**
		 * Loads a raw resource value
		 */
		public SDL.RWops getRWops() {
			if (type == FileType.Resource) {
#if (ANDROID || EMSCRIPTEN)
				throw new SdlException.InvalidForPlatform("Resource not available");
#else
                var ptr = GLib.resources_lookup_data(sdx.resourceBase+"/"+getPath(), 0);
                var raw = new SDL.RWops.from_mem((void*)ptr.get_data(), (int)ptr.get_size());
                if (raw == null)
					throw new SdlException.UnableToLoadResource(getPath());
                return raw;
#endif				
			} else {
                var raw = new SDL.RWops.from_file(getPath(), "r");
                if (raw == null)
					throw new SdlException.UnableToLoadResource(getPath());
                return raw;

			}
		}

		public string read() {
			if (type == FileType.Resource) {
#if (ANDROID || EMSCRIPTEN)
				throw new SdlException.InvalidForPlatform("Resource not available");
#else
                var st =  GLib.resources_open_stream(sdx.resourceBase+"/"+getPath(), 0);
				var sb = new StringBuilder();
				var ready = true;
				var buffer = new uint8[100];
				ssize_t size;
				while (ready) {
					size = st.read(buffer);
					if (size > 0)
						sb.append_len((string) buffer, size);
					else
						ready = false;
				}
				return sb.str;

#endif
			} else {
				return file.read();
			}
		}
		public FileType getType() {
			return type;
		}

		public string getName() {
			return file.getName();
		}

		public string getExt() {
            var name = getName();
            var i = name.last_index_of(".");
            if (i < 0) return "";
			var ext = name.substring(i);
			// BUG fix for emscripten:
			if (ext.index_of(".") < 0) ext = "."+ext;
			return ext;
            //  return name.substring(i);			
		}

		public string getPath() {
			return file.getPath();
		}

		public FileHandle getParent() {
			return new FileHandle(file.getParent(), type); //FileType.Parent);
		}

		public bool exists() {
			if (type == FileType.Resource) {
				return true;
			} else {
				return file.exists();
			}
		}

		/**
		 * Gets a file that is a sibling
		 */
		public FileHandle child(string name) {
            return new FileHandle(file.getPath() + utils.pathSeparator + name, type);
		}

	}
}


