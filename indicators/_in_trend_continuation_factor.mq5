
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_separate_window

#ifdef __MQL5__
 #property indicator_buffers 6
 #property indicator_plots   2
#else
 #property indicator_buffers 2
#endif

#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE

#ifdef __MQL5__
 #property indicator_type3 DRAW_NONE
 #property indicator_type4 DRAW_NONE
 #property indicator_type5 DRAW_NONE
 #property indicator_type6 DRAW_NONE
#endif

#property indicator_color1 clrRoyalBlue
#property indicator_color2 clrRed
/*
#property indicator_level1 0
#property indicator_levelcolor clrSlateGray
#property indicator_levelstyle STYLE_SOLID
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input int period = 35;

double minuscf[];
double minuschange[];
double minustcf[];
double pluscf[];
double pluschange[];
double plustcf[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit(void) {

#ifdef __MQL4__
   IndicatorBuffers(6);
#endif

   SetIndexBuffer(0, plustcf);  // SetIndexLabel(0, "plus");
   SetIndexBuffer(1, minustcf); // SetIndexLabel(1, "minus");
   SetIndexBuffer(2, pluschange);
   SetIndexBuffer(3, minuschange);
   SetIndexBuffer(4, pluscf);
   SetIndexBuffer(5, minuscf);

#ifdef __MQL5__
   // true == 역순 ...0
   ArraySetAsSeries(plustcf,     true);
   ArraySetAsSeries(minustcf,    true);
   ArraySetAsSeries(pluschange,  true);
   ArraySetAsSeries(minuschange, true);
   ArraySetAsSeries(pluscf,      true);
   ArraySetAsSeries(minuscf,     true);
#endif

   SetHLine("level", 0.0, clrSlateGray);

   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnDeinit(const int reason) {
   ObjectDelete(0, "level");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {

#ifdef __MQL5__
   ArraySetAsSeries(high,  true);
   ArraySetAsSeries(low,   true);
   ArraySetAsSeries(close, true);
#endif

   if (!prev_calculated) {
      for (int i = rates_total - 2, j = rates_total - (period + 2); j <= i; i--) {
         pluschange[i] = minuschange[i] = pluscf[i] = minuscf[i] = high[i] - low[i];
         plustcf[i]    = minustcf[i]    = EMPTY_VALUE;
      }
   }

   for (int i = rates_total - (prev_calculated ? prev_calculated : period + 2); 0 <= i; i--) {

      double change = close[i] - close[i + 1];
      pluschange[i] = minuschange[i] = pluscf[i] = minuscf[i] = 0.0;
      plustcf[i]    = minustcf[i] = 0.0;

      if (0 < change) {
         pluschange[i] = change;
         pluscf[i]     = pluschange[i] + pluscf[i + 1];
      }
      else if (0 > change) {
         minuschange[i] = -change;
         minuscf[i]     = minuschange[i] + minuscf[i + 1];
      }

      for (int k = 0; k < period; k++) {
         plustcf[i]  +=  pluschange[i + k] - minuscf[i + k];
         minustcf[i] += minuschange[i + k] -  pluscf[i + k];
      }
   }

   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void SetHLine(string name, double value, color clr) {
   ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_HLINE, ChartWindowFind(), 0, value);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   // ObjectMove(0, name, 0, time, 100);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
