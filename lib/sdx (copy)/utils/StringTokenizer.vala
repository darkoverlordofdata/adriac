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
namespace Sdx.Utils 
{

    public class StringTokenizer : Object 
    {

        public int currentPosition;
        public int newPosition;
        public int maxPosition;
        public string str;
        public string delimiters;
        public bool retDelims;
        public bool delimsChanged;
        public int maxDelimCodePoint;
        public int[] delimiterCodePoints;

        public StringTokenizer(string str, string delim = " \t\n\r\f", bool returnDelims = false) 
        {
            currentPosition = 0;
            newPosition = -1;
            delimsChanged = false;
            this.str = str;
            maxPosition = str.length;
            delimiters = delim;
            retDelims = returnDelims;
            SetMaxDelimCodePoint();
        }
            
        public void SetMaxDelimCodePoint() 
        {
            if (delimiters == null) 
            {
                maxDelimCodePoint = 0;
                return;
            }

            var m = 0;
            var c = 0;
            var count = 0;
            for (var i=0 ; i<delimiters.length-1; i++) 
            {
                c = delimiters[i];
                if (m < c) m = c;
                count++;
            }
            maxDelimCodePoint = m;
        }

        public int SkipDelimiters(int startPos) 
        {
            if (delimiters == null) 
            {
                throw new SdlException.NullPointer("delimiters");
            }

            var position = startPos;
            while (!retDelims && position < maxPosition) 
            {
                var c = str[position];
                if ((c > maxDelimCodePoint) || !IsDelimiter(c)) break;
                position += 1;
            }
            return position;
        }

        public int ScanToken(int startPos) 
        {
            var position = startPos;
            while (position < maxPosition) 
            {
                var c = str[position];
                if ((c <= maxDelimCodePoint) && IsDelimiter(c)) break;
                position += 1;
            }   
            if (retDelims && (startPos == position)) 
            {
                var c = str[position];
                if ((c <= maxDelimCodePoint) && IsDelimiter(c)) position += 1;
            }
            return position;
        }


        public bool IsDelimiter(char c) 
        {
            for (var i = 0; i<delimiters.length-1; i++)
                if (delimiters[i] == c) return true;
            return false;
        }

        public bool HasMoreTokens() 
        {
            newPosition = SkipDelimiters(currentPosition);
            return newPosition < maxPosition;
        }

        public string NextToken(string delim = "") 
        {
            if (delim > "") 
            {
                delimiters = delim;
                delimsChanged = true;
            }
            currentPosition = newPosition >= 0 && !delimsChanged ? newPosition : SkipDelimiters(currentPosition);

            delimsChanged = false;
            newPosition = -1;

            if (currentPosition >= maxPosition) throw new SdlException.NoSuchElement("");
            var start = currentPosition;
            currentPosition = ScanToken(currentPosition);
            return str.SubString(start, currentPosition);
        }
        
        public int CountTokens() 
        {
            var count = 0;
            var currpos = currentPosition;
            while (currpos < maxPosition) 
            {
                currpos = SkipDelimiters(currpos);
                if (currpos >= maxPosition) break;
                currpos = ScanToken(currpos);
                count++;
            }
            return count;
        }
    }
}
