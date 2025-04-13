
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_chart_window

#property indicator_buffers 1
#property indicator_color1 clrTeal

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

extern double percent = 2.0;

double ZzBuffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit() {
   //---
   IndicatorBuffers(1);

   SetIndexBuffer(0, ZzBuffer);
   SetIndexEmptyValue(0, 0.0);
   SetIndexStyle(0, DRAW_SECTION);

   return (INIT_SUCCEEDED);
   //---
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnDeinit(const int reason) {
   //---
   //---
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
   //---
   static int lasthighpos = 0, lastlowpos = 0;
   static double lasthigh = 0.0, lastlow = 0.0, curzz = 0.0;

   static double up = 1.0 + (percent / 100.0);
   static double dn = 1.0 - (percent / 100.0);

   //---
   if (!prev_calculated) {

      ArrayInitialize(ZzBuffer, 0.0);
      lasthigh = lastlow = curzz = high[rates_total - 1] - low[rates_total - 1];
      ZzBuffer[rates_total - 1] = curzz;
   }

   //---
   for (int i = rates_total - (prev_calculated ? prev_calculated : 1); 0 <= i; i--) {

      bool hi = lastlow  * up < high[i] && curzz < high[i];
      bool lo = lasthigh * dn >  low[i] && curzz >  low[i];

      if (lo && hi) {
         lo = (bool)lastlowpos;
         hi = (bool)lasthighpos;
      }

      if (lo && !hi) {
         if (lastlowpos) ZzBuffer[lastlowpos] = 0.0;
         lastlowpos  = i;
         lasthighpos = 0;
         ZzBuffer[i] = lastlow = curzz = low[i];
      }

      if (!lo && hi) {
         if (lasthighpos) ZzBuffer[lasthighpos] = 0.0;
         lasthighpos = i;
         lastlowpos = 0;
         ZzBuffer[i] = lasthigh = curzz = high[i];
      }

   }

   return (rates_total);
   //---
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
