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
namespace Sdx.Utils 
{

	public const string PathSeparator  = "/";
	public const char PathSeparatorChar  = '/';
	/**
	 * Simple File handler
	 * 
	 */
	
	public class File : Object 
	{

		//  public Posix.Stat? stat;
		public SDL.RWops file;
		public string path;
		public string[] files;

		public File(string path) 
		{
			this.path = path;
    		file = new SDL.RWops.FromFile(path, "r");
		} 

		public string GetPath() 
		{
			return path;
		}

		/**
		 * the name is everything after the final separator
		 */
		public string GetName() 
		{
			for (var i=path.length-1; i>0; i--)
				if (path[i] == PathSeparatorChar)
					return path.SubString(i+1);
			return path;
		}

		/**
		 * the parent is everything prior to the final separator
		 */
		public string GetParent() 
		{
			var i = path.LastIndexOf(PathSeparator);
			return i < 0 ? "" : path.SubString(0, i);
		}

		/**
		 * check if the represented struture exists on the virtual disk
		 */
		public bool Exists() 
		{
			return file != null;
		}

		/**
		 * is it a file?
		 */
		public bool IsFile() 
		{
			return file != null;
		}

		/**
		 * is it a folder?
		 */
		public bool IsDirectory() 
		{
			return false;
		}

		/**
		 * get the length of the file
		 */
		public int Length() 
		{
			return file != null ? (int)file.size : 0;
		}
		
		/**
		 * read the contents into a string buffer
		 */
		public string Read() 
		{
			if (!Exists()) return "";
			var size = (int)file.size;
	    	var ioBuff = new char[size+2];
    
    		var stat = file.Read((void*)ioBuff, 2, (size_t)size/2);
			var lines = "";
			lines = lines + (string)ioBuff;
			return lines;
		}
		
			/**
		 * return the list of files in the folder
		 */
		public string[] List() 
		{
			files = new string[0];
			return files;
		}
	}
}