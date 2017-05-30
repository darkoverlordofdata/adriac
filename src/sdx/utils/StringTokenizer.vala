namespace sdx.utils {

    public class StringTokenizer : Object {

        public int currentPosition;
        public int newPosition;
        public int maxPosition;
        public string str;
        public string delimiters;
        public bool retDelims;
        public bool delimsChanged;
        public int maxDelimCodePoint;
        public bool hasSurrogates = false;
        public int[] delimiterCodePoints;

        public StringTokenizer(string str, string delim = " \t\n\r\f", bool returnDelims = false) {
            currentPosition = 0;
            newPosition = -1;
            delimsChanged = false;
            this.str = str;
            maxPosition = str.length;
            delimiters = delim;
            retDelims = returnDelims;
            setMaxDelimCodePoint();
        }
            
        public void setMaxDelimCodePoint() {
            if (delimiters == null) {
                maxDelimCodePoint = 0;
                return;
            }

            var m = 0;
            var c = 0;
            var count = 0;
            for (var i=0 ; i<delimiters.length-1; i++) {
                c = delimiters[i];
                if (m < c) m = c;
                count++;
            }
            maxDelimCodePoint = m;
        }

        public int skipDelimiters(int startPos) {
            if (delimiters == null) {
                throw new SdlException.NullPointer("delimiters");
            }

            var position = startPos;
            while (!retDelims && position < maxPosition) {
                var c = str[position];
                if ((c > maxDelimCodePoint) || !isDelimiter(c)) break;
                position += 1;
            }
            return position;
        }

        public int scanToken(int startPos) {
            var position = startPos;
            while (position < maxPosition) {
                var c = str[position];
                if ((c <= maxDelimCodePoint) && isDelimiter(c)) break;
                position += 1;
            }   
            if (retDelims && (startPos == position)) {
                var c = str[position];
                if ((c <= maxDelimCodePoint) && isDelimiter(c)) position += 1;
            }
            return position;
        }


        public bool isDelimiter(char c) {
            for (var i = 0; i<delimiters.length-1; i++)
                if (delimiters[i] == c) return true;
            return false;
        }

        public bool hasMoreTokens() {
            newPosition = skipDelimiters(currentPosition);
            return newPosition < maxPosition;
        }

        public string nextToken(string delim = "") {
            if (delim > "") {
                delimiters = delim;
                delimsChanged = true;
            }
            currentPosition = newPosition >= 0 && !delimsChanged ? newPosition : skipDelimiters(currentPosition);

            delimsChanged = false;
            newPosition = -1;

            if (currentPosition >= maxPosition) throw new SdlException.NoSuchElement("");
            var start = currentPosition;
            currentPosition = scanToken(currentPosition);
            return str.substring(start, currentPosition);
        }
        
        public int countTokens() {
            var count = 0;
            var currpos = currentPosition;
            while (currpos < maxPosition) {
                currpos = skipDelimiters(currpos);
                if (currpos >= maxPosition) break;
                currpos = scanToken(currpos);
                count++;
            }
            return count;
        }
    }
}
