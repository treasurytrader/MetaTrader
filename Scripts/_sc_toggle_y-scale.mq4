
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnStart() {
   //---
   if (PERIOD_M5 != _Period)
      ChartSetInteger(0, CHART_SHOW_PRICE_SCALE, 0, !ChartGetInteger(0, CHART_SHOW_PRICE_SCALE));
   //---
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
