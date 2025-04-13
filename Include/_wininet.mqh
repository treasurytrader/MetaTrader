
// https://www.mql5.com/en/forum/204328#comment_5307739
//+------------------------------------------------------------------+
//|                                                      Wininet.mqh |
//|                                                     Version: 1.0 |
//|                            Copyright 2015, Wemerson C. Guimaraes |
//|                  https://www.mql5.com/pt/users/wemersonrv/seller |
//|                  http://www.myfxbook.com/members/wemersonrv      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Wemerson C. Guimaraes"
#property link      "https://www.mql5.com/pt/users/wemersonrv/seller"

//+------------------------------------------------------------------+
//| ReadUrl Function                                                 |
//+------------------------------------------------------------------+

#define OPEN_TYPE_PRECONFIG    0
#define DEFAULT_HTTPS_PORT     443
#define SERVICE_HTTP           3
#define FLAG_SECURE            0x00800000
#define FLAG_PRAGMA_NOCACHE    0x00000100
#define FLAG_KEEP_CONNECTION   0x00400000
#define FLAG_RELOAD            0x80000000

#define READURL_BUFFER_SIZEX   1024
#define HTTP_QUERY_STATUS_CODE 19

#import  "Wininet.dll"
  int  InternetAttemptConnect(int);
  int  InternetOpenW(string, int, string, string, int);
  int  InternetConnectW(int, string, int, string, string, int, int, int);
  int  InternetOpenUrlW(int, string, string, int, int, int);
  bool InternetReadFile(int, uchar &[], int, int &);
  bool InternetCloseHandle(int);
  int  HttpOpenRequestW(int, string, string, string, string, string, uint, int);
  bool HttpSendRequestW(int, string &, int, uchar &[], int);
  int  HttpQueryInfoW(int, int, uchar &[], int &, int &);
#import

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

string ReadUrl(string url) {
  //---
  string userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.104 Safari/537.36\0";
  string nill = "\0";
  int HttpOpen    = InternetOpenW(userAgent, 0, nill, nill, 0);
  int HttpConnect = InternetConnectW(HttpOpen, "", 80, nill, nill, 3, 0, 1);
  int HttpRequest = InternetOpenUrlW(HttpOpen, url, NULL, 0, 0, 0);

  string received;
  uchar  cBuff[5];
  int    cBuffLength = 10;
  int    cBuffIndex  = 0;
  int    HttpQueryInfoW = HttpQueryInfoW(HttpRequest, HTTP_QUERY_STATUS_CODE, cBuff, cBuffLength, cBuffIndex);

  // HTTP Codes... Only the 1st character (4xx, 5xx, etc)
  int http_code = (int)CharArrayToString(cBuff, 0, WHOLE_ARRAY, CP_UTF8);
  if (http_code == 4 || http_code == 5) { // 4XX || 5XX
    // if (HttpRequest > 0) InternetCloseHandle(HttpRequest);
    // if (HttpConnect > 0) InternetCloseHandle(HttpConnect);
    // if (HttpOpen    > 0) InternetCloseHandle(HttpOpen);
    received = "-1";
    Print(http_code, "XX | ", url);
  } else {
    int   read, size = 0;
    uchar dst_array[], src_array[];
    ArrayResize(src_array, READURL_BUFFER_SIZEX + 1);
    while (InternetReadFile(HttpRequest, src_array, READURL_BUFFER_SIZEX, read)) {
      if (0 < read) {
        size = ArraySize(dst_array);
        ArrayResize(dst_array, size + 1);
        ArrayCopy(dst_array, src_array, size, 0, read);
      } else break;
    }
    if (0 < size)
      received = CharArrayToString(dst_array, 0, -1, CP_UTF8);
  }

  if (HttpRequest > 0) InternetCloseHandle(HttpRequest);
  if (HttpConnect > 0) InternetCloseHandle(HttpConnect);
  if (HttpOpen    > 0) InternetCloseHandle(HttpOpen);

  return (received);
  //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// https://www.mql5.com/en/forum/149321/page3
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#ifdef __MQL4__
#import "urlmon.dll"
  int URLDownloadToFileW(int pCaller, string szURL, string szFileName, int dwReserved, int Callback);
#import
#endif

bool xmlDownload(string url, string file) {
  //---
  bool ret = true;
  int  get = GrabWeb(url, file);
  if (0 == get) {
    PrintFormat("%s file downloaded successfully!", file);
  }
  else {
    PrintFormat("failed to download %s file, Error code = %d", file, get);
    ret = false;
  }
  return (ret);
  //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int GrabWeb(string url, string file, uint codepage = CP_UTF8) {

  ResetLastError();

#ifdef __MQL4__
  file = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL4\\files\\" + file;
  int get = URLDownloadToFileW(NULL, url, file, 0, NULL);
  return (GetLastError());
#endif

  string toStr = ReadUrl(url);
  if ("-1" != toStr) {
    int handle = FileOpen(file, FILE_TXT | FILE_ANSI | FILE_WRITE, "\n", codepage);
    if (0 < handle) {
      // FileSeek(handle, 0, SEEK_SET);
      FileWrite(handle, toStr);
      FileClose(handle);
    }
  }

  return (GetLastError());
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
