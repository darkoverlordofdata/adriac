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
using Goop;
/** Goop Registry */
/** Oopily doopily */
/** Of all the oopishness... */
/**
 * Registers a classid and returns the unique rehash
 */
public Guid* ClsId(string guid)
{
	if (classes == null) 
		classes = new HashTable<string,Class>(str_hash, str_equal);
	if (classRegistry == null) 
		classRegistry = new HashTable<Guid*,Class>(null, null);

	var klass = classes.Get(guid);
	if (klass == null)
	{
		klass = new Class(guid);
		classes.Set(guid, klass);
		classRegistry.Set(klass.clsId, klass);
	}
	return klass.clsId;
}
[SimpleType, Immutable]
public struct Guid 
{
	public uint32 data1;
	public uint16 data2; 
	public uint16 data3; 
	public uint8 data4[8];

	public string ToString()
	{
		return "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x".printf(data1, data2, data3, 
			data4[0], data4[1], data4[2], data4[3], data4[4], data4[5], data4[6], data4[7]);
	}
}


namespace Goop {
	/**
	 * Provides typeinfo for registered classes.
	 * Use the Class::clsId field value as the first field of a class.
	 * 
	 */
	public static HashTable<Guid*,Class> classRegistry;
	public static HashTable<string,Class> classes;



	/**
	 * Parse a binary guid from string
	 * Creates a unique re-hash that fits in one word.
	 */
	public class Class : Object
	{
		public Guid? ClsId;	//	the parsed guid
		public Guid* clsId;	//	unique re-hash
		public string uuid;
		public Class(string v4)
		{
			uuid = v4;
			Parse(v4);
			clsId = &ClsId;
		}

		/**
		 * Parse a Guid string "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
		 */
		public void Parse(string v4)
		{
			var s = string.Joinv("", v4.Split("-"));
			if (s.length != 32)
				throw new Sdx.Exception.IllegalArgumentException(v4);
			
			char* b = (char*)s;
			uint8 res[16];

			for (var i=0, p=0; i<16; i++)
			{
				if (b[p] >= '0' && b[p] <= '9')
					res[i] = b[p]-'0';
				else if (b[p] >= 'a' && b[p] <= 'f')
					res[i] = b[p]-'a'+10;
				else if (b[p] >= 'A' && b[p] <= 'F')
					res[i] = b[p]-'A'+10;
				else
					throw new Sdx.Exception.IllegalArgumentException(v4);
				p++;

				if (b[p] >= '0' && b[p] <= '9')
					res[i] = res[i]*16+b[p]-'0';
				else if (b[p] >= 'a' && b[p] <= 'f')
					res[i] = res[i]*16+b[p]-'a'+10;
				else if (b[p] >= 'A' && b[p] <= 'F')
					res[i] = res[i]*16+b[p]-'A'+10;
				else
					throw new Sdx.Exception.IllegalArgumentException(v4);
				p++;
			}

			uint32 d1 = res[0];
			d1 = d1 << 8 | res[1];
			d1 = d1 << 8 | res[2];
			d1 = d1 << 8 | res[3];

			uint16 d2 = res[4];
			d2 = d2 << 8 | res[5];

			uint16 d3 = res[6];
			d3 = d3 << 8 | res[7];

			ClsId = Guid() { data1 = d1, data2 = d2, data3 = d3, 
				data4 = { res[8], res[9], res[10], res[11], res[12], res[13], res[14], res[15] } 
			};

		}
		
	}
}