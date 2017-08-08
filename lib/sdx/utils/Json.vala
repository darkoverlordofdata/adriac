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
namespace Sdx.Utils 
{

    /**
     * Simple Json Parser
     * 
     * based on JSON.parse
     * 
     * by [[Crockford]] [[https://github.com/douglascrockford/JSON-js]]
     */
    public errordomain JsonException 
    {
        SyntaxError,
        UnexpectedCharacter,
        InvalidString,
        InvalidArray,
        InvalidObject,
        DuplicateKey
    }

    public enum JsType 
    {
        JS_INVALID,
        JS_BOOLEAN,
        JS_NUMBER,
        JS_STRING,
        JS_OBJECT,
        JS_ARRAY
    }

    public delegate JsVariant JsDelegate(JsVariant holder, string key, JsVariant value);

    public class Json : Object 
    {

        public static const string HEX_DIGIT = "0123456789abcdef";
        public static const string escape0 = "\"\\/bfnrt";
        public static const string[] escape1 = {"\"", "\\", "/", "\b", "\f", "\n", "\r", "\t"};
        public static string gap;
        public static string indent;
        
        private int at;
        private char ch;
        private string text;
        private JsDelegate Replacer;


        public Json(JsDelegate Replacer = null) 
        {
            this.Replacer = Replacer;
        }

        public static JsVariant Parse(string source) 
        {
            return new Json().ParseJson(source);
        }

        public static string Stringify(JsVariant value, JsDelegate Replacer = null, string space = "") 
        {
            // The stringify method takes a value and an optional Replacer, and an optional
            // space parameter, and returns a JSON text. The Replacer can be a function
            // that can replace values, or an array of strings that will select the keys.
            // A default Replacer method can be provided. Use of the space parameter can
            // produce text that is more easily readable.

            gap = "";
            indent = space;

            var holder = new JsVariant(JsType.JS_OBJECT);
            holder.object.Set("", value);
            return new Json(Replacer).Str("", holder);
        }

        public string Quote(string str) 
        {
            return "\"" + str + "\"";
        }

        public JsVariant GetItem(JsVariant holder, string key) 
        {
            switch (holder.type) 
            {
                case JsType.JS_ARRAY:
                    return holder.array.Item(int.Parse(key)).data;
                case JsType.JS_OBJECT:
                    return holder.object.Get(key);
                default:
                    return null;
            }
        }
        public string Str(string key, JsVariant holder) 
        {
            // Produce a string from holder[key].

            var length = 0;
            var mind = gap;
            JsVariant value = GetItem(holder, key);

            if (Replacer != null) 
            {
                value = Replacer(holder, key, value);
            }

            switch (value.type) 
            {

                case JsType.JS_STRING:
                    return Quote(value.string);

                case JsType.JS_NUMBER:
                    return value.number.ToString(); 

                case JsType.JS_BOOLEAN:
                    return value.boolean.ToString();

                case JsType.JS_OBJECT:
                    if (value.object == null) return "null";
                    gap += indent;
                    length = (int)value.object.Size();
                    var partial = new string[length];

                    // iterate through all of the keys in the object.
                    var keys = value.object.GetKeysAsArray();
                    for (var i = 0; i < keys.length; i++) 
                    {
                        var k = keys[i];
                        partial[i] = Quote(k) + (gap.length>0 ? ": " : ":") + Str(k, value);
                    }
                    // Join all of the member texts together, separated with commas,
                    // and wrap them in braces.
                    var v = "";
                    if (partial.length == 0) 
                    {
                        v =  "{}";
                    } 
                    else if (gap.length > 0) 
                    {
                        v = "{\n" + gap + string.Joinv(",\n" + gap, partial) + "\n" + mind + "}";
                    } 
                    else 
                    {
                        v = "{" + string.Joinv(",", partial) + "}";
                    }
                    gap = mind;
                    return v;
                    

                case JsType.JS_ARRAY:
                    if (value.array == null) return "null";
                    gap += indent;
                    
                    // The value is an array. Stringify every element                    
                    length = (int)value.array.Length();
                    var partial = new string[length];
                    for (var i = 0; i < length; i++) 
                    {
                        partial[i] = Str(i.ToString(), value);
                    }
                    // Join all of the elements together, separated with commas, and wrap them in
                    // brackets.

                    var v = "";
                    if (partial.length == 0) 
                    {
                        v =  "[]";
                    } 
                    else if (gap.length > 0) 
                    {
                        v = "[\n" + gap + string.Joinv(",\n" + gap, partial) + "\n" + mind + "]";
                    } 
                    else 
                    {
                        v = "[" + string.Joinv(",", partial) + "]";
                    }
                    gap = mind;
                    return v;
            }
            return "";
        }

        public JsVariant ParseJson(string source) 
        {

            text = source;
            at = 0;
            ch = ' ';
            var result = GetValue();
            SkipWhite();
            if (ch != 0) 
            {
                throw new JsonException.SyntaxError("");
            }
            return result;
        }

        public char Next(char? c=null) 
        {
            // If a c parameter is provided, verify that it matches the current character.
            if (c != null && c != ch) 
            {
                throw new JsonException.UnexpectedCharacter("Expected '%s' instead of '%s'", c.ToString(), ch.ToString());
            }
            // Get the next character. When there are no more characters,
            // return the empty string.
            ch = text[at];
            at += 1;
            return ch;
        }

        public JsVariant GetValue() 
        {

            // Parse a JSON value. It could be an object, an array, a string, a number,
            // or a word.

            SkipWhite();
            switch (ch) 
            {
                case '{':
                    return GetObject();
                case '[':
                    return GetArray();
                case '\"':
                    return GetString();
                case '-':
                    return GetNumber();
                default:
                    return (ch >= '0' && ch <= '9')
                        ? GetNumber()
                        : GetWord();
            }
        }

        public JsVariant GetNumber() 
        {
            // Parse a number value.
            var string = "";

            if (ch == '-') 
            {
                string = "-";
                Next('-');
            }

            while (ch >= '0' && ch <= '9') 
            {
                string += ch.ToString();
                Next();
            }
            if (ch == '.') 
            {
                string += ".";
                while (Next() != 0 && ch >= '0' && ch <= '9') 
                {
                    string += ch.ToString();
                }
            }
            if (ch == 'e' || ch == 'E') 
            {
                string += ch.ToString();
                Next();
                if (ch == '-' || ch == '+') 
                {
                    string += ch.ToString();
                    Next();
                }
                while (ch >= '0' && ch <= '9') 
                {
                    string += ch.ToString();
                    Next();
                }
            }
            return JsVariant.Number((double)double.Parse(string));
        }

        public JsVariant GetString() 
        {
            // Parse a string value.
            var hex = 0;
            var i = 0;
            var string = "";
            var uffff = 0;
            // When parsing for string values, we must look for " and \ characters.

            if (ch == '\"') 
            {
                while (Next() != 0) 
                {
                    if (ch == '\"') 
                    {
                        Next();
                        return JsVariant.String(string);
                    }
                    if (ch == '\\') 
                    {
                        Next();
                        if (ch == 'u') 
                        {
                            uffff = 0;
                            for (i = 0; i < 4; i += 1) 
                            {
                                hex = HEX_DIGIT.IndexOf(Next().ToString().down());
                                if (hex < 0) break;
                                uffff = uffff * 16 + hex;
                            }
                            string += ((char)uffff).ToString();
                        } 
                        else if ((i = escape0.IndexOf(ch.ToString())) >= 0) 
                        {
                            string += escape1[i];
                        } else 
                        {
                            break;
                        }
                    } 
                    else 
                    {
                        string += ch.ToString();
                    }
                }
            }
            throw new JsonException.InvalidString("");
        }


        public void SkipWhite() 
        {

            // Skip whitespace.

            while (ch != 0 && ch <= ' ') 
            {
                Next();
            }
        }

        public JsVariant GetWord() 
        {

            switch (ch) 
            {
                case 't':
                    Next('t');
                    Next('r');
                    Next('u');
                    Next('e');
                    return JsVariant.Boolean(true);
                case 'f':
                    Next('f');
                    Next('a');
                    Next('l');
                    Next('s');
                    Next('e');
                    return JsVariant.Boolean(false);
                case 'n':
                    Next('n');
                    Next('u');
                    Next('l');
                    Next('l');
                    return new JsVariant(JsType.JS_OBJECT, true);
            }
            throw new JsonException.UnexpectedCharacter("Unexpected '%s'", ch.ToString());

        }

        public JsVariant GetArray() 
        {
            // Parse an array value.
            var result = new JsVariant(JsType.JS_ARRAY);

            if (ch == '[') 
            {
                Next('[');
                SkipWhite();
                if (ch == ']') 
                {
                    Next(']');
                    return result;
                }
                while (ch != 0) 
                {
                    result.array.Add(GetValue());
                    SkipWhite();
                    if (ch == ']') 
                    {
                        Next(']');
                        return result;
                    }
                    Next(',');
                    SkipWhite();
                }
            }
            throw new JsonException.InvalidArray("");
        }

        public JsVariant GetObject() 
        {
            // Parse an object value.
            var key = "";
            var result = new JsVariant(JsType.JS_OBJECT);

            if (ch == '{') 
            {
                Next('{');
                SkipWhite();
                if (ch == '}') 
                {
                    Next('}');
                    return result;
                }
                while (ch != 0) 
                {
                    key = GetString().string;
                    SkipWhite();
                    Next(':');
                    if (result.object.Contains(key)) 
                    {
                        throw new JsonException.DuplicateKey("");
                    }
                    result.object.Set(key, GetValue());
                    SkipWhite();
                    if (ch == '}') 
                    {
                        Next('}');
                        return result;
                    }
                    Next(',');
                    SkipWhite();
                }
            }
            throw new JsonException.InvalidObject("");

        }

    }
    /**
     * Wrap a Json object
     * 
     * Arrays are represented as List<JsVariant>
     * Objects are represented as HashTable<string, JsVariant>
     */
    public class JsVariant : Object 
    {

        public bool boolean;
        public double number;
        public string string;
        public HashTable<string, JsVariant> object;
        public List<JsVariant> array;

        public JsType type;

        public static JsVariant String(string value) 
        {
            var it = new JsVariant(JsType.JS_STRING);
            it.string = value;
            return it;
        }

        public static JsVariant Number(double value) 
        {
            var it = new JsVariant(JsType.JS_NUMBER);
            it.number = value;
            return it;
        }
        public static JsVariant Boolean(bool value) 
        {
            var it = new JsVariant(JsType.JS_BOOLEAN);
            it.boolean = value;
            return it;
        }

        public JsVariant(JsType type, bool isNull = false) 
        {
            this.type = type;
            switch (type) 
            {
                case JsType.JS_BOOLEAN:
                    boolean = false;
                    break;
                case JsType.JS_NUMBER:
                    number = 0;
                    break;
                case JsType.JS_STRING:
                    string = "";
                    break;
                case JsType.JS_OBJECT:
                    object = isNull ? null : new HashTable<string, JsVariant>(str_hash, str_equal);
                    break;
                case JsType.JS_ARRAY:
                    array = new List<JsVariant>();
                    break;
                    
                default:
                    break;
            }
        }

        public JsVariant At(int index) 
        {
            return array.Head.data;
        }

        public JsVariant Member(string key) 
        {
            return object.Get(key);
        }
    }   
}

