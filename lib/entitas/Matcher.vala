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
namespace Entitas 
{
	/**
	 * Match entities by component
	 * complile list of components to bit array for fast comparison
	 *
	 */
	public class Matcher : Object 
	{
		/**
		 * A unique sequential index number assigned to each match
		 * type number 
		 */
		public static int uniqueId;
		/**
		 * Get the matcher id
		 * type number
		 */
		public int id;
		/**
		 * A unique sequential index number assigned to each entity at creation
		 * type number
		 */
		public int[] allOfIndices;

		public uint64 allOfMask;

		/**
		 * A unique sequential index number assigned to each entity at creation
		 * type number
		 */
		public int[] anyOfIndices;

		public uint64 anyOfMask;
		/**
		 * A unique sequential index number assigned to each entity at creation
		 * type number
		 */
		public int[] noneOfIndices;

		public uint64 noneOfMask;

		public int[] indices;
		public string toStringCache;

		/**
		 *  clone/merge 1 or more existing matchers
		 */
		public Matcher(Matcher[] matchers = null ) 
		{
			id = uniqueId++;
			if (matchers != null) 
			{
				//  print("matchers != null\n");
				var allOf = new int[0];
				var anyOf = new int[0];
				var noneOf = new int[0];
				for (var i=0;  i < matchers.length; i++) 
				{
					allOfMask |= matchers[i].allOfMask;
					anyOfMask |= matchers[i].anyOfMask;
					noneOfMask |= matchers[i].noneOfMask;
					foreach (var j in matchers[i].allOfIndices) allOf += j;
					foreach (var j in matchers[i].anyOfIndices) anyOf += j;
					foreach (var j in matchers[i].noneOfIndices) noneOf += j;
				}
				allOfIndices = Matcher.DistinctIndices(allOf);
				anyOfIndices = Matcher.DistinctIndices(anyOf);
				noneOfIndices = Matcher.DistinctIndices(noneOf);
				
			}
		}

		/**
		 * Check if the entity matches this matcher
		 * @param entity to match 
		 * @return boolean true if matches else false
		 */
		public bool Matches(Entity* entity) 
		{
			var mask = entity.mask ^ ACTIVE; 
			var matchesAllOf  = allOfMask  == 0 ? true : (mask & allOfMask) == allOfMask;
			var matchesAnyOf  = anyOfMask  == 0 ? true : (mask & anyOfMask) != 0;
			var matchesNoneOf = noneOfMask == 0 ? true : (mask & noneOfMask) == 0;
			return matchesAllOf && matchesAnyOf && matchesNoneOf;
		}

		/**
		 * Merge list of component indices
		 * @return Array<number>
		 */
		public int[] MergeIndices() 
		{

			var indices = new int[0];
			if (allOfIndices != null)
				foreach (var i in allOfIndices) indices += i;

			if (anyOfIndices != null)
				foreach (var i in anyOfIndices) indices += i;

			if (noneOfIndices != null)
				foreach (var i in noneOfIndices) indices += i;

			return Matcher.DistinctIndices(indices);
		}

		/**
		 * toString representation of this matcher
		 * @return string
		 */
		public string ToString() 
		{
			if (toStringCache == null) 
			{
				var sb = new StringBuilder();
				if (allOfIndices != null) 
				{
					sb.Append("AllOf(")
					.Append(ComponentsToString(allOfIndices))
					.Append(")");
				}
				if (anyOfIndices != null) 
				{
					if (allOfIndices != null)
						sb.Append(".");
					sb.Append("AnyOf(")
					.Append(ComponentsToString(anyOfIndices))
					.Append(")");
				}
				if (noneOfIndices != null) 
				{
					sb.Append(".NoneOf(")
					.Append(ComponentsToString(noneOfIndices))
					.Append(")");
				}
				toStringCache = sb.str;
			}
			return toStringCache;
		}

		public static string ComponentsToString(int[] indexArray) 
		{
			var sb = new StringBuilder();
			var i = 0;
			foreach (var index in indexArray) 
			{
				sb.Append(ComponentString[index]).Append(",");
				i = 1;
			}
			sb.Truncate(sb.len-i);
			return sb.str;
		}

		public static int[] ListToArray(List<int> list) 
		{
			var a = new int[list.Length()];
			var i = 0;
			foreach (var x in list) a[i++] = x;
			return a;
		}
		/**
		 * Get the set if distinct (non-duplicate) indices from a list
		 * @param indices array of indices to scrub
		 * @return array of distint indices
		 */
		public static int[] DistinctIndices(int[] indices) 
		{
			var indicesSet = new bool[64];
			var result = new List<int>();

			foreach (var index in indices) 
			{
				if (!indicesSet[index])
					result.Insert(index);
				indicesSet[index] = true;
			}
			return ListToArray(result);
		}


		/**
		 * Matches noneOf the components/indices specified
		 * @param components list of components to match
		 * @return new component matcher
		 */
		public static Matcher NoneOf(int[] components) 
		{
			var matcher = new Matcher();
			matcher.noneOfIndices = Matcher.DistinctIndices(components);
			matcher.noneOfMask = Matcher.BuildMask(matcher.noneOfIndices);
			return matcher;
		}
		/**
		 * Matches allOf the components/indices specified
		 * @param components list of components to match
		 * @return new component matcher
		 */
		public static Matcher AllOf(int[] components) 
		{ 
			var matcher = new Matcher();
			matcher.allOfIndices = Matcher.DistinctIndices(components);
			matcher.allOfMask = Matcher.BuildMask(matcher.allOfIndices);
			return matcher;
		}

		/**
		 * Matches anyOf the components/indices specified
		 * @param components list of components to match
		 * @return new component matcher
		 */
		public static Matcher AnyOf(int[] components) 
		{ 
			var matcher = new Matcher();
			matcher.anyOfIndices = Matcher.DistinctIndices(components);
			matcher.anyOfMask = Matcher.BuildMask(matcher.anyOfIndices);
			return matcher;
		}

		public static uint64 BuildMask(int[] indices) 
		{ 
			uint64 accume = 0;
			foreach (var index in indices) accume |= POW2[index];
			return accume;
		}
	}
}

