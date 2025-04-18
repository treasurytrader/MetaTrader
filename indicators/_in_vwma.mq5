
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_chart_window

#property indicator_buffers 1
#property indicator_plots   1

#property indicator_color1 clrFireBrick
#property indicator_type1  DRAW_LINE

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input int period = 20;

double buffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit(void) {
   SetIndexBuffer(0, buffer, INDICATOR_DATA);
   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnDeinit(const int reason) {
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

   for (int i = (prev_calculated ? prev_calculated - 1 : period); rates_total > i; i++) {

      buffer[i] = VWMA(close, tick_volume, period, i);

   }

   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// VWMA - Volume Weighted Moving Average

double VWMA(const double &price[], const long &volume[], int per, int bar) {

   double sum  = 0;
   double vwma = 0;
   long weight = 0;

   for (int i = 0; per > i; i++) {
      sum    +=  price[bar - i] * volume[bar - i];
      weight += volume[bar - i];
   }

   if (0 < weight) vwma = sum / weight;

   return (vwma);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/* 예스트레이더용
// _vwma

input: period(20);
vars : i(0);

value1 = 0;
value2 = 0;

for i = 0 to period - 1 {
   value1 = value1 + (volume[i] * close[i]);
   value2 = value2 + volume[i];
}

value10 = value1 / value2;

plot1(value10, "vwma");
*/