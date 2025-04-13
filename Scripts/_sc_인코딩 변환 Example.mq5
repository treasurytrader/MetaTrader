//
// Original article: GrabWeb not working on MT4 Build 600
// https://www.mql5.com/en/forum/149321
//

#import "kernel32.dll"
  int GetTempPathA(int, uchar &arr[]);
  int GetTempPathW(int, short &arr[]);
#import

void OnStart() {
  uchar AnsiStringBuffer[256];
  GetTempPathA(255, AnsiStringBuffer);
  string strTempPathFromA = CharArrayToString(AnsiStringBuffer);

  short UnicodeStringBuffer[256];
  GetTempPathW(255, UnicodeStringBuffer);
  string strTempPathFromW = ShortArrayToString(UnicodeStringBuffer);

  Print("Temp path via GetTempPathA(): ", strTempPathFromA);
  Print("Temp path via GetTempPathW(): ", strTempPathFromW);
}
/*
#import "user32.dll"
  // Declare the Ansi function as taking uchar[] input parameters instead of
  // strings
  int MessageBoxA(int, uchar &arr1[], uchar &arr2[], int);
#import

void OnStart() {
  string strMessage = "Hello";
  string strTitle = "Hi!";

  // Convert the strings to uchar[] arrays
  uchar ucMessage[], ucTitle[];
  StringToCharArray(strMessage, ucMessage);
  StringToCharArray(strTitle, ucTitle);

  MessageBoxA(0, ucMessage, ucTitle, 64);
}
*/