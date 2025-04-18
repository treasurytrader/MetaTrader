//+------------------------------------------------------------------+
//|                                        ListingFilesDirectory.mq5 |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link "http://wmua.ru/slesar/"
#property version "1.010"

#define MAX_PATH 0x00000104             //
#define ERROR_NO_MORE_FILES 0x00000012  // there are no more files
#define ERROR_FILE_NOT_FOUND 0x00000002 // the system cannot find the file specified
//---
//+------------------------------------------------------------------+
//| A file or directory that is an archive file or directory.        |
//| Applications typically use this attribute to mark files          |
//| for backup or removal .                                          |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_ARCHIVE 0x00000020 // dec 32

//+------------------------------------------------------------------+
//| A file or directory that is compressed. For a file,              |
//| all of the data in the file is compressed. For a directory,      |
//| compression is the default for newly created files               |
//| and subdirectories.                                              |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_COMPRESSED 0x00000800 // dec 2048

//+------------------------------------------------------------------+
//| This value is reserved for system use.                           |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_DEVICE 0x00000040 // dec 64

//+------------------------------------------------------------------+
//| The handle that identifies a directory.                          |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_DIRECTORY 0x00000010 // dec 16

//+------------------------------------------------------------------+
//| A file or directory that is encrypted. For a file, all data      |
//| streams in the file are encrypted. For a directory, encryption   |
//| is the default for newly created files and subdirectories.       |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_ENCRYPTED 0x00004000 // dec 16384

//+------------------------------------------------------------------+
//| The file or directory is hidden.                                 |
//| It is not included in an ordinary directory listing.             |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_HIDDEN 0x00000002 // dec 2

//+------------------------------------------------------------------+
//| The directory or user data stream is configured with integrity   |
//| (only supported on ReFS volumes). It is not included in an       |
//| ordinary directory listing. The integrity setting persists with  |
//| the file if it's renamed. If a file is copied the destination    |
//| file will have integrity set if either the source file           |
//| or destination directory have integrity set.                     |
//| Windows Server 2008 R2, Windows 7, Windows Server 2008,          |
//| Windows Vista, Windows Server 2003, and Windows XP:              |
//| This flag is not supported until Windows Server 2012.            |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_INTEGRITY_STREAM 0x00008000 // dec 32768

//+------------------------------------------------------------------+
//| A file that does not have other attributes set.                  |
//| This attribute is valid only when used alone.                    |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_NORMAL 0x00000080 // dec 128

//+------------------------------------------------------------------+
//| The file or directory is not to be indexed by                    |
//| the content indexing service.                                    |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_NOT_CONTENT_INDEXED 0x00002000 // dec 8192

//+------------------------------------------------------------------+
//| The user data stream not to be read by the background data       |
//| integrity scanner (AKA scrubber). When set on a directory it only|
//| provides inheritance. This flag is only supported on Storage     |
//| Spaces and ReFS volumes. It is not included                      |
//| in an ordinary directory listing.                                |
//| Windows Server 2008 R2, Windows 7, Windows Server 2008, Windows  |
//| Vista, Windows Server 2003, and Windows XP: This flag            |
//| is not supported until Windows 8 and Windows Server 2012.        |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_NO_SCRUB_DATA 0x00020000 // dec 131072

//+------------------------------------------------------------------+
//| The data of a file is not available immediately. This attribute  |
//| indicates that the file data is physically moved to offline      |
//| storage. This attribute is used by Remote Storage, which is      |
//| the hierarchical storage management software.                    |
//| Applications should not arbitrarily change this attribute.       |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_OFFLINE 0x00001000 // dec 4096

//+------------------------------------------------------------------+
//| A file that is read-only. Applications can read the file, but    |
//| cannot write to it or delete it. This attribute is not honored   |
//| on directories. For more information, see You cannot view or     |
//| change the Read-only or the System attributes of folders in      |
//| Windows Server 2003, in Windows XP, in Windows Vista             |
//| or in Windows 7.                                                 |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_READONLY 0x00000001 // dec 1

//+------------------------------------------------------------------+
//| A file or directory that has an associated reparse point,        |
//| or a file that is a symbolic link.                               |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_REPARSE_POINT 0x00000400 // dec 1024

//+------------------------------------------------------------------+
//| A file that is a sparse file.                                    |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_SPARSE_FILE 0x00000200 // dec 512

//+------------------------------------------------------------------+
//| A file or directory that the operating system uses               |
//| a part of, or uses exclusively.                                  |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_SYSTEM 0x00000004 // dec 4

//+------------------------------------------------------------------+
//| A file that is being used for temporary storage. File systems    |
//| avoid writing data back to mass storage if sufficient cache      |
//| memory is available, because typically, an application deletes   |
//| a temporary file after the handle is closed. In that scenario,   |
//| the system can entirely avoid writing the data.                  |
//| Otherwise, the data is written after the handle is closed.       |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_TEMPORARY 0x00000100 // dec 256

//+------------------------------------------------------------------+
//| This value is reserved for system use.                           |
//+------------------------------------------------------------------+
#define FILE_ATTRIBUTE_VIRTUAL 0x00010000 // dec 65536
//---
//+------------------------------------------------------------------+
//| FILETIME structure                                               |
//+------------------------------------------------------------------+
struct FILETIME {
  uint dwLowDateTime;
  uint dwHighDateTime;
};
//+------------------------------------------------------------------+
//| WIN32_FIND_DATA structure                                        |
//+------------------------------------------------------------------+
struct WIN32_FIND_DATA {
  uint dwFileAttributes;
  FILETIME ftCreationTime;
  FILETIME ftLastAccessTime;
  FILETIME ftLastWriteTime;
  uint nFileSizeHigh;
  uint nFileSizeLow;
  uint dwReserved0;
  uint dwReserved1;
  ushort cFileName[MAX_PATH];
  ushort cAlternateFileName[14];
};

#import "kernel32.dll"
  //---
  int  GetLastError();
  long FindFirstFileW(string lpFileName, WIN32_FIND_DATA &lpFindFileData);
  //--- 64
  int  FindNextFileW(long FindFile, WIN32_FIND_DATA &lpFindFileData);
  int  FindClose(long hFindFile);
  //--- 32
  int  FindNextFileW(int FindFile, WIN32_FIND_DATA &lpFindFileData);
  int  FindClose(int hFindFile);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool WinAPI_FindClose(long hFindFile) {
  bool res;
  if (_IsX64)
    res = FindClose(hFindFile) != 0;
  else
    res = FindClose((int)hFindFile) != 0;
  //---
  return (res);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool WinAPI_FindNextFile(long hFindFile, WIN32_FIND_DATA &lpFindFileData) {
  bool res;
  if (_IsX64)
    res = FindNextFileW(hFindFile, lpFindFileData) != 0;
  else
    res = FindNextFileW((int)hFindFile, lpFindFileData) != 0;
  //---
  return (res);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
