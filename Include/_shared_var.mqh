
//
// SHAREDVAR Header File
//
// Last Update 02.Feb.2015
// Download latest files from https://fx1.net/sharedvar.php
// Fx1 Inc
//

#ifdef __MQL5__
   #import "_shared_var-w64.dll"
#else
   #import "_shared_var-w32.dll"
#endif

   // core functions
   int      svInit(string Realm);
   bool     svExists(int Handle,string Name);

   // set
   bool     svSetString(int Handle,string Name,string Value);
   bool     svSetValue(int Handle,string Name,double Value);
   bool     svSetBool(int Handle,string Name,bool Value);
   bool     svIncValue(int Handle,string Name,double IncBy);

   int      svUpdated(int Handle,string Name);
   int      svCreated(int Handle,string Name);

   // removing
   bool     svRemoveAll(int Handle);
   bool     svRemovePrefix(int Handle,string Prefix);

   // hashing functions
   string   svMD5(string Value);
   int      svCRC32(string Value);
   int      LocalUnixTime();
   int      GMTUnixTime();

   // get
   bool     svGetBool   (int Handle,string Name);
   double   svGetDouble (int Handle,string Name);
   int      svGetInt    (int Handle,string Name);
   string   svGetString (int Handle,string Name);

   // core functions
   string   svVersion();
   bool     svServerRunning();
   string   svServerPath();
   bool     svServerStart();

   // realm functions
   int      svRealmCount();
   string   svRealmName(int Index);

   // variable enumeration
   int      svVarCount(int Handle);
   string   svVarName(int Handle,int Position);
#import

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
//|                                                                  |
//+------------------------------------------------------------------+
