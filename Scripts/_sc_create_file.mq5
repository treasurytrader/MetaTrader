
// https://www.mql5.com/en/forum/326416
// https://www.mql5.com/ru/forum/342311
//+------------------------------------------------------------------+
//|                                                   CreateFile.mq5 |
//|                              Copyright © 2019, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.00"
#property script_show_inputs
#include <WinAPI\fileapi.mqh>
//--- input parameters
input string   InpDirectory="Q:\\CreateFile\\";
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   string path_name=InpDirectory;
   PVOID security_attributes=0;

   int result=CreateDirectoryW(path_name,security_attributes);

   HANDLE handle=-1;
   string file_name=Symbol()+".csv";

   uint desired_access=0;

//+------------------------------------------------------------------+
//| share_mode                                                       |
//|  https://docs.microsoft.com/ru-ru/windows/win32/api/fileapi/nf-fileapi-createfilew                               |
//|  0x00000000 Prevents other processes from opening a file or device if they request delete, read, or write access |
//|  0x00000004 FILE_SHARE_DELETE Enables subsequent open operations on a file or device to request delete access    |
//+------------------------------------------------------------------+
   uint share_mode=0x00000004;

//+------------------------------------------------------------------+
//| security_attributes                                              |
//|  https://docs.microsoft.com/ru-ru/windows/win32/api/fileapi/nf-fileapi-createfilew                               |
//|   This parameter can be NULL                                     |
//+------------------------------------------------------------------+
   security_attributes=0;

//+------------------------------------------------------------------+
//| creation_disposition                                             |
//|  https://docs.microsoft.com/ru-ru/windows/win32/api/fileapi/nf-fileapi-createfilew                               |
//|  2 CREATE_ALWAYS                                                 |
//+------------------------------------------------------------------+
   uint creation_disposition=2;

//+------------------------------------------------------------------+
//| flags_and_attributes                                             |
//|  https://docs.microsoft.com/ru-ru/windows/win32/api/fileapi/nf-fileapi-createfilew                               |
//|  128 (0x80) FILE_ATTRIBUTE_NORMAL                                |
//+------------------------------------------------------------------+
   uint flags_and_attributes=0x80;
   HANDLE template_file=0;

   handle=CreateFileW(path_name+"\\"+file_name,desired_access,share_mode,security_attributes,creation_disposition,flags_and_attributes,template_file);
   if(handle!=INVALID_HANDLE)
      FileClose(handle);
   int d=0;
  }
//+------------------------------------------------------------------+
