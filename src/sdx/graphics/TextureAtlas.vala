namespace sdx.graphics {
	/**sdx_graphics_texture_atlas_inner_class_release
	 * 
	 */
	public class TextureAtlas : Object {

        public InnerClass x;

            public class InnerClass : Object {

            public string name;

            public InnerClass() {
                print("this is na inner test\n");
                name = "frodo";
            }
        }


        public TextureAtlas() {
            x = new InnerClass();
            print("this is a test\n");

        }

        public InnerClass createInner() {
            return new InnerClass();
        }
    }
}