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

using Sdx.Files;

namespace Sdx.Audio {

    public class Sound : Object {

#if (!EMSCRIPTEN) 
        public SDLMixer.Chunk chunk;

        public Sound(FileHandle file) {
            chunk = new SDLMixer.Chunk.WAV_RW(file.GetRWops());
        }

        public void Play(int loops = 0) {   
            SDLMixer.play(-1, chunk, loops);
        }
#else
// TODO:  use vorbis for emscripten

        public Sound(FileHandle file) {
        }

        public void Play(int loops = 0) {            
        }

#endif
    }
}