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

    [Immutable]
    public struct ClsId
    {
        public uint64 data0;
        public uint64 data1;
        public ClsId()
        {
            data0 = 0;
            data1 = 0;
            uint64 d0 = MersenneTwister.GenrandInt32();
            uint64 d1 = MersenneTwister.GenrandInt32();
            uint64 d2 = MersenneTwister.GenrandInt32();
            uint64 d3 = MersenneTwister.GenrandInt32();

            // (a) set the high nibble of the 7th byte equal to 4 and
            // (b) set the two most significant bits of the 9th byte to 10'B,
            d1 = d1 & 0xffff0fff | 0x00004000;
            d2 = d2 & 0x3fffffff | 0x80000000;
            data0 = d0 << 32 | d1;
            data1 = d2 << 32 | d3;
            
            //  abData[6] = (byte)(0x40 | ((int)abData[6] & 0xf));
            //  abData[8] = (byte)(0x80 | ((int)abData[8] & 0x3f));

        }
        public bool Equals(ClsId other)
        {
            return data0 == other.data0 &&
                    data1 == other.data1;
        }
    }

	[SimpleType, Immutable]
    public struct Guid
    {
        public uint32 data0;
        public uint16 data1;  
        public uint16 data2;  
        public uint16 data3;  
        public uint64 data4;  

        public bool Equals(Guid other)
        {
            return data0 == other.data0 &&
                    data1 == other.data1 &&
                    data2 == other.data2 &&
                    data3 == other.data3 &&
                    data4 == other.data4;
        }
    }
    public static string[] hex;
    
    public static void InitHex()
    {
        hex = { // hex identity values 0-255
            "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "0a", "0b", "0c", "0d", "0e", "0f",
            "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "1a", "1b", "1c", "1d", "1e", "1f",
            "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "2a", "2b", "2c", "2d", "2e", "2f",
            "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "3a", "3b", "3c", "3d", "3e", "3f",
            "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "4a", "4b", "4c", "4d", "4e", "4f",
            "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "5a", "5b", "5c", "5d", "5e", "5f",
            "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "6a", "6b", "6c", "6d", "6e", "6f",
            "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "7a", "7b", "7c", "7d", "7e", "7f",
            "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "8a", "8b", "8c", "8d", "8e", "8f",
            "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "9a", "9b", "9c", "9d", "9e", "9f",
            "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "aa", "ab", "ac", "ad", "ae", "af",
            "b0", "b1", "b2", "b3", "b4", "b5", "b6", "b7", "b8", "b9", "ba", "bb", "bc", "bd", "be", "bf",
            "c0", "c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "c9", "ca", "cb", "cc", "cd", "ce", "cf",
            "d0", "d1", "d2", "d3", "d4", "d5", "d6", "d7", "d8", "d9", "da", "db", "dc", "dd", "de", "df",
            "e0", "e1", "e2", "e3", "e4", "e5", "e6", "e7", "e8", "e9", "ea", "eb", "ec", "ed", "ee", "ef",
            "f0", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "fa", "fb", "fc", "fd", "fe", "ff"
        };
    }

    public static string GenerateUUID() {


        if (hex == null) InitHex();
        var d0 = MersenneTwister.GenrandInt32();
        var d1 = MersenneTwister.GenrandInt32();
        var d2 = MersenneTwister.GenrandInt32();
        var d3 = MersenneTwister.GenrandInt32();
        
        var hex00 = d0 & 0xff;
        var hex01 = d0 >> 8 & 0xff;
        var hex02 = d0 >> 16 & 0xff;
        var hex03 = d0 >> 24 & 0xff;

        var hex04 = d1 & 0xff;
        var hex05 = d1 >> 8 & 0xff;
        var hex06 = d1 >> 16 & 0x0f | 0x40;
        var hex07 = d1 >> 24 & 0xff;

        var hex08 = d2 & 0x3f | 0x80;
        var hex09 = d2 >> 8 & 0xff;
        var hex10 = d2 >> 16 & 0xff;
        var hex11 = d2 >> 24 & 0xff;

        var hex12 = d3 & 0xff;
        var hex13 = d3 >> 8 & 0xff;
        var hex14 = d3 >> 16 & 0xff;
        var hex15 = d3 >> 24 & 0xff;

        var sb = new StringBuilder();

        sb.Append(hex[hex00]);
        sb.Append(hex[hex01]);
        sb.Append(hex[hex02]);
        sb.Append(hex[hex03]);
        sb.Append("-");
        sb.Append(hex[hex04]);
        sb.Append(hex[hex05]);
        sb.Append("-");
        sb.Append(hex[hex06]);
        sb.Append(hex[hex07]);
        sb.Append("-");
        sb.Append(hex[hex08]);
        sb.Append(hex[hex09]);
        sb.Append("-");
        sb.Append(hex[hex10]);
        sb.Append(hex[hex11]);
        sb.Append(hex[hex12]);
        sb.Append(hex[hex13]);
        sb.Append(hex[hex14]);
        sb.Append(hex[hex15]);

        return sb.str;

    }

    
}