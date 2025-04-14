//+------------------------------------------------------------------+
//|                                                    USD_Index.mq5 |
//|                             Copyright 2000-2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property service
#property copyright "Copyright 2000-2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#define CUSTOM_SYMBOL     "USDX.synthetic"
#define CUSTOM_GROUP      "Synthetics"
#define BASKET_SIZE       6
#define MAIN_COEFF        50.14348112

#include "CurrencyIndex.mqh"

SymbolWeight ExtWeights[BASKET_SIZE]=
  {
     { "EURUSD",-0.576 },
     { "USDJPY", 0.136 },
     { "GBPUSD",-0.119 },
     { "USDCAD", 0.091 },
     { "USDSEK", 0.042 },
     { "USDCHF", 0.036 } 
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
