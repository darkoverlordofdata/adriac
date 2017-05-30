namespace entitas {
	
	public class World : Object {
		public static World instance;
		public List<Group> groups;
		public Entity[] pool;
		public Cache[] cache;
		public int id = 0;
		public ISystem?[] systems = new ISystem?[100];
		public int count = 0;
		public  EntityRemovedListener entityRemoved;

		public World() {
			instance = this;
		}

		public static void onComponentAdded(Entity* e, Components c) {
			instance.componentAddedOrRemoved(e, c);
		}

		public static void onComponentRemoved(Entity* e, Components c) {
			instance.componentAddedOrRemoved(e, c);
		}

		public void setPool(int size, int count, Buffer[] buffers) {
			pool = new Entity[size];
			cache = new Cache[count];
			for (var i=0;  i < buffers.length; i++) {
				var iPool = buffers[i].pool;
				var iSize = buffers[i].size;
				cache[iPool] = new Cache(); //iSize) 
				for (var k=0;  k < iSize; k++) {
					cache[iPool].enque(buffers[i].factory());
				}
			}
		}
				
		public void addSystem(ISystem iface) {
			systems[count++] = iface;
		}

		public void initialize() {
			for (var i=0; i < count; i++)
				systems[i].initialize();
		}

		public void execute(double delta) {
			for (var i=0; i < count; i++)
				systems[i].execute(delta);
		}

		public void setEntityRemovedListener(EntityRemovedListener removed) {
			entityRemoved = removed;
		}

		public void componentAddedOrRemoved(Entity* entity, Components component) {
			foreach (var group in groups)
				group.handleEntity(entity, component);
		}

		/**
		* send antity back to it's pool
		*/		
		public void deleteEntity(Entity* entity) {
			entity.setActive(false);
			cache[entity.pool].enque(entity);
			entityRemoved(entity);
		}

		/**
		* create an entity from the pool
		*/
		public Entity* createEntity(string name, int pool, bool active) {
			var id = this.id++;
			return  (this.pool[id]
				.setId(id)
				.setName(name)
				.setPool(pool)
				.setActive(active));
		}

		public Group getGroup(Matcher matcher) {
			if (groups.length() > matcher.id ) {
				return groups.nth_data(matcher.id);
			} else {
				groups.prepend(new Group(matcher));
				for (var i = 0; i < this.id-1; i++) 
					groups.nth_data(0).handleEntitySilently(&pool[i]);
				return groups.nth_data(0);
			}
		}
	}
}


