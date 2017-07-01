
using sdx.files;

namespace sdx.audio {

    public class Sound : Object {

#if (!EMSCRIPTEN) 
        public SDLMixer.Chunk chunk;

        public Sound(FileHandle file) {
            chunk = new SDLMixer.Chunk.WAV_RW(file.getRWops());
        }

        public void play(int loops = 0) {            
            SDLMixer.play(-1, chunk, loops);

        }
#else
        public Sound(FileHandle file) {
        }

        public void play(int loops = 0) {            
        }

#endif
    }
}