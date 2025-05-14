
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_separate_window

#property indicator_buffers 3

#property indicator_color1 clrDarkSlateGray
#property indicator_color2 clrSilver
#property indicator_color3 clrRed

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input int fast   = 12;
input int slow   = 26;
input int signal = 9;

double buffer0[];
double buffer1[];
double buffer2[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit(void) {
   //---

   IndicatorBuffers(3);

   SetIndexBuffer(0, buffer0);
   SetIndexBuffer(1, buffer1);
   SetIndexBuffer(2, buffer2);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_LINE);

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
   for (int i = rates_total - (prev_calculated ? prev_calculated : 1); 0 <= i; i--) {
      buffer0[i] = 0.0;
      buffer1[i] = iMACD(NULL, PERIOD_CURRENT, fast, slow, signal, PRICE_CLOSE, MODE_MAIN, i);
      buffer2[i] = iMACD(NULL, PERIOD_CURRENT, fast, slow, signal, PRICE_CLOSE, MODE_SIGNAL, i);
   }

   return (rates_total);
   //---
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
