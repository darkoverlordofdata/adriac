/* ******************************************************************************
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
using Sdx.Files;

namespace Sdx {

	public enum FileType 
	{
		Resource = 1,		/* Path to memory GResource */
		Asset,				/* Android asset folder */
		Absolute,			/* Absolute filesystem path.  */
		Relative			/* Path relative to the pwd */
		//  Parent = 0x10		/* Placeholder for the parent path  */
	}
	
	public class DataInputStream : Object 
	{
		public string[] data; 
		public int ctr;
		public DataInputStream(string data) 
		{
			this.data = data.Split("\n");

			ctr = 0;
		}
		public string? ReadLine() 
		{
			return ctr<data.length ? data[ctr++] : null;
		}
	}
}
