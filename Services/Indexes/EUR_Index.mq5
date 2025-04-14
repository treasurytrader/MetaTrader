//+------------------------------------------------------------------+
//|                                                    EUR_Index.mq5 |
//|                             Copyright 2000-2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property service
#property copyright "Copyright 2000-2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#define CUSTOM_SYMBOL     "EURX.synthetic"
#define CUSTOM_GROUP      "Synthetics"
#define BASKET_SIZE       5
#define MAIN_COEFF        34.38805726

#include "CurrencyIndex.mqh"

SymbolWeight ExtWeights[BASKET_SIZE]=
  {
   { "EURUSD", 0.3155 },
   { "EURGBP", 0.3056 },
   { "EURJPY", 0.1891 },
   { "EURCHF", 0.1113 }, 
   { "EURSEK", 0.0785 }
  };
//+------------------------------------------------------------------+
//| Service program start function                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(!InitService(CUSTOM_SYMBOL,CUSTOM_GROUP))
      return;
//---
   while(!IsStopped())
     {
      ProcessTick(CUSTOM_SYMBOL);
      Sleep(10);
     }
//---
   Print(CUSTOM_SYMBOL," datafeed stopped");
  }
//+------------------------------------------------------------------+
