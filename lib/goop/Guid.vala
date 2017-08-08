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
 * Guid Exceptions
 */
 public errordomain GuidException
{
	/**
	 * Thrown when a guid string containes fewer than 32 digits 
	 */
	StringTooShort,
	/**
	 * Thrown when a guid string containes an invalid digit 
	 */
	InvalidHexDigit
}
 
/** 
 * Globally Unique Identifier 
 * 
 * holds 128 bit guid data
 */
[SimpleType, Immutable]
public struct Guid 
{
	public uint32 data1;
	public uint16 data2; 
	public uint16 data3; 
	public uint8 data4[8];

	/**
	 * String representation of a Guid, 
	 * formatted as "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
	 */
	public string ToString()
	{
		return "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x".printf(data1, data2, data3, 
			data4[0], data4[1], data4[2], data4[3], data4[4], data4[5], data4[6], data4[7]);
	}

	/**
	 * Generate a new binary guid
	 */
	public static string Generate()
	{
        var d0 = MersenneTwister.GenrandInt32();
        var d1 = MersenneTwister.GenrandInt32();
        var d2 = MersenneTwister.GenrandInt32();
		var d3 = MersenneTwister.GenrandInt32();
		d1 = d1 & 0xffff0fff | 0x00004000;
		d2 = d2 & 0x3fffffff | 0x80000000;

		return Guid() {
			data1 = (uint32)d0,
			data2 = (uint16)(d1 >> 16),
			data3 = (uint16)(d1 & 0x0000ffff),
			data4 = {
				(uint8)((d2 & 0xff000000) >> 24),
				(uint8)((d2 & 0x00ff0000) >> 16),
				(uint8)((d2 & 0x0000ff00) >> 8),
				(uint8)(d2 & 0x000000ff),
				(uint8)((d3 & 0xff000000) >> 24),
				(uint8)((d3 & 0x00ff0000) >> 16),
				(uint8)((d3 & 0x0000ff00) >> 8),
				(uint8)(d3 & 0x000000ff)
			}
		}.ToString();
	}

	/**
	 * Generate a binary guid by 
	 * parsing a Guid string "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
	 */
	public static Guid Parse(string v4)
	{
		var s = string.Joinv("", v4.Split("-"));
		if (s.length != 32)
			throw new GuidException.StringTooShort(v4);
		
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
				throw new GuidException.InvalidHexDigit(v4);
			p++;

			if (b[p] >= '0' && b[p] <= '9')
				res[i] = res[i]*16+b[p]-'0';
			else if (b[p] >= 'a' && b[p] <= 'f')
				res[i] = res[i]*16+b[p]-'a'+10;
			else if (b[p] >= 'A' && b[p] <= 'F')
				res[i] = res[i]*16+b[p]-'A'+10;
			else
				throw new GuidException.InvalidHexDigit(v4);
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

		return Guid() { data1 = d1, data2 = d2, data3 = d3, 
			data4 = { res[8], res[9], res[10], res[11], res[12], res[13], res[14], res[15] } 
		};
	}
}
