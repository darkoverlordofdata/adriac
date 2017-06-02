namespace entitas {

	/**
	 * Match entities by component
	 * complile list of components to bit array for fast comparison
	 *
	 */
	public class Matcher : Object {
		/**
		 * A unique sequential index number assigned to each match
		 * @type number */
		public static int uniqueId;
		/**
		 * Get the matcher id
		 * @type number
		 * @name entitas.Matcher#id */
		public int id;
		/**
		 * A unique sequential index number assigned to each entity at creation
		 * @type number
		 * @name entitas.Matcher#allOfIndices */
		public int[] allOfIndices;

		public uint64 allOfMask;

		/**
		 * A unique sequential index number assigned to each entity at creation
		 * @type number
		 * @name entitas.Matcher#anyOfIndices */
		public int[] anyOfIndices;

		public uint64 anyOfMask;
		/**
		 * A unique sequential index number assigned to each entity at creation
		 * @type number
		 * @name entitas.Matcher#noneOfIndices */
		public int[] noneOfIndices;

		public uint64 noneOfMask;

		public int[] indices;
		public string toStringCache;

		/**
		 *  clone/merge 1 or more existing matchers
		 */
		public Matcher(Matcher[] matchers = null ) {
			id = uniqueId++;
			if (matchers != null) {
				var allOf = new int[0];
				var anyOf = new int[0];
				var noneOf = new int[0];
				for (var i=0;  i < matchers.length; i++) {
					allOfMask |= matchers[i].allOfMask;
					anyOfMask |= matchers[i].anyOfMask;
					noneOfMask |= matchers[i].noneOfMask;
					foreach (var j in matchers[i].allOfIndices) allOf += j;
					foreach (var j in matchers[i].anyOfIndices) anyOf += j;
					foreach (var j in matchers[i].noneOfIndices) noneOf += j;
				}
				allOfIndices = Matcher.distinctIndices(allOf);
				anyOfIndices = Matcher.distinctIndices(anyOf);
				noneOfIndices = Matcher.distinctIndices(noneOf);
			}
		}

		/**
		 * A list of the component ordinals that this matches
		 * @type Array<number>
		 * @name entitas.Matcher#indices */
		public int[] getIndices() {
			if (indices == null)
				indices = mergeIndices();
			return indices;
		}

		/**
		 * Matches anyOf the components/indices specified
		 * @params Array<entitas.IMatcher>|Array<number> args
		 * @returns entitas.Matcher
		 */
		public Matcher* anyOf(int[] args) { 
			anyOfIndices = Matcher.distinctIndices(args);
			indices = null;
			return this;
		}

		/**
		 * Matches noneOf the components/indices specified
		 * @params Array<entitas.IMatcher>|Array<number> args
		 * @returns entitas.Matcher
		 */
		public Matcher* noneOf(int[] args) { 
			noneOfIndices = Matcher.distinctIndices(args);
			indices = null;
			return this;
		}

		/**
		 * Check if the entity matches this matcher
		 * @param entitas.IEntity entity	
		 * @returns boolean
		 */
		public bool matches(Entity* entity) {
			var mask = entity.mask ^ ACTIVE; 
			var matchesAllOf  = allOfMask  == 0 ? true : (mask & allOfMask) == allOfMask;
			var matchesAnyOf  = anyOfMask  == 0 ? true : (mask & anyOfMask) != 0;
			var matchesNoneOf = noneOfMask == 0 ? true : (mask & noneOfMask) == 0;
			return matchesAllOf && matchesAnyOf && matchesNoneOf;
		}

		/**
		 * Merge list of component indices
		 * @returns Array<number>
		 */
		public int[] mergeIndices() {

			var indices = new int[0];
			if (allOfIndices != null)
				foreach (var i in allOfIndices) indices += i;

			if (anyOfIndices != null)
				foreach (var i in anyOfIndices) indices += i;

			if (noneOfIndices != null)
				foreach (var i in noneOfIndices) indices += i;

			return Matcher.distinctIndices(indices);
		}

		/**
		 * toString representation of this matcher
		 * @returns string
		 */
		public string toString() {
			if (toStringCache == null) {
				var sb = "";
				if (allOfIndices != null) {
					sb += "AllOf(";
					sb += componentstoString(allOfIndices);
					sb += ")";
				}
				if (anyOfIndices != null) {
					if (allOfIndices != null)
						sb += ".";
					sb += "AnyOf(";
					sb += componentstoString(anyOfIndices);
					sb += ")";
				}
				if (noneOfIndices != null) {
					sb += ".NoneOf(";
					sb += componentstoString(noneOfIndices);
					sb += ")";
				}
				toStringCache = sb;
			}
			return toStringCache;
		}

		public static string componentstoString(int[] indexArray) {
			var sb = "";
			foreach (var index in indexArray) 
				sb += ComponentString[index];
			return sb;
		}

		public static int[] listToArray(List<int> list) {
			var a = new int[list.length()];
			var i = 0;
			foreach (var x in list) a[i++] = x;
			return a;
		}
		/**
		 * Get the set if distinct (non-duplicate) indices from a list
		 * @param Array<number> indices
		 * @returns Array<number>
		 */
		public static int[] distinctIndices(int[] indices) {
			var indicesSet = new bool[64];
			var result = new List<int>();

			foreach (var index in indices) {
				if (!indicesSet[index])
					result.prepend(index);
				indicesSet[index] = true;
			}
			return listToArray(result);
		}

		/**
		 * Merge all the indices of a set of Matchers
		 * @param Array<IMatcher> matchers
		 * @returns Array<number>
		 */
		public static int[] merge(Matcher[] matchers) throws Exception {
			var indices = new List<int>();

			for (var i=0; i < matchers.length-1; i++) {
				if (matchers[i].indices.length != 1)
					throw new Exception.InvalidMatcherExpression(matchers[i].toString());
				indices.prepend(matchers[i].indices[0]);
			}
			return listToArray(indices);
		}

		/**
		 * Matches noneOf the components/indices specified
		 * @params Array<entitas.IMatcher>|Array<number> args
		 * @returns entitas.Matcher
		 */
		public static Matcher NoneOf(int[] args) {
			var matcher = new Matcher();
			matcher.noneOfIndices = Matcher.distinctIndices(args);
			matcher.noneOfMask = Matcher.buildMask(matcher.noneOfIndices);
			return matcher;
		}
		/**
		 * Matches allOf the components/indices specified
		 * @params Array<entitas.IMatcher>|Array<number> args
		 * @returns entitas.Matcher
		 */
		public static Matcher AllOf(int[] args) { 
			var matcher = new Matcher();
			matcher.allOfIndices = Matcher.distinctIndices(args);
			matcher.allOfMask = Matcher.buildMask(matcher.allOfIndices);
			return matcher;
		}

		/**
		 * Matches anyOf the components/indices specified
		 * @params Array<entitas.IMatcher>|Array<number> args
		 * @returns entitas.Matcher
		 */
		public static Matcher AnyOf(int[] args) { 
			var matcher = new Matcher();
			matcher.anyOfIndices = Matcher.distinctIndices(args);
			matcher.anyOfMask = Matcher.buildMask(matcher.anyOfIndices);
			return matcher;
		}

		public static uint64 buildMask(int[] indices) { 
			uint64 accume = 0;
			foreach (var index in indices) accume |= POW2[index];
			return accume;
		}
	}
}

