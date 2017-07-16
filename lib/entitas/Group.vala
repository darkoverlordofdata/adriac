/*******************************************************************************
 *# MIT License
 *
 * Copyright (c) 2015-2017 Bruce Davidson &lt;darkoverlordofdata@gmail.com&gt;
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * 'Software'), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
namespace Entitas 
{
	public class Group : Object 
	{
        /**
         * Get a list of the entities in this group
         *
         * @type List<Entity*>
         */
		public List<Entity*> entities;
        /**
         * Get the Matcher for this group
         * @type Entitas.Matcher */
 		public Matcher matcher;
       /**
         * Subscribe to IEntity Addded events
         * @type Event.GroupChanged */
		public Event.GroupChanged onEntityAdded;
        /**
         * Subscribe to IEntity Removed events
         * @type Event.GroupChanged */
		public Event.GroupChanged onEntityRemoved;
        /**
         * Subscribe to IEntity Updated events
         * @type Event.GroupUpdated */
		public Event.GroupUpdated onEntityUpdated;
		
		
		public Group(Matcher matcher) 
		{
			this.matcher = matcher;
            onEntityAdded = new Event.GroupChanged();
            onEntityRemoved = new Event.GroupChanged();
            onEntityUpdated = new Event.GroupUpdated();
		}

        /**
         * Handle adding and removing component from the entity without raising events
         * @param entity
         */
 		public void HandleEntitySilently(Entity* entity) 
		{
			if (matcher.Matches(entity)) 
				AddEntitySilently(entity);
			else 
				RemoveEntitySilently(entity);
		}

        /**
         * Handle adding and removing component from the entity and raisieevents
         * @param entity
         * @param index
         * @param component
         */
 		public void HandleEntity(Entity* entity, int index, void* component) 
		{
			if (matcher.Matches(entity))
				AddEntity(entity, index, component);
			else
				RemoveEntity(entity, index, component);
		} 

        /**
         * Add entity without raising events
         * @param entity
         */
		public void AddEntitySilently(Entity* entity) 
		{
			if (entities.Find(entity) == null) 
			{
				entities.Insert(entity);
			}

		}

        /**
         * Add entity and raise events
         * @param entity
         * @param index
         * @param component
         */
		public void AddEntity(Entity* entity, int index, void* component) 
		{
			if (entities.Find(entity) == null) 
			{
				entities.Insert(entity);
				onEntityAdded.Dispatch(this, entity, index, component);
			}

		}

        /**
         * Remove entity without raising events
         * @param entity
         */
		public void RemoveEntitySilently(Entity* entity) 
		{
			if (entities.Find(entity) != null) 
			{
				entities.Remove(entity);
			}
		}


        /**
         * Remove entity and raise events
         * @param entity
         * @param index
         * @param component
         */
		public void RemoveEntity(Entity* entity, int index, void* component) 
		{
			if (entities.Find(entity) != null) 
			{
				entities.Remove(entity);
				onEntityRemoved.Dispatch(this, entity, index, component);
			}
		}

 
        /**
         * Check if group has this entity
         *
         * @param entity
         * @returns boolean
         */
		public bool ContainsEntity(Entity* entity)
		{
			return entities.Find(entity) != null;
		}

        /**
         * Gets an entity singleton.
         * If a group has more than 1 entity, this is an error condition.
         *
         * @returns entitas.IEntity
         */
		public Entity* GetSingleEntity() 
		{ 
			var c = entities.Length();
			if (c == 1) 
			{
				return (Entity*)entities.Head.data;
			} 
			else if (c == 0) 
			{
				return null;
			} 
			else 
			{
				throw new Exception.SingleEntity(matcher.ToString());
			}
		}
	}
}
						
