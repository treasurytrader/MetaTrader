
#include <_wininet.mqh>

/*
#define OPEN_TYPE_PRECONFIG    0
#define DEFAULT_HTTPS_PORT     443
#define SERVICE_HTTP           3
#define FLAG_SECURE            0x00800000
#define FLAG_PRAGMA_NOCACHE    0x00000100
#define FLAG_KEEP_CONNECTION   0x00400000
#define FLAG_RELOAD            0x80000000

#import "wininet.dll"
int InternetAttemptConnect(int x);
int InternetOpenW(string sAgent, int lAccessType, string sProxyName, string sProxyBypass, int lFlags);
int InternetConnectW(int hInternet, string szServerName, int nServerPort, string lpszUsername, string lpszPassword, int dwService, int dwFlags, int dwContext);
int HttpOpenRequestW(int hConnect, string Verb, string ObjectName, string Version, string Referer, string AcceptTypes, uint dwFlags, int dwContext);
bool HttpSendRequestW(int hRequest, string &lpszHeaders, int dwHeadersLength, uchar &lpOptional[], int dwOptionalLength);
bool InternetReadFile(int hFile, uchar &sBuffer[], int lNumBytesToRead, int &lNumberOfBytesRead);
bool InternetCloseHandle(int hInet);
#import
*/
//-------------------------------------------------------------------
// https://github.com/ssut/py-googletrans/issues/268
// https://translate.googleapis.com/translate_a/single?client=gtx&dt=t&sl=en&tl=ko&q=Hello
// https://translate.google.com/m?sl=en&tl=ko&hl=ko&q=Hello
//-------------------------------------------------------------------

string translate_googleapis(string message) {

  //--- DLL 사용 확인
  if (!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED)) {
    Print("Error. DLL is not allowed");
    Print("You need to use wininet.dll.");
    return ("");
  }

  //--- 인터넷 연결 확인
  if (0 != InternetAttemptConnect(0)) {
    Print("Error. There is no Internet connection.");
    return ("");
  }

  //--- InternetOpenW :: 초기화
  string userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.104 Safari/537.36\0";
  string nill = "\0";
  int hOpen = InternetOpenW(userAgent, OPEN_TYPE_PRECONFIG, nill, nill, 0);

  if (0 >= hOpen) {
    printf("Error. InternetOpenW() failed.");
    printf("hOpen = %ld", hOpen);
    return ("");
  }

  //--- InternetConnectW :: HTTP 세션 열기
  string host = "translate.googleapis.com";
  int hConnect = InternetConnectW(hOpen, host, DEFAULT_HTTPS_PORT, nill, nill, SERVICE_HTTP, 0, 0);

  if (0 >= hConnect) {
    printf("Error. InternetConnectW() failed.");
    printf("hConnect = %ld", hConnect);
    hClose(hOpen, "hOpen");
    return ("");
  }

  //--- HttpOpenRequestW HTTP 요청 핸들
  string version   = "HTTP/1.1";
  string httpVerb  = "POST";
  string pathName  = "/translate_a/single";

  int hRequest = HttpOpenRequestW(hConnect, httpVerb, pathName, version, nill, nill, FLAG_SECURE | FLAG_KEEP_CONNECTION | FLAG_RELOAD | FLAG_PRAGMA_NOCACHE, 0);

  if (0 >= hRequest) {
    printf("Error. HttpOpenRequestW() failed.");
    printf("hRequest = %ld", hRequest);
    hClose(hConnect, "hConnect");
    hClose(hOpen   , "hOpen"   );
    return ("");
  }

  //--- HttpSendRequestW HTTP 요청
  uchar contents[];
  // message = UrlEncode(message);
  ArrayResize(contents, StringToCharArray("client=gtx&dt=t&sl=en&tl=ko&q=" + message, contents, 0, -1, CP_UTF8) - 1);

  // 검증 코드 (contents에 저장된 문자열 출력)
  // int array_size = ArraySize(contents);
  // for (int i = 0; i < array_size; i++) printf("contents[%d] = %d", i, contents[i]);
  // string letters = CharArrayToString(contents, 0, array_size);
  // printf("array_size = %d", array_size);
  // printf("contents 내용 : %s", letters);

  string header = "Content-Type: application/x-www-form-urlencoded";
  bool   result = HttpSendRequestW(hRequest, header, StringLen(header), contents, ArraySize(contents));

  // InternetReadFile 서버 응답
  // 단순히 더하게 되면 한글 코드가 깨진다.
  // 누적 카피한 다음 최종적으로 변환을 해야 된다.
  // uchar receivedChar[100];
  // ArrayInitialize(receivedChar, (uchar)"\0");
  int   byteRead = 0;
  uchar dst_array[], src_array[];

  ArrayResize(src_array, READURL_BUFFER_SIZEX + 1);

  while (true) {
    InternetReadFile(hRequest, src_array, READURL_BUFFER_SIZEX, byteRead);
    if (0 < byteRead) {
      int size = ArraySize(dst_array);
      ArrayResize(dst_array, size + 1);
      ArrayCopy(dst_array, src_array, size, 0, byteRead);
    } else break;
  }
  string receivedString = CharArrayToString(dst_array, 0, -1, CP_UTF8);
  /*
  while (InternetReadFile(hRequest, receivedChar, 100, byteRead)) {
    if (byteRead <= 0) break;
    receivedString += CharArrayToString(receivedChar, 0, byteRead, CP_UTF8);
  }
  */
  hClose(hRequest, "hRequest");
  hClose(hConnect, "hConnect");
  hClose(hOpen   , "hOpen"   );

  return (receivedString);
  //---
}


//-------------------------------------------------------------------
// 핸들을 닫는 함수
//-------------------------------------------------------------------

void hClose(int handle, string label) {
  if (InternetCloseHandle(handle) == false)
    printf("%s was not closed.", label);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
