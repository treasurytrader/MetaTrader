
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <WinUser32.mqh>

#import "kernel32.dll"
   int CreateFileW(string, uint, int, int, int, int, int);
   int GetFileSize(int, int);
   int ReadFile(int, uchar&[], int, int&[], int);
   int CloseHandle(int);
#import
//59491

int BytesToRead = 0;

// Get your current logs to read for example today is 28.02.2020 so logs will be 20200228
string CovertDateTime()
{
   datetime now = TimeCurrent(), yesterday = now - 86400; // PERIOD_D1 * 60
   string logFile2=TimeToStr(yesterday);
   string logFile1=TimeToStr(TimeCurrent(),TIME_DATE);
   StringReplace(logFile1,".","");
   return logFile1;
}

string File = CovertDateTime();
string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH); 
string filename= File +".log";
string path=terminal_data_path+"/logs/"+File+".log";

//if dont want with this condition to find your logs please remove this line and put the next line your path;

//string path = "C:/Users/Gavyy/AppData/Roaming/MetaQuotes/Terminal/A270C22676FD87E1F4CE8044BDE1756D2/logs/20200225.log";

int OnInit()
{
   string a = ReadFile(path);
   Alert(a);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
}

string ReadFile(string Filename)
{
   string strFileContents = "";
   int Handle = CreateFileW(Filename, 0x80000000 /*GENERIC_READ*/, 3 /*SHARE READ|WRITE*/, 0, 3 /*OPEN_EXISTING*/, 0, 0);
   
   if (Handle == -1)
   { // error opening file
      Print("Error opening log file ", path, " error code: ", IntegerToString(GetLastError()));
      return ("");
   }
   else
   {
      int LogFileSize = GetFileSize(Handle, 0);
      BytesToRead = LogFileSize;
      if (LogFileSize <= 0)
      {
         // File empty
         Print("Log file is empty ", path);
         return ("");
      }
      else
      {
         uchar buffer[];
         ArrayResize(buffer, BytesToRead);
         int read[1];
         ReadFile(Handle, buffer, BytesToRead, read, 0);
         if (read[0] == BytesToRead)
         {
            strFileContents = CharArrayToString(buffer, 0, read[0]);
         }
         else
         {
            // Read failed
            Print("Error reading log file ", path);
            return ("");
         }
      }
      CloseHandle(Handle);
   }
   return strFileContents;
}
