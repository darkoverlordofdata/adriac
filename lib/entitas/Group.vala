namespace entitas {

	public class Group : Object {
		public Matcher matcher;
		public List<Entity*> entities;
		
		public Group(Matcher matcher) {
			this.matcher = matcher;
		}

		/** Add entity to group */
		public void handleEntitySilently(Entity* entity) {
			if (matcher.matches(entity)) 
				entities.prepend(entity);
			else 
				entities.remove(entity);
		}

		/** Add entity to group and raise events */
		public void handleEntity(Entity* entity, Components index) {
			if (matcher.matches(entity))
				entities.prepend(entity);
			else
				entities.remove(entity);
		} 

		public bool containsEntity(Entity* entity) {
			return entities.find(entity) != null;
		}

		public Entity* getSingleEntity() { 
			var c = entities.length();
			if (c == 1) {
				return (Entity*)entities.first().data;
			} else if (c == 0) {
				return null;
			} else {
				throw new Exception.SingleEntity(matcher.toString());
			}
		}
	}
}
						
