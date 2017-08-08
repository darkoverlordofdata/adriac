/* ******************************************************************************
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

/**
 * Entitas
 * 
 * An ECS (entity component system) 
 * based on: [[https://github.com/sschmid/Entitas-CSharp|Entitas-CSharp]]
 * 
 */
namespace Entitas 
{

	/**
	 * ECS Exceptions
	 */
	public errordomain Exception 
	{
		EntityIsNotEnabled,
		EntityAlreadyHasComponent,
		EntityDoesNotHaveComponent,
		InvalidMatcherExpression,
		EntityIsAlreadyReleased,
		SingleEntity,
		WorldDoesNotContainEntity
	}

	/**
	 * Factory method - create an entity
	 */
	public delegate Entity* EntityFactory();
	/**
	 * Calls Initialize() on all IInitializeSystem and other
	 * nested Systems instances in the order you added them.
	 */
	public delegate void SystemInitialize();
	/**
	 * Calls Execute() on all IExecuteSystem and other
	 * nested Systems instances in the order you added them.
	 */
	public delegate void SystemExecute(float delta);

	/**
	 * Describe the cache buffer for a factory
	 */
	public struct Buffer 
	{
		public int pool;		   		// pool index
		public int size;		   		// pool size
		public EntityFactory Factory;	// factory callback
		public Buffer(int pool, int size, EntityFactory factory) 
		{
			this.pool = pool;
			this.size = size;
			this.Factory = factory;
		}
	}

    /**
	 * This is the base interface for all systems
	 */
	public struct ISystem 
	{ 
		public SystemInitialize Initialize;
		public SystemExecute Execute;
	}



    /**
	 * Systems provide a convenient way to group systems.
     * All systems will be initialized and executed based on the order
     * you added them.
	 */
	public class System : Object 
	{
		public ISystem ISystem 
		{ 
			get { return { Initialize, Execute }; } 
		}
        /**
		 * Calls Initialize() on all IInitializeSystem and other
		 * nested Systems instances in the order you added them.
		 */
		public SystemInitialize Initialize = () => {};
        /**
         * Calls Execute() on all IExecuteSystem and other
         * nested Systems instances in the order you added them.
 		 */
		public SystemExecute Execute = (delta) => {};
	}	


	/**
	 * Bit array masks
	 */
	const uint64[] POW2 = 
	{
		0x0000000000000000,
		0x0000000000000001,
		0x0000000000000002,
		0x0000000000000004,
		0x0000000000000008,
		0x0000000000000010,
		0x0000000000000020,
		0x0000000000000040,
		0x0000000000000080,
		0x0000000000000100,
		0x0000000000000200,
		0x0000000000000400,
		0x0000000000000800,
		0x0000000000001000,
		0x0000000000002000,
		0x0000000000004000,
		0x0000000000008000,
		0x0000000000010000,
		0x0000000000020000,
		0x0000000000040000,
		0x0000000000080000,
		0x0000000000100000,
		0x0000000000200000,
		0x0000000000400000,
		0x0000000000800000,
		0x0000000001000000,
		0x0000000002000000,
		0x0000000004000000,
		0x0000000008000000,
		0x0000000010000000,
		0x0000000020000000,
		0x0000000040000000,
		0x0000000080000000,
		0x0000000100000000,
		0x0000000200000000,
		0x0000000400000000,
		0x0000000800000000,
		0x0000001000000000,
		0x0000002000000000,
		0x0000004000000000,
		0x0000008000000000,
		0x0000010000000000,
		0x0000020000000000,
		0x0000040000000000,
		0x0000080000000000,
		0x0000100000000000,
		0x0000200000000000,
		0x0000400000000000,
		0x0000800000000000,
		0x0001000000000000,
		0x0002000000000000,
		0x0004000000000000,
		0x0008000000000000,
		0x0010000000000000,
		0x0020000000000000,
		0x0040000000000000,
		0x0080000000000000,
		0x0100000000000000,
		0x0200000000000000,
		0x0400000000000000,
		0x0800000000000000,
		0x1000000000000000,
		0x2000000000000000,
		0x4000000000000000,
		0x8000000000000000

	};
}


