
//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+
// https://www.mql5.com/en/forum/149178
#property show_inputs

void OnStart()
  {
    int      handle = Create("BLANK", 1, 2);
    MqlRates rates  = {D'2000.01.01 00:00', 100, 120, 90, 110, 100, 1, 1};
    long     offset = 0; // 추가 : 0, 다시 쓰기 : -sizeof(rates) or -60

    FileSeek(handle, offset, SEEK_END);
    FileWriteStruct(handle, rates);
    FileClose(handle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int Create(string symbol, int timeframe, int digits)
  {
    int handle = FileOpenHistory(symbol + (string)timeframe + ".hst", FILE_BIN | FILE_WRITE);
    FileClose(handle);

    handle = FileOpenHistory(symbol + (string)timeframe + ".hst", FILE_BIN | FILE_WRITE | FILE_READ | FILE_SHARE_WRITE | FILE_SHARE_READ);

    if (0 > handle) return (-1);
    // if (FileSize(handle) <= 0)
    // {
    FileSeek(handle, 0, SEEK_SET);
    int unused[13];
    ArrayInitialize(unused, 0);
    FileWriteInteger(handle, 401, LONG_VALUE);
    FileWriteString(handle, "(C)opyright 2003, MetaQuotes Software Corp.", 64);
    FileWriteString(handle, symbol, 12);
    FileWriteInteger(handle, timeframe, LONG_VALUE);
    FileWriteInteger(handle, digits, LONG_VALUE);
    FileWriteInteger(handle, 0, LONG_VALUE);
    FileWriteInteger(handle, 0, LONG_VALUE);
    FileWriteArray(handle, unused, 0, 13);
    // }
    // else // go to end of existing history file
    //   {
    FileSeek(handle, 0, SEEK_END);
    //   }
    // FileFlush(handle);
    return (handle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
