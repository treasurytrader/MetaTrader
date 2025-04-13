//+------------------------------------------------------------------+
//|                                  Period_Converter_OptReverse.mq4 |
//|                                          Copyright (c) 2015, AUO |
//|                                     http://mt4indifx.seesaa.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2015, AUO "
#property link "http://mt4indifx.seesaa.net/"
#property version "1.00"
#property strict

#property indicator_chart_window

#include <WinUser32.mqh>

#define FILE_VERSION 401
#define C_COPYRIGHT "(C)opyright 2003, MetaQuotes Software Corp."
#define CHART_CMD_UPDATE_DATA 33324

//--- input parameters
input string Name = "";
input int PeriodMultiplier = 1;
input bool OutputHstFile = true;
input bool OutputCsvFile = false;
input uint UpdateInterval = 0;
input int MyDigit = 5;

//--- indicator buffers

//---
string gs_symbol;
int gi_period;
int gi_filehandle = INVALID_HANDLE;
int gi_csvhandle = INVALID_HANDLE;
int gi_jpymultiplier = 1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
  bool lb_timeframe, lb_symbol;
  long ll_chart;
  string ls_suffix = "";

  //---
  gi_period = Period() * PeriodMultiplier;
  switch (gi_period) {
  case PERIOD_M1:
    lb_timeframe = true;
    break;
  case PERIOD_M5:
    lb_timeframe = true;
    break;
  case PERIOD_M15:
    lb_timeframe = true;
    break;
  case PERIOD_M30:
    lb_timeframe = true;
    break;
  case PERIOD_H1:
    lb_timeframe = true;
    break;
  case PERIOD_H4:
    lb_timeframe = true;
    break;
  case PERIOD_D1:
    lb_timeframe = true;
    break;
  case PERIOD_W1:
    lb_timeframe = true;
    break;
  case PERIOD_MN1:
    lb_timeframe = true;
    break;
  default:
    lb_timeframe = false;
  }

  ll_chart = ChartFirst();
  lb_symbol = false;
  while (ll_chart > 0) {
    if (Name == ChartSymbol(ll_chart))
      lb_symbol = true;
    ll_chart = ChartNext(ll_chart);
  }

  if (StringFind(Symbol(), "JPY") == -1) {
    gi_jpymultiplier = 1;
  } else {
    gi_jpymultiplier = 100;
  }
  if ((lb_symbol && lb_timeframe) || Name == "") {
    gs_symbol = StringConcatenate(StringSubstr(Symbol(), 3, 3),
                                  StringSubstr(Symbol(), 0, 3));
  } else {
    gs_symbol = Name;
    if (StringLen(gs_symbol) > 11) {
      gs_symbol = StringSubstr(gs_symbol, 0, 11);
    }
  }

  //--- file open
  if (!OutputHstFile && !OutputCsvFile)
    return (INIT_FAILED);
  if (OutputHstFile) {
    gi_filehandle = OpenHistoryFile(gs_symbol, gi_period);
    if (gi_filehandle == INVALID_HANDLE)
      return (INIT_FAILED);
    //--- write history file header
    WriteHistoryHeader(gi_filehandle, gs_symbol, gi_period);
  }
  if (OutputCsvFile) {
    gi_csvhandle = OpenCsvFile(gs_symbol, gi_period);
    if (gi_csvhandle == INVALID_HANDLE)
      return (INIT_FAILED);
  }
  //--- indicator buffers mapping
  //--- name for DataWindow and indicator subwindow label
  //---
  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
  //---
  CloseHistoryFile(gi_filehandle);
  CloseHistoryFile(gi_csvhandle);
  //---
  return;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  //---
  static uint si_last_time = 0;
  uint li_current_time;
  int i, limit;
  bool lb_last;
  MqlRates ls_rate = {0, 0, 0, 0, 0, 0, 0};

  //--- counting from 0 to rates_total

  //----
  if (UpdateInterval != 0) {
    li_current_time = GetTickCount();
    if (li_current_time - si_last_time < UpdateInterval) {
      return (prev_calculated);
    }
    si_last_time = li_current_time;
  }

  limit = rates_total - prev_calculated;
  if (limit < 1)
    limit = 1;
  for (i = limit - 1; i >= 0; i--) {
    ls_rate.time = iTime(NULL, PERIOD_CURRENT, i);
    ls_rate.open = NormalizeDouble(
        1 / iOpen(NULL, PERIOD_CURRENT, i) * gi_jpymultiplier, MyDigit);
    ls_rate.high = NormalizeDouble(
        1 / iLow(NULL, PERIOD_CURRENT, i) * gi_jpymultiplier, MyDigit);
    ls_rate.low = NormalizeDouble(
        1 / iHigh(NULL, PERIOD_CURRENT, i) * gi_jpymultiplier, MyDigit);
    ls_rate.close = NormalizeDouble(
        1 / iClose(NULL, PERIOD_CURRENT, i) * gi_jpymultiplier, MyDigit);
    ls_rate.tick_volume = iVolume(NULL, PERIOD_CURRENT, i);
    if (i == 0) {
      lb_last = true;
    } else {
      lb_last = false;
    }
    if (OutputHstFile)
      WriteHistoryData(gi_filehandle, gi_period * 60, ls_rate, lb_last,
                       lb_last);
    if (OutputCsvFile)
      WriteCsvData(gi_csvhandle, gi_period * 60, ls_rate, lb_last, lb_last);
  }
  UpdateChartWindow(gs_symbol, gi_period);
  //--- return value of prev_calculated for next call

  TickSender(gs_symbol, gi_period);

  return (rates_total);
}

//+------------------------------------------------------------------+
//| Subroutine                                                       |
//+------------------------------------------------------------------+
int OpenHistoryFile(string symbol, int timeframe) {
  int li_handle;

  li_handle = FileOpenHistory(symbol + IntegerToString(timeframe) + ".hst",
                              FILE_BIN | FILE_WRITE | FILE_SHARE_WRITE |
                                  FILE_SHARE_READ | FILE_ANSI);
  return (li_handle);
}
//+------------------------------------------------------------------+
int OpenCsvFile(string symbol, int timeframe) {
  int li_handle;

  li_handle = FileOpen(symbol + IntegerToString(timeframe) + ".csv",
                       FILE_CSV | FILE_WRITE | FILE_SHARE_WRITE |
                           FILE_SHARE_READ | FILE_ANSI,
                       ',');
  return (li_handle);
}
//+------------------------------------------------------------------+
void WriteHistoryHeader(int filehandle, string symbol, int timeframe) {
  int li_unused[13];

  if (filehandle == INVALID_HANDLE)
    return;
  ArrayInitialize(li_unused, 0);
  FileWriteInteger(filehandle, FILE_VERSION, LONG_VALUE);
  FileWriteString(filehandle, C_COPYRIGHT, 64);
  FileWriteString(filehandle, symbol, 12);
  FileWriteInteger(filehandle, timeframe, LONG_VALUE);
  FileWriteInteger(filehandle, MyDigit, LONG_VALUE);
  FileWriteInteger(filehandle, 0, LONG_VALUE);
  FileWriteInteger(filehandle, 0, LONG_VALUE);
  FileWriteArray(filehandle, li_unused, 0, 13);
  return;
}
//+------------------------------------------------------------------+
void WriteHistoryData(int filehandle, int second, const MqlRates &rate,
                      bool minusvolume, bool flush) {
  static MqlRates written = {0, 0, 0, 0, 0, 0, 0, 0};
  static ulong fp = 0;

  if (filehandle == INVALID_HANDLE)
    return;
  if (fp == 0 || written.time + second <= rate.time) {
    //--- new
    written = rate;
    written.time = rate.time / second;
    written.time *= second;
    written.spread = 0;
    written.real_volume = 0;
    fp = FileTell(filehandle);
    FileWriteStruct(filehandle, written);
    if (minusvolume)
      written.tick_volume -= rate.tick_volume;
    if (flush)
      FileFlush(filehandle);
  } else if (written.time <= rate.time && rate.time < written.time + second) {
    //--- current
    if (written.high < rate.high)
      written.high = rate.high;
    if (written.low > rate.low)
      written.low = rate.low;
    written.close = rate.close;
    written.tick_volume += rate.tick_volume;
    FileSeek(filehandle, fp, SEEK_SET);
    FileWriteStruct(filehandle, written);
    if (minusvolume)
      written.tick_volume -= rate.tick_volume;
    if (flush)
      FileFlush(filehandle);
  }
  return;
}
//+------------------------------------------------------------------+
void WriteCsvData(int filehandle, int second, const MqlRates &rate,
                  bool minusvolume, bool flush) {
  static MqlRates written = {0, 0, 0, 0, 0, 0, 0, 0};
  static ulong fp = 0;

  if (filehandle == INVALID_HANDLE)
    return;
  if (fp == 0 || written.time + second <= rate.time) {
    //--- new
    written = rate;
    written.time = rate.time / second;
    written.time *= second;
    written.spread = 0;
    written.real_volume = 0;
    fp = FileTell(filehandle);
    FileWrite(filehandle, TimeToString(written.time, TIME_DATE),
              TimeToString(written.time, TIME_MINUTES),
              DoubleToString(written.open, MyDigit),
              DoubleToString(written.high, MyDigit),
              DoubleToString(written.low, MyDigit),
              DoubleToString(written.close, MyDigit),
              IntegerToString(written.tick_volume));
    if (minusvolume)
      written.tick_volume -= rate.tick_volume;
    if (flush)
      FileFlush(filehandle);
  } else if (written.time <= rate.time && rate.time < written.time + second) {
    //--- current
    if (written.high < rate.high)
      written.high = rate.high;
    if (written.low > rate.low)
      written.low = rate.low;
    written.close = rate.close;
    written.tick_volume += rate.tick_volume;
    FileSeek(filehandle, fp, SEEK_SET);
    FileWrite(filehandle, TimeToString(written.time, TIME_DATE),
              TimeToString(written.time, TIME_MINUTES),
              DoubleToString(written.open, MyDigit),
              DoubleToString(written.high, MyDigit),
              DoubleToString(written.low, MyDigit),
              DoubleToString(written.close, MyDigit),
              IntegerToString(written.tick_volume));
    if (minusvolume)
      written.tick_volume -= rate.tick_volume;
    if (flush)
      FileFlush(filehandle);
  }
  return;
}
//+------------------------------------------------------------------+
int UpdateChartWindow(string symbol, int timeframe) {
  static int si_hwnd = 0;

  if (si_hwnd == 0) {
    si_hwnd = WindowHandle(symbol, timeframe);
    if (si_hwnd != 0)
      Print("Chart window detected");
  }
  if (si_hwnd != 0) {
    if (!IsDllsAllowed()) {
      //--- DLL calls must be allowd
      Print("[Allow DLL imports] not checked");
      return (-1);
    }
    // if(PostMessageA(si_hwnd,WM_COMMAND,CHART_CMD_UPDATE_DATA,0)==0) {
    if (PostMessageW(si_hwnd, WM_COMMAND, CHART_CMD_UPDATE_DATA, 0) == 0) {
      // PostMessage failed, chart window closed
      si_hwnd = 0;
      return (-1);
    } else {
      // PostMessage succeed
      return (0);
    }
  }
  // window not found or PostMessage failed
  return (-1);
}
//+------------------------------------------------------------------+
void CloseHistoryFile(int filehandle) {
  if (filehandle != INVALID_HANDLE) {
    FileClose(filehandle);
    filehandle = INVALID_HANDLE;
  }
  return;
}
//+------------------------------------------------------------------+

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  http://www.forexmt4.com/mt_yahoo/TickSender.mq4
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#import "user32.dll"
int PostMessageW(int hWnd, int Msg, int wParam, int lParam);
int RegisterWindowMessageW(string lpString);
#import

/**
* MT4/experts/scripts/ticks.mq4
* send a fake tick every 200 ms to the chart and
* all its indicators and EA until this script is removed.

#property copyright "© Bernd Kreuss"

extern int timedelay=400;

int start()
{
   int msg = RegisterWindowMessageA("MetaTrader4_Internal_Message");

   while(!IsStopped())
   {
      if (Period()==1 && Seconds()>=50)
      {
         Print("!! Period: ",Period()," ","Minute: ",Minute()," ","Seconds:
",Seconds()); PostMessageA(handle, msg, 2, 1); Sleep(timedelay);
      }
   }
}
*/

void TickSender(string strSymbol, int intTF) {
  static int hwnd = 0;
  if (0 == hwnd)
    hwnd = WindowHandle(strSymbol, intTF);
  if (0 != hwnd) {
    /*
    if (!PostMessageW(hwnd, WM_COMMAND, 33324, 0))
    {
       hwnd = 0;
       return;
    }
    */
    int msg = RegisterWindowMessageW("MetaTrader4_Internal_Message");
    if (!PostMessageW(hwnd, msg, 2, 1))
      hwnd = 0;
  }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~