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
	public class World : Object 
	{
		/**
		 * A unique sequential index number assigned to each entity
		 * @type int */
		public int id = 0;

		/**
		 * Pool of prebuilt entities
		 * @type Entity[] */
		public Entity[] pool;

		/**
		 * Systems to run
		 * @type ISystem[] */
		public ISystem[] systems;

		/**
		 * Cache of unused Entity* in poool
		 * @type Queue<Entity*>[] */
		public Stack<Entity*>[] cache;

		/**
		 * List of active groups
		 * @type List<Group> */
		public List<Group> groups;

        /**
         * Subscribe to Entity Created Event
         * @type Event.WorldChanged */
		public Event.WorldChanged onEntityCreated;

        /**
         * Subscribe to Entity Will Be Destroyed Event
         * @type Event.WorldChanged */
		public Event.WorldChanged onEntityWillBeDestroyed;

        /**
         * Subscribe to Entity Destroyed Event
         * @type Event.WorldChanged */
		public Event.WorldChanged onEntityDestroyed;

        /**
         * Subscribe to Group Created Event
         * @type Event.GroupsChanged */
		public Event.GroupsChanged onGroupCreated;

		public World() 
		{
			systems = new ISystem[0];
            onGroupCreated = new Event.GroupsChanged();
            onEntityCreated = new Event.WorldChanged();
            onEntityDestroyed = new Event.WorldChanged();
            onEntityWillBeDestroyed = new Event.WorldChanged();
		}

		public void SetPool(int size, int count, Buffer[] buffers) 
		{
			pool = new Entity[size+1];
			cache = new Stack<Entity*>[count];
			for (var i = 0; i < buffers.length; i++) 
			{
				var bufferPool = buffers[i].pool;
				var bufferSize = buffers[i].size;
				cache[bufferPool] = new Stack<Entity*>(bufferSize); 
				for (var k = 0; k < bufferSize; k++) 
				{
					cache[bufferPool].Push(buffers[i].Factory());
				}
			}
		}
				
        /**
         * add System
         * @param entitas.ISystem|Function
         * @returns entitas.ISystem
         */
		public World AddSystem(System system) 
		{
			// make a local copy of the array
			// so we can copy and concat

			var sy = systems;
			sy += system.ISystem;
			systems = sy;
			return this;
		}

        /**
         * Initialize Systems
         */
		public void Initialize() 
		{
			foreach (var system in systems)
				system.Initialize();
		}

        /**
         * Execute Systems
         */
		public void Execute(float delta) 
		{
			foreach (var system in systems)
				system.Execute(delta);
		}

        /**
         * @param entitas.Entity entity
         * @param number index
         * @param entitas.IComponent component
         */
		public void ComponentAddedOrRemoved(Entity* entity, int index, void* component) 
		{
			foreach (var group in groups)
				group.HandleEntity(entity, index, component);
		}

        /**
         * Destroy an entity
         * @param entitas.Entity entity
         */
		public void DeleteEntity(Entity* entity) 
		{
            onEntityWillBeDestroyed.Dispatch(this, entity);
			entity.Destroy();
            onEntityDestroyed.Dispatch(this, entity);
			cache[entity.pool].Push(entity);

			//EntityRemoved(entity);
		}

		public void onEntityReleased(Entity* e) 
		{

		}

		public void onComponentReplaced(Entity* e, int index,  void* component, void* replacement)
		{

		}

        /**
         * Create a new entity
         * @param string name
         * @returns entitas.Entity
         */
		public Entity* CreateEntity(string name, int pool, bool active) 
		{
			id++;
			this.pool[id] = Entity(id, ComponentAddedOrRemoved, onEntityReleased, onComponentReplaced);
			return this.pool[id]
				.SetName(name)
				.SetPool(pool)
				.SetActive(active);
		}


       /**
         * Gets all of the entities that match
         *
         * @param entias.IMatcher matcher
         * @returns entitas.Group
         */
 		public Group GetGroup(Matcher matcher) 
		{
			if (groups.Length() > matcher.id ) 
			{
				return groups.Item(matcher.id).data;
			} 
			else 
			{
				//  groups.prepend(new Group(matcher));
				groups.Insert(new Group(matcher));
				for (var i = 0; i < id-1; i++) 
					groups.Head.data.HandleEntitySilently(&pool[i]);
                onGroupCreated.Dispatch(this, groups.Head.data);
				return groups.Head.data;
			}
		}
	}
}


