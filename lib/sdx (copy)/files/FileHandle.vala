/*******************************************************************************
 * Copyright 2017 darkoverlordofdata.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
namespace Sdx.Files 
{

	/**
	 * get a better grip on the file object
	 */	
	public class FileHandle : Object 
	{
		public Utils.File file;
		public string path;
		public FileType type;

		public FileHandle(string path, FileType type) 
		{
			this.path = path;
			this.type = type;
			this.file = new Utils.File(path);
		}

		/**
		 * Loads a raw resource value
		 */
		public SDL.RWops GetRWops() 
		{
			if (type == FileType.Resource) 
			{
#if (ANDROID || EMSCRIPTEN || NOGOBJECT)
				throw new SdlException.InvalidForPlatform("Resource not available");
#else
                var bytes = GLib.ResourcesLookupData(Sdx.resourceBase+"/"+GetPath(), 0);
                var raw = new SDL.RWops.FromMem((void*)bytes.GetData(), (int)bytes.GetSize());
                if (raw == null)
					throw new SdlException.UnableToLoadResource(GetPath());
                return raw;
#endif				
			} 
			else 
			{
                var raw = new SDL.RWops.FromFile(GetPath(), "r");
				if (raw == null)
					throw new SdlException.UnableToLoadResource(GetPath());
                return raw;

			}
		}

		public string Read() 
		{
			if (type == FileType.Resource) 
			{
#if (ANDROID || EMSCRIPTEN || NOGOBJECT)
				throw new SdlException.InvalidForPlatform("Resource not available");
#else
                var st =  GLib.ResourcesOpenStream(Sdx.resourceBase+"/"+GetPath(), 0);
				var sb = new StringBuilder();
				var ready = true;
				var buffer = new uint8[100];
				while (ready) {
					var size = st.Read(buffer);
					if (size > 0) 
					{
						buffer[size] = 0;
						sb.Append((string) buffer);
					} 
					else 
					{
						ready = false;
					}
				}
				return sb.str;
#endif
			} 
			else 
			{
				return file.Read();
			}
		}
		public FileType GetType() 
		{
			return type;
		}

		public string GetName() 
		{
			return file.GetName();
		}

		public string GetExt() 
		{
            var name = GetName();
            var i = name.LastIndexOf(".");
            if (i < 0) return "";
			var ext = name.SubString(i);
			// BUG fix for emscripten:
			if (ext.IndexOf(".") < 0) ext = "."+ext;
			return ext;
		}

		public string GetPath() 
		{
			return file.GetPath();
		}

		public FileHandle GetParent() 
		{
			return new FileHandle(file.GetParent(), type); //FileType.Parent);
		}

		public bool Exists() 
		{
			if (type == FileType.Resource) 
			{
				return true;
			} 
			else 
			{
				return file.Exists();
			}
		}

		/**
		 * Gets a file that is a sibling
		 */
		public FileHandle Child(string name) 
		{
            return new FileHandle(file.GetPath() + Utils.PathSeparator + name, type);
		}

	}
}


