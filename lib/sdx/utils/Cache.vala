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
 * Unordered cache 
 */
namespace Sdx.Utils 
{	
	//  public class Cache<T> : Object 
	//  {

	//  	public T[] items;
	//  	public int size;
		
	//  	public Cache(int capacity = 4) 
	//  	{
	//  		items = new T[capacity];
	//  		size = 0;
	//  	}

	//  	public bool IsEmpty() 
	//  	{
	//  		return size == 0;
	//  	}

	//  	public T Get(int index) 
	//  	{
	//  		if (index < 0 || index > size) 
	//  		{
	//  			stdout.printf("Can't get cache at %d\n", index);
	//  			return null;
	//  		}
	//  		return items[index];
	//  	}

	//  	public void Put(int index, T entity) 
	//  	{
	//  		if (index < 0 || index >= size) 
	//  		{
	//  			stdout.printf("Can't put cache at %d\n", index);
	//  			return;
	//  		}
	//  		items[index] = entity;
	//  	}

	//  	public void Enque(T entity) 
	//  	{
	//  		if (size >= items.length) Grow(items.length*2);
	//  		items[size++] = entity;
	//  	}

	//  	public T Deque() 
	//  	{
	//  		if (size <= 0) 
	//  		{
	//  			stdout.printf("Unable to pop from queue\n");
	//  			return null;
	//  		}
	//  		return items[--size];
	//  	}

	//  	public void Grow(int newSize) 
	//  	{
	//  		var temp = new List<T>();
	//  		foreach (var item in items)
	//  			temp.Insert(item);

	//  		items = new T[newSize];

	//  		var i = 0;
	//  		foreach (var item in temp)
	//  			items[i++] = item;
		
	//  	}
	//  }
}			

