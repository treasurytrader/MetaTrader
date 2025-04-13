//+------------------------------------------------------------------+
//|                                            TestSQLite3Select.mq4 |
//|                                          Copyright 2018, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property version   "1.00"
#property strict

#include <SQLite3/Statement.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- optional but recommended
   SQLite3::initialize();

//--- open database
#ifdef __MQL5__
   string filesPath=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files";
#else
   string filesPath=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files";
#endif
   string dbPath=filesPath+"\\test.db";
   Print(dbPath);

   SQLite3 db(dbPath,SQLITE_OPEN_READWRITE);
   if(!db.isValid()) return;

   string sql="select a, b from buy_orders;";

   Statement s(db,sql);

   if(!s.isValid())
     {
      Print(db.getErrorMsg());
      return;
     }

   int r=s.step();
   do
     {
      if(r==SQLITE_ROW)
        {
         Print(">>> New row!");
         int c=s.getColumnCount();
         for(int i=0; i<c; i++)
           {
            if(i==0)
              {
               int value;
               s.getColumn(i,value);
               Print(s.getColumnName(i),": ",value);
              }
            else if(i==1)
              {
               string value;
               s.getColumn(i,value);
               Print(s.getColumnName(i),": ",value);
              }
           }
        }
      else
         break;

      r=s.step();
     }
   while(r!=SQLITE_DONE);

//--- optional but recommended
   SQLite3::shutdown();
  }
//+------------------------------------------------------------------+