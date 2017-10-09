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
//  #if (!NOGOBJECT && !EMSCRIPTEN)
//  /**
//   * Base class to replace GLib.Object
//   */
//  public class Object {}
//  #endif

/**
 * Class Registration Exceptions
 */
public errordomain Exception
{
	/**
	 * Thrown when referening a class that is not registered
	 */
	ClassNotRegistered,
	/**
	 * Thrown when registering a class that is already registered.
	 */
	ClassAlreadyRegistered
}

/**
 * Core Class bits
 */
public class Klass : Object
{
	/**
	 * a weak referece to the Class for this object
	 */
	public Class* klass; 
}

/**
 * Class metadata header
 */
public class Class : Object
{
	/**
	 * Registers a classid and returns the unique rehash
	 */
	public static Class Register(string name, string? guid=null)
	{
		if (classes == null) 
			classes = new HashTable<string,Class>(str_hash, str_equal);
		if (registry == null) 
			registry = new HashTable<Guid*,Class>(null, null);

		var klass = classes.Get(name);
		if (klass == null)
		{
			string uuid = guid==null ? Guid.Generate() : guid;
			klass = new Class(name, uuid); 
			classes.Set(name, klass);
			registry.Set(klass.clsId, klass);
		}
		return klass;
	}

	/**
	 */
	public static Class Get(string name)
	{
		if (classes == null) throw new Exception.ClassNotRegistered(name);
		var klass = classes.Get(name);
		if (klass == null) throw new Exception.ClassNotRegistered(name);
		return klass;
	}


	/**
	 * Provides typeinfo for registered classes.
	 */
	public static HashTable<Guid*,Class> registry;
	public static HashTable<string,Class> classes;


	public Guid? ClsId;	//	the parsed guid
	public Guid* clsId;	//	unique re-hash
	public string uuid;
	public string name;
	/**
	 * Parse a binary guid from string
	 * Creates a unique re-hash that fits in one word.
	 */
	public Class(string name, string uuid)
	{
		this.uuid = uuid;
		this.name = name;
		ClsId = Guid.Parse(uuid);
		clsId = &ClsId;
	}

	/**
	 * String representation of the klass
	 */
	public string ToString()
	{
		return uuid;
	}

}
