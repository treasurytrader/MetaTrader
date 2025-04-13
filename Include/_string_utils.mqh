
// https://www.mql5.com/en/code/35395
//+------------------------------------------------------------------+
//|                                                  StringUtils.mqh |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "1.800"
#property description "A collection of string manipulation functions."

#ifdef __MQL4__
#property strict
#endif


#ifndef STRING_UNIQUE_HEADER_ID_H
#define STRING_UNIQUE_HEADER_ID_H


//+------------------------------------------------------------------+
//| StringUtils.mqh                                                  |
//+------------------------------------------------------------------+

//--- additions to MQL's native string functions:

//   StringAppendIfMissing
//   StringCharAt
//   StringCharCodeAt
//   StringChunk
//   StringChunkRight
//   StringContains
//   StringCountMatches
//   StringEndsWith
//   StringGenerateRandom
//   StringIndexOf
//   StringInsert
//   StringIsNullOrEmpty
//   StringIsNumeric
//   StringJoin
//   StringLastIndexOf
//   StringLeft
//   StringPad
//   StringPadEnd
//   StringPadStart
//   StringPrependIfMissing
//   StringRemove
//   StringRemoveEnd
//   StringRemoveStart
//   StringRepeat
//   StringReplace2
//   StringReplaceBetween
//   StringReverse
//   StringRight
//   StringShuffle
//   StringSplit
//   StringSplitTrim
//   StringStartsWith
//   StringSubstrAfter
//   StringSubstrAfterLast
//   StringSubstrBefore
//   StringSubstrBeforeLast
//   StringSubstrBetween
//   StringToLowerCase
//   StringToUpperCase
//   StringTrim
//   StringTrimEnd
//   StringTrimStart
//   DQuoteStr
//   StrHashCode
//   Base64Encode
//   Base64Decode
//   UTF8GetBytes
//   UTF8GetString
//   UnicodeGetBytes
//   UnicodeGetString

//+------------------------------------------------------------------+
//| StringAppendIfMissing.                                           |
//+------------------------------------------------------------------+
/**
* Appends the suffix to the end of the string if the string does not
* already end with the suffix, otherwise returns the same string.
* Example:
*      StringAppendIfMissing("dir", "\\");    // "dir\"
*      StringAppendIfMissing("dir\\", "\\");  // "dir\"
*/
string StringAppendIfMissing(string sourceStr, string suffix)
  {
   if(StringIsNullOrEmpty(sourceStr)
      || StringIsNullOrEmpty(suffix)
      || StringEndsWith(sourceStr, suffix))
     {
      return sourceStr;
     }
   return sourceStr + suffix;
  }
//+------------------------------------------------------------------+
//| StringCharAt.                                                    |
//+------------------------------------------------------------------+
/**
* Returns the character at the specified index in a string.
* The function returns an empty string, in case of an error.
* Example:
*      StringCharAt("Apple",4);  // "e"
*/
string StringCharAt(string sourceStr, int index)
  {
   if(index < 0 || index >= StringLen(sourceStr))
     {
      return "";
     }
   return StringSubstr(sourceStr, index, 1);
  }
//+------------------------------------------------------------------+
//| StringCharCodeAt.                                                |
//+------------------------------------------------------------------+
/**
* Returns a short integer between 0 and 65535 representing the UTF-16
* code unit at the given index.
* The function returns 0, in case of an error.
* Example:
*      StringCharCodeAt("Apple", 4);  // 101
*/
ushort StringCharCodeAt(string sourceStr, int index)
  {
   if(index < 0 || index >= StringLen(sourceStr))
     {
      return 0;
     }
// return sourceStr[index];
   return StringGetCharacter(sourceStr, index);
  }
//+------------------------------------------------------------------+
//| StringChunk.                                                     |
//+------------------------------------------------------------------+
/**
* Split a string into evenly sized chunks of the specified length.
* limit [optional].
*      Specifies the max number of chunks to be placed into the array.
* Return value is the number of chunks in the resulting array.
* Example:
*      string parts[];
*      StringChunk("1234567890", 3, parts);  // 4
*      ArrayPrint(parts);                    // "123" "456" "789" "0"
*/
int StringChunk(string sourceStr, int length, string &result[], int limit = 0)
  {
   if(StringIsNullOrEmpty(sourceStr) || length < 1)
     {
      ArrayFree(result);
      return 0;
     }
   int n = 0;
   int size = StringLen(sourceStr);
   for(int pos = 0; pos < size; pos += length)
     {
      ArrayResize(result, ++n, size);
      result[n - 1] = StringSubstr(sourceStr, pos, length);
      if(n == limit)
         break;
     }
   return n;
  }
//+------------------------------------------------------------------+
//| StringChunkRight.                                                |
//+------------------------------------------------------------------+
/**
* Split a string into evenly sized chunks of the specified length,
* starting the split at the end of the string.
* limit [optional].
*      Specifies the max number of chunks to be placed into the array.
* Return value is the number of chunks in the resulting array.
* Example:
*      string parts[];
*      StringChunkRight("1234567890", 3, parts);  // 4
*      ArrayPrint(parts);                         // "890" "567" "234" "1"
*/
int StringChunkRight(string sourceStr, int length, string &result[], int limit = 0)
  {
   if(StringIsNullOrEmpty(sourceStr) || length < 1)
     {
      ArrayFree(result);
      return 0;
     }
   int n = 0;
   int size = StringLen(sourceStr);
   for(int pos = size; pos > 0; pos -= length)
     {
      ArrayResize(result, ++n, size);
      result[n - 1] = StringSubstr(sourceStr, MathMax(pos - length, 0), MathMin(length, pos));
      if(n == limit)
         return n;
     }
   return n;
  }
//+------------------------------------------------------------------+
//| StringContains.                                                  |
//+------------------------------------------------------------------+
/**
* Determines whether this string contains the specified substring.
* startIndex [optional].
*      The position in this string at which to begin searching for substr.
*      Defaults to 0.
* Example:
*      StringContains("life_is_good", "is");  // true
*/
bool StringContains(string sourceStr, string searchStr, int startIndex = 0)
  {
   return StringFind(sourceStr, searchStr, startIndex) != -1;
  }
//+------------------------------------------------------------------+
//| StringCountMatches.                                              |
//+------------------------------------------------------------------+
/**
* Counts the number of all occurrences of the specified string in
* the input string using case-sensitive search.
* Example:
*      string str = "Mr Blue has a blue house and a blue car";
*      Print( StringCountMatches(str, "blue") );  // 2
*/
int StringCountMatches(string sourceStr, string searchStr)
  {
// return StringReplace(sourceStr, searchStr, "");
   int count = 0;
   int pos = 0;
   while((pos = StringFind(sourceStr, searchStr, pos)) != -1)
     {
      count++;
      pos += StringLen(searchStr);
     }
   return count;
  }
//+------------------------------------------------------------------+
//| StringEndsWith.                                                  |
//+------------------------------------------------------------------+
/**
* Determines whether this string ends with the specified suffix.
* length [optional].
*      If provided, it is used as the length of sourceStr.
*      Defaults to sourceStr actual length .
* Example:
*      StringEndsWith("life_is_good", "good");   // true
*      StringEndsWith("life_is_good", "is", 7);  // true
*/
bool StringEndsWith(string sourceStr, string suffix, int length = -1)
  {
   if(length < 0 || length > StringLen(sourceStr))
     {
      length = StringLen(sourceStr);
     }
   int position = length - StringLen(suffix);
   return position >= 0 && StringStartsWith(sourceStr, suffix, position);
  }
//+------------------------------------------------------------------+
//| StringGenerateRandom.                                            |
//+------------------------------------------------------------------+
/**
* Generates a random string with a desired length from ascii characters.
* Example:
*      StringGenerateRandom(12);  // "YvDpF50uvOAq"
*/
string StringGenerateRandom(int length)
  {
   string str_result = "";
   const string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
   for(int i = 0; i < length; i++)
     {
      int rand_pos = MathRand() % 64;
      str_result += StringSubstr(alphabet, rand_pos, 1);
     }
   return (str_result);
  }
//+------------------------------------------------------------------+
//| StringIndexOf.                                                   |
//+------------------------------------------------------------------+
/**
* Returns the index within this string of the first occurrence of the
* specified substring, starting the search at the specified index, or
* at the beginning if no 'fromIndex' is specified.
* The function returns -1, if the substring is not found.
* Example:
*      StringIndexOf("Morning", "n");  // 3
*/
int StringIndexOf(string sourceStr, string searchStr, int fromIndex = 0)
  {
   return StringFind(sourceStr, searchStr, fromIndex);
  }
//+------------------------------------------------------------------+
//| StringInsert.                                                    |
//+------------------------------------------------------------------+
/**
* Returns a new string in which a specified substring is inserted at
* a specified index position in this string.
* The source string is not modified (i.e., immutable).
* Example:
*      StringInsert("012345", "xxx", 3);  // "012xxx345"
*/
string StringInsert(string sourceStr, string substr, int index)
  {
   if(index < 0 || index > StringLen(sourceStr))
     {
      return sourceStr;
     }
   return StringSubstr(sourceStr, 0, index) + substr + StringSubstr(sourceStr, index);
  }
//+------------------------------------------------------------------+
//| StringIsNullOrEmpty.                                             |
//+------------------------------------------------------------------+
/**
* Indicates whether the specified string is NULL or an empty string ("").
* Example:
*      StringIsNullOrEmpty(NULL);  // true
*      StringIsNullOrEmpty("");    // true
*/
bool StringIsNullOrEmpty(string sourceStr)
  {
   return StringLen(sourceStr) == 0;
  }
//+------------------------------------------------------------------+
//| StringIsNumeric.                                                 |
//+------------------------------------------------------------------+
/**
* Determines whether the input string consists only of decimal digits.
* Example:
*      StringIsNumeric("12345");  // true
*      StringIsNumeric("3.142");  // true
*/
bool StringIsNumeric(string sourceStr)
  {
   if(StringIsNullOrEmpty(sourceStr))
     {
      return false;
     }
   int dot = 0;
   int strLen = StringLen(sourceStr);
   for(int i = 0; i < strLen; i++)
     {
      ushort c = StringGetCharacter(sourceStr, i);
      if (c == '.')
        {
         dot++;
        }
      else if(c < '0' || c > '9')
        {
         return false;
        }
     }
   return dot <= 1;
  }
//+------------------------------------------------------------------+
//| StringJoin.                                                      |
//+------------------------------------------------------------------+
/**
* Returns the result string, formed by joining of string parameters
* using a specified separator.
*
*  separator
*  [in]  String to separate each pair of adjacent parameters. If separator is an
*         empty string, all elements are joined without any characters in between them.
*  argumentN
*   [in]  Any comma separated string values. From 2 to 12 parameters of string type.
*
* Example:
*      StringJoin("-", "Java", "is", "cool");  // "Java-is-cool"
*/
string  StringJoin(
   string separator,
   string s1,
   string s2,
   string s3 = "",
   string s4 = "",
   string s5 = "",
   string s6 = "",
   string s7 = "",
   string s8 = "",
   string s9 = "",
   string s10 = "",
   string s11 = "",
   string s12 = ""
)
  {
   string str = "";
   StringConcatenate(str, s1, separator, s2);
//---
   if(StringLen(s3) > 0)
      StringAdd(str, separator + s3);
   if(StringLen(s4) > 0)
      StringAdd(str, separator + s4);
   if(StringLen(s5) > 0)
      StringAdd(str, separator + s5);
   if(StringLen(s6) > 0)
      StringAdd(str, separator + s6);
   if(StringLen(s7) > 0)
      StringAdd(str, separator + s7);
   if(StringLen(s8) > 0)
      StringAdd(str, separator + s8);
   if(StringLen(s9) > 0)
      StringAdd(str, separator + s9);
   if(StringLen(s10) > 0)
      StringAdd(str, separator + s10);
   if(StringLen(s11) > 0)
      StringAdd(str, separator + s11);
   if(StringLen(s12) > 0)
      StringAdd(str, separator + s12);
//---
   return (str);
  }
//+------------------------------------------------------------------+
//| StringLastIndexOf.                                               |
//+------------------------------------------------------------------+
/**
* Returns the index within this string of the last occurrence of the
* specified substring, searching backward starting at the specified
* index, or at the end if no 'fromIndex' is specified.
* The function returns -1, if the substring is not found.
* Example:
*      StringLastIndexOf("Morning", "n");  // 5
*/
int StringLastIndexOf(string sourceStr, string searchStr, int fromIndex = -1)
  {
   int sourceLen = StringLen(sourceStr);
   int searchLen = StringLen(searchStr);
   int rightIndex = sourceLen - searchLen;
   if(fromIndex < 0 || fromIndex > rightIndex)
     {
      fromIndex = rightIndex;
     }
   if(fromIndex < 0)
     {
      return -1;
     }

   for(int i = fromIndex; i >= 0; i--)
     {
      if(StringSubstr(sourceStr, i, searchLen) == searchStr)
        {
         return i;
        }
     }
   return -1;
  }
//+------------------------------------------------------------------+
//| StringLeft.                                                      |
//+------------------------------------------------------------------+
/**
* Extracts the leftmost 'length' characters of a string.
* length [optional].
*      The length of the required characters to return.
*      Defaults to 1.
* Example:
*      StringLeft("helicopter");  // "h"
*      StringLeft("vehicle", 2);  // "ve"
*      StringLeft("car", 5);      // "car"
*/
string StringLeft(string sourceStr, int length = 1)
  {
   if(length <= 0)
     {
      return "";
     }
   if(length >= StringLen(sourceStr))
     {
      return sourceStr;
     }
   return StringSubstr(sourceStr, 0, length);
  }
//+------------------------------------------------------------------+
//| StringPad.                                                       |
//+------------------------------------------------------------------+
/**
* Returns a new string of a specified length in which the input
* string is centered by padding with a specified character.
* The default value for padChar is ' '.
* The source string is not modified (i.e., immutable).
* Example:
*      StringPad("MQL5 is awesome", 21, '*');  // "***MQL5 is awesome***"
*/
string StringPad(string sourceStr, int targetWidth, ushort padChar = ' ')
  {
   int pads = targetWidth - StringLen(sourceStr);
   int front = pads / 2;
   int back = (pads + 1) / 2;
   return StringRepeat(padChar, front) + sourceStr + StringRepeat(padChar, back);
  }
//+------------------------------------------------------------------+
//| StringPadEnd.                                                    |
//+------------------------------------------------------------------+
/**
* Returns a new string of a specified length in which the end of the
* input string is padded with a specified character.
* The default value for padChar is ' '.
* The source string is not modified (i.e., immutable).
* Example:
*      StringPadEnd("USD", 5);       // "USD  "
*      StringPadEnd("1.3", 5, '0');  // "1.300"
*
* Note: to right pad with just white-space:
*      StringFormat("%-*s", width, sourceStr);
*/
string StringPadEnd(string sourceStr, int targetWidth, ushort padChar = ' ')
  {
   return sourceStr + StringRepeat(padChar, targetWidth - StringLen(sourceStr));
  }
//+------------------------------------------------------------------+
//| StringPadStart.                                                  |
//+------------------------------------------------------------------+
/**
* Returns a new string of a specified length in which the beginning
* of the input string is padded with a specified character.
* The default value for padChar is ' '.
* The source string is not modified (i.e., immutable).
* Example:
*      StringPadStart("USD", 5);        // "  USD"
*      StringPadStart("123", 5, '0');   // "00123"
*      StringPadStart("8803", 16, '*'); // "************8803"
*
* Note: to left pad with just white-space:
*      StringFormat("%*s", width, sourceStr);
*
* Note: for accurate right justification of text, the font that is used for
* display should be monospaced like Courier, Courier New, or Lucida Console.
*/
string StringPadStart(string sourceStr, int targetWidth, ushort padChar = ' ')
  {
   return StringRepeat(padChar, targetWidth - StringLen(sourceStr)) + sourceStr;
  }
//+------------------------------------------------------------------+
//| StringPrependIfMissing.                                          |
//+------------------------------------------------------------------+
/**
* Prepends the prefix to the start of the string if the string does not
* already start with the prefix, otherwise returns the same string.
* Example:
*      StringPrependIfMissing("domain.com", "www.");      // "www.domain.com"
*      StringPrependIfMissing("www.domain.com", "www.");  // "www.domain.com"
*/
string StringPrependIfMissing(string sourceStr, string prefix)
  {
   if(StringIsNullOrEmpty(sourceStr)
      || StringIsNullOrEmpty(prefix)
      || StringStartsWith(sourceStr, prefix))
     {
      return sourceStr;
     }
   return prefix + sourceStr;
  }
//+------------------------------------------------------------------+
//| StringRemove.                                                    |
//+------------------------------------------------------------------+
/**
* Returns a new string in which all occurrences of a specified string
* in the input string are removed.
* The source string is not modified (i.e., immutable).
* Example:
*      string str = "Mr Blue has a blue house and a blue car";
*      Print( StringRemove(str, "blue ") );
*      // Mr Blue has a house and a car
*/
string StringRemove(string sourceStr, string remove)
  {
   if(StringIsNullOrEmpty(sourceStr) || StringIsNullOrEmpty(remove))
     {
      return sourceStr;
     }
   return StringReplace2(sourceStr, remove, "");
  }
//+------------------------------------------------------------------+
//| StringRemoveEnd.                                                 |
//+------------------------------------------------------------------+
/**
* Removes the specified suffix from the end of the string if the string
* already ends with the suffix, otherwise returns the same string.
* The source string is be modified (i.e., immutable).
* Example:
*      StringRemoveEnd("www.domain.com", ".com");  // "www.domain"
*/
string StringRemoveEnd(string sourceStr, string suffix)
  {
   if(StringIsNullOrEmpty(sourceStr)
      || StringIsNullOrEmpty(suffix)
      || !StringEndsWith(sourceStr, suffix))
     {
      return sourceStr;
     }
   return StringSubstr(sourceStr, 0, StringLen(sourceStr) - StringLen(suffix));
  }
//+------------------------------------------------------------------+
//| StringRemoveStart.                                               |
//+------------------------------------------------------------------+
/**
* Removes the specified prefix from the start of the string if the string
* already starts with the prefix, otherwise returns the same string.
* The source string is be modified (i.e., immutable).
* Example:
*      StringRemoveStart("www.domain.com", "www.");  // "domain.com"
*      StringRemoveStart("domain.com", "www.");      // "domain.com"
*/
string StringRemoveStart(string sourceStr, string prefix)
  {
   if(StringIsNullOrEmpty(sourceStr)
      || StringIsNullOrEmpty(prefix)
      || !StringStartsWith(sourceStr, prefix))
     {
      return sourceStr;
     }
   return StringSubstr(sourceStr, StringLen(prefix));
  }
//+------------------------------------------------------------------+
//| StringRepeat.                                                    |
//+------------------------------------------------------------------+
/**
* Returns a new string which contains the specified number of copies
* of the input string, concatenated together.
* Example:
*      StringRepeat("*", 5);  // "*****"
*/
string StringRepeat(string sourceStr, int count)
  {
   string result = "";
   for(int i = 0; i < count; i++)
     {
      result += sourceStr;
     }
   return result;
  }
//+------------------------------------------------------------------+
//| StringRepeat: overload for ushort parameter.                     |
//+------------------------------------------------------------------+
/**
* Returns a new string which contains the specified number of copies
* of the input character, concatenated together.
* Example:
*      StringRepeat('*', 5);  // "*****"
*/
string StringRepeat(ushort chr, int count)
  {
   string str = ShortToString(chr);
   return StringRepeat(str, count);
  }
//+------------------------------------------------------------------+
//| StringReplace2.                                                  |
//+------------------------------------------------------------------+
/**
* Returns a new string in which all occurrences of a specified string
* in the input string are replaced with another specified string.
* The source string is not modified (i.e., immutable).
* Example:
*      string str = "Mr Blue has a blue house and a blue car";
*      Print( StringReplace2(str, "blue", "red") );
*      // Mr Blue has a red house and a red car
*/
string StringReplace2(string sourceStr, string searchStr, string replacement)
  {
   StringReplace(sourceStr, searchStr, replacement);
   return (sourceStr);
  }
//+------------------------------------------------------------------+
//| StringReplaceBetween.                                            |
//+------------------------------------------------------------------+
/**
* Replaces the string that is nested in between two string tags.
* Only the first match is replaced.
* Example:
*      StringReplaceBetween("<a>foo</a>", "<a>", "</a>", "bar");  // "<a>bar</a>"
*/
string StringReplaceBetween(string sourceStr, string openTag, string closeTag, string replacement)
  {
   if(StringIsNullOrEmpty(sourceStr)
      || StringIsNullOrEmpty(openTag)
      || StringIsNullOrEmpty(closeTag))
     {
      return sourceStr;
     }
   int start = StringIndexOf(sourceStr, openTag);
   if(start != -1)
     {
      start += StringLen(openTag);
      int end = StringIndexOf(sourceStr, closeTag, start);
      if(end != -1)
        {
         return StringSubstr(sourceStr, 0, start) + replacement + StringSubstr(sourceStr, end);
        }
     }
   return sourceStr;
  }
//+------------------------------------------------------------------+
//| StringReverse.                                                   |
//+------------------------------------------------------------------+
/**
* Returns a copy of this string with all the characters reversed.
* The source string is not modified (i.e., immutable).
* Example:
*      StringReverse("012345");  // "543210"
*/
string StringReverse(string sourceStr)
  {
   ushort chars[];
   StringToShortArray(sourceStr, chars);
   ArrayReverse(chars, 0, StringLen(sourceStr));
   return ShortArrayToString(chars);
  }
//+------------------------------------------------------------------+
//| StringRight.                                                     |
//+------------------------------------------------------------------+
/**
* Extracts the rightmost 'length' characters of a string.
* length [optional].
*      The length of the required characters to return.
*      Defaults to 1.
* Example:
*      StringRight("helicopter");  // "r"
*      StringRight("vehicle", 2);  // "le"
*      StringRight("car", 5);      // "car"
*/
string StringRight(string sourceStr, int length = 1)
  {
   if(length <= 0)
     {
      return "";
     }
   if(length >= StringLen(sourceStr))
     {
      return sourceStr;
     }
   return StringSubstr(sourceStr, StringLen(sourceStr) - length, length);
  }
//+------------------------------------------------------------------+
//| StringShuffle.                                                   |
//+------------------------------------------------------------------+
/**
* Returns a copy of this string with all the characters shuffled.
* The source string is not modified (i.e., immutable).
* Example:
*      StringShuffle("012345");  // "514203"
*/
string StringShuffle(string sourceStr)
  {
   string str_result = "";
   int length = StringLen(sourceStr);
   if(!length)
      return sourceStr;
//--- prepare random indices array
   int indices[][2];
   ArrayResize(indices, length);
   for(int i = 0; i < length; i++)
     {
      indices[i][0] = MathRand();
      indices[i][1] = i;
     }
   ArraySort(indices);
   for(int i = 0; i < length; i++)
     {
      int rand_pos = indices[i][1];
      str_result += StringSubstr(sourceStr, rand_pos, 1);
     }
   return (str_result);
  }
//+------------------------------------------------------------------+
//| StringSplit(): overload for string separator.                    |
//+------------------------------------------------------------------+
/**
* Split a string into an array of substrings, using a specified separator string.
* limit [optional].
*      Specifies the max number of splits to be placed into the array.
* Return value is the number of splits in the resulting array.
* Example:
*      string parts[];
*      StringSplit("_life_is_good_", "_", parts);  // 5
*      ArrayPrint(parts);                          // ""     "life" "is"   "good" ""
*/
int StringSplit(string sourceStr, string separator, string &result[], int limit = 0)
  {
   if(StringIsNullOrEmpty(sourceStr))
     {
      ArrayFree(result);
      return 0;
     }
   int n = 0, start_pos = 0, pos = -1;
   while((pos = StringFind(sourceStr, separator, start_pos)) != -1)
     {
      ArrayResize(result, ++n, StringLen(sourceStr));
      result[n - 1] = StringSubstr(sourceStr, start_pos, pos - start_pos);
      if(n == limit)
         return n;
      start_pos = pos + StringLen(separator);
     }
//--- append the last part
   ArrayResize(result, ++n);
   result[n - 1] = StringSubstr(sourceStr, start_pos);
   return n;
  }
//+------------------------------------------------------------------+
//| StringSplitTrim.                                                 |
//+------------------------------------------------------------------+
/**
* Split a string into an array of substrings, using a specified separator
* string. Substrings that consist only of white-space characters are
* removed from the result.
* Example:
*      string Parts[];
*      StringSplitTrim("_life_is_good_", "_", Parts);  // 3
*      ArrayPrint(Parts);                              // "life" "is"   "good"
*/
int StringSplitTrim(string sourceStr, string separator, string &result[], int limit = 0)
  {
   int size = StringSplit(sourceStr, separator, result, limit);
//---
   if(size > 0)
     {
      string working[];
      ArrayCopy(working, result);
      size = 0;
      for(int i = 0; i < ArraySize(working); i++)
        {
         string trimmed = StringTrim(working[i]);
         if(StringIsNullOrEmpty(trimmed))
            continue;
         result[size++] = trimmed;
        }
      ArrayResize(result, size);
     }
//---
   return (size);
  }
//+------------------------------------------------------------------+
//| StringStartsWith.                                                |
//+------------------------------------------------------------------+
/**
* Determines whether this string starts with the specified prefix.
* position [optional].
*      The position in this string at which the prefix is checked.
*      Defaults to 0.
* Example:
*      StringStartsWith("life_is_good", "life");   // true
*      StringStartsWith("life_is_good", "is", 5);  // true
*/
bool StringStartsWith(string sourceStr, string prefix, int position = 0)
  {
   return StringSubstr(sourceStr, position, StringLen(prefix)) == prefix;
  }
//+------------------------------------------------------------------+
//| StringSubstrAfter.                                               |
//+------------------------------------------------------------------+
/**
* Gets the substring after the first occurrence of a separator.
* The separator is not returned.
* length [optional].
*      The length of the required characters to return.
*      Defaults to -1, which means length up to the end of the string.
* Example:
*      StringSubstrAfter("abcba", "b");     // "cba"
*      StringSubstrAfter("abcba", "b", 2);  // "cb"
*/
string StringSubstrAfter(string sourceStr, string separator, int length = -1)
  {
   if(StringIsNullOrEmpty(sourceStr)
      || StringIsNullOrEmpty(separator))
     {
      return NULL;
     }
   int pos = StringIndexOf(sourceStr, separator);
   if(pos != -1)
     {
      return StringSubstr(sourceStr, pos + StringLen(separator), length);
     }
   return NULL;
  }
//+------------------------------------------------------------------+
//| StringSubstrAfterLast.                                           |
//+------------------------------------------------------------------+
/**
* Gets the substring after the last occurrence of a separator.
* The separator is not returned.
* length [optional].
*      The length of the required characters to return.
*      Defaults to -1, which means length up to the end of the string.
* Example:
*      StringSubstrAfterLast("abcba", "b");  // "a"
*/
string StringSubstrAfterLast(string sourceStr, string separator, int length = -1)
  {
   if(StringIsNullOrEmpty(sourceStr)
      || StringIsNullOrEmpty(separator))
     {
      return NULL;
     }
   int pos = StringLastIndexOf(sourceStr, separator);
   if(pos != -1)
     {
      return StringSubstr(sourceStr, pos + StringLen(separator), length);
     }
   return NULL;
  }
//+------------------------------------------------------------------+
//| StringSubstrBefore.                                              |
//+------------------------------------------------------------------+
/**
* Gets the substring before the first occurrence of a separator.
* The separator is not returned.
* length [optional].
*      The length of the required characters to return.
*      Defaults to -1, which means length up to the beginning of the string.
* Example:
*      StringSubstrBefore("abcba", "b");  // "a"
*/
string StringSubstrBefore(string sourceStr, string separator, int length = -1)
  {
   if(StringIsNullOrEmpty(sourceStr)
      || StringIsNullOrEmpty(separator))
     {
      return NULL;
     }
   int pos = StringIndexOf(sourceStr, separator);
   if(pos != -1)
     {
      if(length < 0 || length > pos)
        {
         length = pos;
        }
      return StringSubstr(sourceStr, pos - length, length);
     }
   return NULL;
  }
//+------------------------------------------------------------------+
//| StringSubstrBeforeLast.                                          |
//+------------------------------------------------------------------+
/**
* Gets the substring before the last occurrence of a separator.
* The separator is not returned.
* length [optional].
*      The length of the required characters to return.
*      Defaults to -1, which means length up to the beginning of the string.
* Example:
*      StringSubstrBeforeLast("abcba", "b");     // "abc"
*      StringSubstrBeforeLast("abcba", "b", 2);  // "bc"
*/
string StringSubstrBeforeLast(string sourceStr, string separator, int length = -1)
  {
   if(StringIsNullOrEmpty(sourceStr)
      || StringIsNullOrEmpty(separator))
     {
      return NULL;
     }
   int pos = StringLastIndexOf(sourceStr, separator);
   if(pos != -1)
     {
      if(length < 0 || length > pos)
        {
         length = pos;
        }
      return StringSubstr(sourceStr, pos - length, length);
     }
   return NULL;
  }
//+------------------------------------------------------------------+
//| StringSubstrBetween.                                             |
//+------------------------------------------------------------------+
/**
* Gets the string that is nested in between two string tags.
* Only the first match is returned.
* Example:
*      StringSubstrBetween("<a>foo</a>", "<a>", "</a>");  // "foo"
*/
string StringSubstrBetween(string sourceStr, string openTag, string closeTag)
  {
   if(StringIsNullOrEmpty(sourceStr)
      || StringIsNullOrEmpty(openTag)
      || StringIsNullOrEmpty(closeTag))
     {
      return NULL;
     }
   int start = StringIndexOf(sourceStr, openTag);
   if(start != -1)
     {
      start += StringLen(openTag);
      int end = StringIndexOf(sourceStr, closeTag, start);
      if(end != -1)
        {
         return StringSubstr(sourceStr, start, end - start);
        }
     }
   return NULL;
  }
//+------------------------------------------------------------------+
//| StringToLowerCase.                                               |
//+------------------------------------------------------------------+
/**
* Returns a copy of this string converted to lowercase.
* The source string is not modified (i.e., immutable).
*/
string StringToLowerCase(string sourceStr)
  {
   StringToLower(sourceStr);
   return (sourceStr);
  }
//+------------------------------------------------------------------+
//| StringToUpperCase.                                               |
//+------------------------------------------------------------------+
/**
* Returns a copy of this string converted to uppercase.
* The source string is not modified (i.e., immutable).
*/
string StringToUpperCase(string sourceStr)
  {
   StringToUpper(sourceStr);
   return (sourceStr);
  }
//+------------------------------------------------------------------+
//| StringTrim.                                                      |
//+------------------------------------------------------------------+
/**
* Returns a new string in which all leading and trailing white-space
* characters found in the input string are removed.
* The source string is not modified (i.e., immutable).
*/
string StringTrim(string sourceStr)
  {
   return StringTrimStart(StringTrimEnd(sourceStr));
  }
//+------------------------------------------------------------------+
//| StringTrimEnd.                                                   |
//+------------------------------------------------------------------+
/**
* Returns a new string in which all trailing white-space characters
* found in the input string are removed.
* The source string is not modified (i.e., immutable).
*/
string StringTrimEnd(string sourceStr)
  {
#ifdef __MQL4__
   return StringTrimRight(sourceStr);
#else
   StringTrimRight(sourceStr);
   return (sourceStr);
#endif
  }
//+------------------------------------------------------------------+
//| StringTrimStart.                                                 |
//+------------------------------------------------------------------+
/**
* Returns a new string in which all leading white-space characters
* found in the input string are removed.
* The source string is not modified (i.e., immutable).
*/
string StringTrimStart(string sourceStr)
  {
#ifdef __MQL4__
   return StringTrimLeft(sourceStr);
#else
   StringTrimLeft(sourceStr);
   return (sourceStr);
#endif
  }
//+------------------------------------------------------------------+
//| DQuoteStr.                                                       |
//+------------------------------------------------------------------+
/**
* Returns a copy of this string enclosed in a pair of double quotes.
* The source string is not modified (i.e., immutable).
* This helps to pass string parameters which may contain spaces on
* the command-line.
* Example:
*      DQuoteStr("MetaTrader 5");  // ""MetaTrader 5""
*      DQuoteStr(ea_path());       // ""C:\Program Files\MetaTrader 5\MQL5\Scripts\""
*/
string DQuoteStr(string sourceStr)
  {
   return "\"" + sourceStr + "\"";
  }
//+------------------------------------------------------------------+
//| StrHashCode.                                                     |
//+------------------------------------------------------------------+
/**
* Generates 32 bit FNV-1a hash value from the given string.
* https://en.wikipedia.org/wiki/Fowler-Noll-Vo_hash_function
* Example:
*      const long magicNumber = ((long) StrHashCode("MyExpertName") << 31) + StrHashCode(_Symbol);
*/
uint StrHashCode(string key)
  {
//--- Handle Unicode code points > 0x7f
   uchar bytes[];
   StringToCharArray(key, bytes, 0, -1, CP_UTF8);
   int len = ArraySize(bytes) - 1;

//--- Generate 32 bit fnv-1a checksum
   uint hash = 2166136261;
   for(int i = 0; i < len; i++)
      hash = 16777619 * (hash ^ bytes[i]);
   return hash;
  }
//+------------------------------------------------------------------+
//| Base64Encode.                                                    |
//+------------------------------------------------------------------+
/**
* Encodes a string using Base64 encoding scheme.
* Example:
*      Base64Encode("https://twitter.com/");  // "aHR0cHM6Ly90d2l0dGVyLmNvbS8="
*      Base64Encode("Привет мир!");           // "0J/RgNC40LLQtdGCINC80LjRgCE="
*/
string Base64Encode(string text)
  {
   uchar src[], dst[], key[] = {0};

//--- copy text to source array src[]
   StringToCharArray(text, src, 0, -1, CP_UTF8);
   ArrayResize(src, ArraySize(src) - 1);

//--- encode src[] with BASE64
   int res = CryptEncode(CRYPT_BASE64, src, key, dst);

   return (res > 0) ? CharArrayToString(dst, 0, -1, CP_ACP) : "";
  }
//+------------------------------------------------------------------+
//| Base64Decode.                                                    |
//+------------------------------------------------------------------+
/**
* Decodes a Base64-encoded string into the original string.
* Example:
*      Base64Decode("aHR0cHM6Ly90d2l0dGVyLmNvbS8=");  // "https://twitter.com/"
*      Base64Decode("0J/RgNC40LLQtdGCINC80LjRgCE=");  // "Привет мир"
*/
string Base64Decode(string text)
  {
   uchar src[], dst[], key[] = {0};

//--- copy text to source array src[]
   StringToCharArray(text, src, 0, -1, CP_ACP);
   ArrayResize(src, ArraySize(src) - 1);

//--- decode src[] with BASE64
   int res = CryptDecode(CRYPT_BASE64, src, key, dst);

   return (res > 0) ? CharArrayToString(dst, 0, -1, CP_UTF8) : "";
  }
//+------------------------------------------------------------------+
//| UTF8GetBytes.                                                    |
//+------------------------------------------------------------------+
/**
* Encodes this string into a sequence of bytes using UTF-8 encoding.
* The function returns the number of copied elements.
* This helps to send string messages via web sockets.
* Example:
*      uchar bytes[];
*      UTF8GetBytes("MQL5", bytes);  // 4
*      ArrayPrint(bytes);            // 77 81 76 53
*      UTF8GetString(bytes);         // "MQL5"
*/
int UTF8GetBytes(string sourceStr, uchar &bytes[])
  {
   ArrayFree(bytes);
   StringToCharArray(sourceStr, bytes, 0, -1, CP_UTF8);
   int count = ArrayResize(bytes, ArraySize(bytes) - 1);
   return count;
  }
//+------------------------------------------------------------------+
//| UTF8GetString.                                                   |
//+------------------------------------------------------------------+
/**
* Decodes a sequence of bytes into a string using UTF-8 encoding.
* The input array may (or may not) be terminated with a terminal 0.
* This helps to decode string messages received from web sockets.
*/
string UTF8GetString(uchar &bytes[])
  {
   return CharArrayToString(bytes, 0, -1, CP_UTF8);
  }
//+------------------------------------------------------------------+
//| UnicodeGetBytes.                                                 |
//+------------------------------------------------------------------+
/**
* Encodes this string into a sequence of bytes using Unicode (UTF16) encoding.
* The function returns the number of copied elements.
* This helps to pass string parameters to Windows api functions.

* Example:
*      ushort chars[];
*      UnicodeGetBytes("MQL5", chars);  // 4
*      ArrayPrint(chars);               // 77 81 76 53
*      UnicodeGetString(chars);         // "MQL5"
*/
int UnicodeGetBytes(string sourceStr, ushort &chars[])
  {
   ArrayFree(chars);
   StringToShortArray(sourceStr, chars, 0, -1);
   int count = ArrayResize(chars, ArraySize(chars) - 1);
   return count;
  }
//+------------------------------------------------------------------+
//| UnicodeGetString.                                                |
//+------------------------------------------------------------------+
/**
* Decodes a sequence of bytes into a string using Unicode (UTF16) encoding.
* The input array may (or may not) be terminated with a terminal 0.
* This helps to decode strings returned from Windows api functions.
*/
string UnicodeGetString(ushort &chars[])
  {
   return ShortArrayToString(chars, 0, -1);
  }


#endif // #ifndef STRING_UNIQUE_HEADER_ID_H