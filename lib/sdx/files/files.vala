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
/**
 * Sdx Files
 * 
 * Use SDL2 for file io
 */
namespace Sdx.Files {

	public FileHandle GetHandle(string path, FileType type) {
		return new FileHandle(path, type);
	}

	public FileHandle Resource(string path) {
		return new FileHandle(path, FileType.Resource);
	}

	public FileHandle Asset(string path) {
		return new FileHandle(path, FileType.Asset);
	}

	public FileHandle Absolute(string path) {
		return new FileHandle(path, FileType.Absolute);
	}

	public FileHandle Relative(string path) {
		return new FileHandle(path, FileType.Relative);
	}
	public FileHandle Default(string path) {
#if (EMSCRIPTEN)
		return new FileHandle(path, FileType.Relative);
#elif (ANDROID)
		return new FileHandle(path, FileType.Asset);
#elif (NOGOBJECT)
		return new FileHandle(path, FileType.Relative);
#else
		return new FileHandle(path, FileType.Resource);
#endif		
	}
}

