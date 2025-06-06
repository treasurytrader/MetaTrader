
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_chart_window

#property indicator_buffers 2

#property indicator_color1 C'34,106,178'
#property indicator_color2 clrFireBrick

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input int period1 = 26;
input int period2 = 12;

double buffer0[], buffer1[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit(void) {
   //---
   IndicatorBuffers(3);

   SetIndexBuffer(0, buffer0);
   SetIndexBuffer(1, buffer1);

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

      buffer0[i] = iMA(NULL, 0, period1, 0, MODE_EMA, PRICE_CLOSE, i);
      buffer1[i] = iMA(NULL, 0, period2, 0, MODE_EMA, PRICE_CLOSE, i);
   }

   return (rates_total);
   //---
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
