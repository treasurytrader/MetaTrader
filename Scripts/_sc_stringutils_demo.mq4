
//https://www.mql5.com/en/code/35395
//+------------------------------------------------------------------+
//|                                                 StringUtils_demo |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "1.800"
#property description "A collection of string manipulation functions."

#include <_string_utils.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define PRINT(A) PrintHelper(#A, (A))

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
void PrintHelper(string _A, const T A)
  {
   if(typename(T) == "string")
      Print(_A + " = ", "\"" + (string)A + "\"");
   else
      Print(_A + " = ", (string)A);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   /**
    * All functions return a modified copy of the input string.
    * The source string is not modified (i.e., immutable).
    */
   PRINT( StringAppendIfMissing("dir", "\\") );
   PRINT( StringAppendIfMissing("dir\\", "\\") );
   PRINT( StringCharAt("Apple", 4) );
   PRINT( StringCharCodeAt("Apple", 4) );
   string parts[];
   PRINT( StringChunk("1234567890", 3, parts) );
   ArrayPrint(parts);
   PRINT( StringChunkRight("1234567890", 3, parts) );
   ArrayPrint(parts);
   PRINT( StringContains("life_is_good", "is") );
   PRINT( StringCountMatches("Mr Blue has a blue house and a blue car", "blue") );
   PRINT( StringEndsWith("life_is_good", "good") );
   PRINT( StringEndsWith("life_is_good", "is", 7) );
   PRINT( StringGenerateRandom(12) );
   PRINT( StringIndexOf("Morning", "n") );
   PRINT( StringInsert("012345", "xxx", 3) );
   PRINT( StringIsNullOrEmpty(NULL) );
   PRINT( StringIsNullOrEmpty("") );
   PRINT( StringIsNumeric("12345") );
   PRINT( StringIsNumeric("3.142") );
   PRINT( StringJoin("-", "Java", "is", "cool") );
   PRINT( StringLastIndexOf("Morning", "n") );
   PRINT( StringLeft("helicopter") );
   PRINT( StringLeft("vehicle", 2) );
   PRINT( StringLeft("car", 5) );
   PRINT( StringPad("MQL5 is awesome", 21, '*') );
   PRINT( StringPadEnd("USD", 5) );
   PRINT( StringPadEnd("1.3", 5, '0') );
   PRINT( StringPadStart("USD", 5) );
   PRINT( StringPadStart("123", 5, '0') );
   PRINT( StringPrependIfMissing("domain.com", "www.") );
   PRINT( StringPrependIfMissing("www.domain.com", "www.") );
   PRINT( StringRemove("Mr Blue has a blue house and a blue car", "blue ") );
   PRINT( StringRemoveEnd("www.domain.com", ".com") );
   PRINT( StringRemoveStart("www.domain.com", "www.") );
   PRINT( StringRemoveStart("domain.com", "www.") );
   PRINT( StringRepeat("*", 5) );
   PRINT( StringRepeat('*', 5) );
   PRINT( StringReplace2("Mr Blue has a blue house and a blue car", "blue", "red") );
   PRINT( StringReplaceBetween("<a>foo</a>", "<a>", "</a>", "bar") );
   PRINT( StringReverse("012345") );
   PRINT( StringRight("helicopter") );
   PRINT( StringRight("vehicle", 2) );
   PRINT( StringRight("car", 5) );
   PRINT( StringShuffle("012345") );
   PRINT( StringSplit("_life_is_good_", "_", parts) );
   ArrayPrint(parts);
   PRINT( StringSplitTrim("_life_is_good_", "_", parts) );
   ArrayPrint(parts);
   PRINT( StringStartsWith("life_is_good", "life") );
   PRINT( StringStartsWith("life_is_good", "is", 5) );
   PRINT( StringSubstrAfter("abcba", "b") );
   PRINT( StringSubstrAfterLast("abcba", "b") );
   PRINT( StringSubstrBefore("abcba", "b") );
   PRINT( StringSubstrBeforeLast("abcba", "b") );
   PRINT( StringSubstrBetween("<a>foo</a>", "<a>", "</a>") );
   PRINT( StringToLowerCase("MetaTrader 5") );
   PRINT( StringToUpperCase("MetaTrader 5") );
   PRINT( StringTrim("  Hello World!  ") );
   PRINT( StringTrimEnd("  Hello World!  ") );
   PRINT( StringTrimStart("  Hello World!  ") );
   PRINT( DQuoteStr(MQLInfoString(MQL_PROGRAM_PATH)) );
   PRINT( StrHashCode("https://twitter.com/") );
   PRINT( StrHashCode("Привет мир!") );
   const long magicNumber = ((long) StrHashCode("MyExpertName") << 31) + StrHashCode(_Symbol);
   PRINT( magicNumber );
   PRINT( Base64Encode("https://twitter.com/") );
   PRINT( Base64Decode("aHR0cHM6Ly90d2l0dGVyLmNvbS8=") );
   PRINT( Base64Encode("Привет мир!") );
   PRINT( Base64Decode("0J/RgNC40LLQtdGCINC80LjRgCE=") );
   uchar bytes[];
   PRINT( UTF8GetBytes("MQL5", bytes) );
   ArrayPrint(bytes);
   PRINT( UTF8GetString(bytes) );
   ushort chars[];
   PRINT( UnicodeGetBytes("MQL5", chars) );
   ArrayPrint(chars);
   PRINT( UnicodeGetString(chars) );
  }
//+------------------------------------------------------------------+

// Expected output:
/*
  StringAppendIfMissing(dir,\) = "dir\"
  StringAppendIfMissing(dir\,\) = "dir\"
  StringCharAt(Apple,4) = "e"
  StringCharCodeAt(Apple,4) = 101
  StringChunk(1234567890,3,parts) = 4
  "123" "456" "789" "0"
  StringChunkRight(1234567890,3,parts) = 4
  "890" "567" "234" "1"
  StringContains(life_is_good,is) = true
  StringCountMatches(Mr Blue has a blue house and a blue car,blue) = 2
  StringEndsWith(life_is_good,good) = true
  StringEndsWith(life_is_good,is,7) = true
  StringGenerateRandom(12) = "9VPP7jZcShNz"
  StringIndexOf(Morning,n) = 3
  StringInsert(012345,xxx,3) = "012xxx345"
  StringIsNullOrEmpty(NULL) = true
  StringIsNullOrEmpty() = true
  StringIsNumeric(12345) = true
  StringIsNumeric(3.142) = true
  StringJoin(-,Java,is,cool) = "Java-is-cool"
  StringLastIndexOf(Morning,n) = 5
  StringLeft(helicopter) = "h"
  StringLeft(vehicle,2) = "ve"
  StringLeft(car,5) = "car"
  StringPad(MQL5 is awesome,21,'*') = "***MQL5 is awesome***"
  StringPadEnd(USD,5) = "USD  "
  StringPadEnd(1.3,5,'0') = "1.300"
  StringPadStart(USD,5) = "  USD"
  StringPadStart(123,5,'0') = "00123"
  StringPrependIfMissing(domain.com,www.) = "www.domain.com"
  StringPrependIfMissing(www.domain.com,www.) = "www.domain.com"
  StringRemove(Mr Blue has a blue house and a blue car,blue ) = "Mr Blue has a house and a car"
  StringRemoveEnd(www.domain.com,.com) = "www.domain"
  StringRemoveStart(www.domain.com,www.) = "domain.com"
  StringRemoveStart(domain.com,www.) = "domain.com"
  StringRepeat(*,5) = "*****"
  StringRepeat('*',5) = "*****"
  StringReplace2(Mr Blue has a blue house and a blue car,blue,red) = "Mr Blue has a red house and a red car"
  StringReplaceBetween(<a>foo</a>,<a>,</a>,bar) = "<a>bar</a>"
  StringReverse(012345) = "543210"
  StringRight(helicopter) = "r"
  StringRight(vehicle,2) = "le"
  StringRight(car,5) = "car"
  StringShuffle(012345) = "145230"
  StringSplit(_life_is_good_,_,parts) = 5
  ""     "life" "is"   "good" ""
  StringSplitTrim(_life_is_good_,_,parts) = 3
  "life" "is"   "good"
  StringStartsWith(life_is_good,life) = true
  StringStartsWith(life_is_good,is,5) = true
  StringSubstrAfter(abcba,b) = "cba"
  StringSubstrAfterLast(abcba,b) = "a"
  StringSubstrBefore(abcba,b) = "a"
  StringSubstrBeforeLast(abcba,b) = "abc"
  StringSubstrBetween(<a>foo</a>,<a>,</a>) = "foo"
  StringToLowerCase(MetaTrader 5) = "metatrader 5"
  StringToUpperCase(MetaTrader 5) = "METATRADER 5"
  StringTrim(  Hello World!  ) = "Hello World!"
  StringTrimEnd(  Hello World!  ) = "  Hello World!"
  StringTrimStart(  Hello World!  ) = "Hello World!  "
  DQuoteStr(MQLInfoString(MQL_PROGRAM_PATH)) = ""C:\Program Files\MetaTrader 5\MQL5\Scripts\StringUtils_demo.ex5""
  StrHashCode(https://twitter.com/) = 2363652379
  StrHashCode(Привет мир!) = 3271322339
  magicNumber = 9094825662509768225
  Base64Encode(https://twitter.com/) = "aHR0cHM6Ly90d2l0dGVyLmNvbS8="
  Base64Decode(aHR0cHM6Ly90d2l0dGVyLmNvbS8=) = "https://twitter.com/"
  Base64Encode(Привет мир!) = "0J/RgNC40LLQtdGCINC80LjRgCE="
  Base64Decode(0J/RgNC40LLQtdGCINC80LjRgCE=) = "Привет мир!"
  UTF8GetBytes(MQL5,bytes) = 4
  77 81 76 53
  UTF8GetString(bytes) = "MQL5"
  UnicodeGetBytes(MQL5,chars) = 4
  77 81 76 53
  UnicodeGetString(chars) = "MQL5"
*/