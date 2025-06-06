
// https://www.mql5.com/en/forum/204328
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#define GENERIC_READ      -2147483648
#define GENERIC_WRITE     1073741824

// #define FILE_SHARE_READ   1
// #define FILE_SHARE_WRITE  2

#define CREATE_NEW        1
#define CREATE_ALWAYS     2
#define OPEN_EXISTING     3
#define OPEN_ALWAYS       4
#define TRUNCATE_EXISTING 5

#define FILE_BEGIN        0
#define FILE_CURRENT      1
#define FILE_END          2

#ifdef __MQL5__
  #define HANDLE long
#else
  #define HANDLE int
#endif

#import "kernel32.dll"
  HANDLE CreateFileW(const string, int, int, HANDLE, int, int, HANDLE);
  int    ReadFile(HANDLE, uchar &[], int, int &[], HANDLE);
  int    WriteFile(HANDLE, const uchar &[], int, int &[], HANDLE);
  int    SetFilePointer(HANDLE, int, int &[], int);
  int    GetFileSize(HANDLE, int);
  int    CloseHandle(HANDLE);
  int    FlushFileBuffers(HANDLE);
  bool   DeleteFileW(const string);
  //---
#import

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

HANDLE WinAPI_FileOpen(string file_name, int open_flags,
                       short delimiter = ';', uint codepage = CP_ACP) {
  //---
  int _READ        = 0; // FILE_READ        1
  int _WRITE       = 0; // FILE_WRITE       2
  int _BIN         = 0; // FILE_BIN         4
  int _CSV         = 0; // FILE_CSV         8
  int _TXT         = 0; // FILE_TXT         16
  int _ANSI        = 0; // FILE_ANSI        32
  int _UNICODE     = 0; // FILE_UNICODE     64
  int _SHARE_READ  = 0; // FILE_SHARE_READ  128
  int _SHARE_WRITE = 0; // FILE_SHARE_WRITE 256
  int _REWRITE     = 0; // FILE_REWRITE     512
  int _COMMON      = 0; // FILE_COMMON      4096

  int flag = open_flags;

  if (FILE_COMMON      <= flag) {_COMMON      = FILE_COMMON;      flag -= FILE_COMMON;}
  if (FILE_REWRITE     <= flag) {_REWRITE     = FILE_REWRITE;     flag -= FILE_REWRITE;}
  if (FILE_SHARE_WRITE <= flag) {_SHARE_WRITE = FILE_SHARE_WRITE; flag -= FILE_SHARE_WRITE;}
  if (FILE_SHARE_READ  <= flag) {_SHARE_READ  = FILE_SHARE_READ;  flag -= FILE_SHARE_READ;}
  if (FILE_UNICODE     <= flag) {_UNICODE     = FILE_UNICODE;     flag -= FILE_UNICODE;}
  if (FILE_ANSI        <= flag) {_ANSI        = FILE_ANSI;        flag -= FILE_ANSI;}
  if (FILE_TXT         <= flag) {_TXT         = FILE_TXT;         flag -= FILE_TXT;}
  if (FILE_CSV         <= flag) {_CSV         = FILE_CSV;         flag -= FILE_CSV;}
  if (FILE_BIN         <= flag) {_BIN         = FILE_BIN;         flag -= FILE_BIN;}
  if (FILE_WRITE       <= flag) {_WRITE       = FILE_WRITE;       flag -= FILE_WRITE;}
  if (FILE_READ        <= flag) {_READ        = FILE_READ;        flag -= FILE_READ;}

  //---
  int dwDesiredAccess = 0;
  if (_READ  == FILE_READ ) dwDesiredAccess = GENERIC_READ;
  if (_WRITE == FILE_WRITE) dwDesiredAccess = (dwDesiredAccess | GENERIC_WRITE);

  //---
  int ShareMode = 0;
  if (_SHARE_READ  == FILE_SHARE_READ ) ShareMode = 1;
  if (_SHARE_WRITE == FILE_SHARE_WRITE) ShareMode = (ShareMode | 2);

  //---
  int dwCreationDisposition = 0;
  if (_READ == FILE_READ) {
    if (_WRITE == FILE_WRITE)
      dwCreationDisposition = CREATE_NEW | OPEN_EXISTING;
    else
      dwCreationDisposition = OPEN_ALWAYS;
  } else {
    if (_WRITE == FILE_WRITE)
      dwCreationDisposition = CREATE_ALWAYS;
  }

  return (CreateFileW(file_name, dwDesiredAccess, ShareMode, 0, dwCreationDisposition, 0, 0));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

uint WinAPI_FileWrite(HANDLE file_handle, string data1,
                      string data2 = "", string data3 = "") {
  // Receives the number of bytes written to the file. Note that MQL can only
  // pass arrays as by-reference parameters to DLLs
  int size[1] = {0};

  // Get the length of the string
  string source = data1 + data2 + data3;
  uchar buffer[];
  StringToCharArray(source, buffer, 0, StringLen(source), CP_UTF8);
  int length = ArraySize(buffer);

  // Do the write
  WriteFile(file_handle, buffer, length, size, NULL);

  // Return true if the number of bytes written matches the expected number
  return ((uint)size[0]);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string WinAPI_FileRead(HANDLE file_handle) {
  // Move to the start of the file
  int movehigh[1] = {0};
  SetFilePointer(file_handle, 0, movehigh, FILE_BEGIN);

  // String which holds the combined file
  string str = "";

  // Keep reading from the file until reads fail because we've reached the end
  // (or because the file handle is not valid for reading)
  while (true) {
    // Receives the number of bytes read from the file. Note that MQL can only
    // pass arrays as by-reference parameters to DLLs
    int size[1] = {0};

    // 255-byte buffer...
    uchar buffer[1] = {"123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345"};
    // int length = StringLen(buffer);
    int length = ArraySize(buffer);

    // Do a read of up to 255 bytes
    ReadFile(file_handle, buffer, length, size, NULL);

    // Check whether any data has been read...
    if (0 >= size[0]) break;

    // Add the data which has been read to the combined string
    str += CharArrayToString(buffer, 0, size[0], CP_UTF8);
  }
  return (str);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string WinAPI_FileReadString(HANDLE file_handle, int length = 0, string terminator = "\n") {
  // Holds the line which is eventually returned to the caller
  int    movehigh[1] = {0};
  string str = "";

  // Keep track of the file pointer before we start doing any reading
  int point = SetFilePointer(file_handle, 0, movehigh, FILE_CURRENT);

  // Keep reading from the file until we get the end of the line, or the end of
  // the file
  while (true) {
    // Receives the number of bytes read from the file. Note that MQL can only
    // pass arrays as by-reference parameters to DLLs
    int size[1] = {0};

    // 255-byte buffer...
    uchar buffer[1] = {"123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A123456789A12345"};
    // length = StringLen(buffer);
    length = ArraySize(buffer);

    // Do a read of up to 255 bytes
    ReadFile(file_handle, buffer, length, size, NULL);

    // Check whether any data has been read...
    if (0 >= size[0]) break;

    // Add the new data to the line we've built so far
    str += CharArrayToString(buffer, 0, size[0], CP_UTF8);

    // Does the line now contain the specified terminator?
    int find = StringFind(str, terminator);
    if (-1 != find) {
      // The line does contain the specified terminator. Remove it from the
      // data we're going to pass back to the caller
      str = StringSubstr(str, 0, find);

      // We've almost certainly read too much data - i.e. the latest 200 byte
      // block intrudes into the next line. Need to adjust the file pointer to
      // the start of the next line. This must be the file pointer before we
      // started reading, plus the length of the line we've read, plus the
      // length of the terminator
      SetFilePointer(file_handle, point + StringLen(str) + StringLen(terminator), movehigh, FILE_BEGIN);

      // Stop reading
      break;
    }
  }
  StringReplace(str, "\r", "");
  return (str);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void WinAPI_FileClose (HANDLE file_handle) {
  CloseHandle(file_handle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ulong WinAPI_FileSize(HANDLE file_handle) {
  return ((ulong)GetFileSize(file_handle, 0));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool WinAPI_FileSeek(HANDLE file_handle, long offset, ENUM_FILE_POSITION origin) {
  int from = -1;
  switch (origin) {
    case SEEK_SET : from = FILE_BEGIN;   break;
    case SEEK_CUR : from = FILE_CURRENT; break;
    case SEEK_END : from = FILE_END;
  }
  int movehigh[1] = {0};
  return (-1 != SetFilePointer(file_handle, (int)offset, movehigh, from));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ulong WinAPI_FileTell(HANDLE file_handle) {
  int movehigh[1] = {0};
  return((ulong)SetFilePointer(file_handle, 0, movehigh, FILE_CURRENT));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool WinAPI_FileIsExist(const string file_name, int common_flag = 0) {
  HANDLE file_handle = CreateFileW(file_name, 0, 0, 0, OPEN_EXISTING, 0, 0);
  if (-1 != file_handle) {
    CloseHandle(file_handle);
    return (true);
  }
  return (false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool WinAPI_FileIsEnding(HANDLE file_handle) {
  int movehigh[1] = {0};
  int point = SetFilePointer(file_handle, 0, movehigh, FILE_CURRENT);
  return (WinAPI_FileSize(file_handle) <= point);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool WinAPI_FileDelete (const string file_name, int common_flag = 0) {
  return (DeleteFileW(file_name));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
