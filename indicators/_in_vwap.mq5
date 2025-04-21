
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property indicator_chart_window

#property indicator_buffers 3
#property indicator_plots   1

#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_NONE
#property indicator_type3 DRAW_NONE

#property indicator_color1 clrSlateGray

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double buffer0[], buffer1[], buffer2[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit() {

   SetIndexBuffer(0, buffer0);
   SetIndexBuffer(1, buffer1);
   SetIndexBuffer(2, buffer2);

   return (INIT_SUCCEEDED);
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

void OnChartEvent(const int id, const long &lparam,
                  const double &dparam, const string &sparam) {
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

   if (!prev_calculated) {

      double val = (high[0] + low[0] + close[0]) / 3.0;
      double vol = (double)fmax(tick_volume[0], 1);

      buffer1[0] = vol * val;
      buffer2[0] = vol;

      buffer0[0] = buffer1[0] / buffer2[0];

   }

   for (int i = (prev_calculated ? prev_calculated - 1 : 1); rates_total > i; i++) {

      double val = (high[i] + low[i] + close[i]) / 3.0;
      double vol = (double)fmax(tick_volume[i], 1);

      if (TimeDay(time[i - 1]) != TimeDay(time[i])) {

         buffer1[i] = vol * val;
         buffer2[i] = vol;

         PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, i);

      } else {

         buffer1[i] = buffer1[i - 1] + (vol * val);
         buffer2[i] = buffer2[i - 1] + vol;

      }

      buffer0[i] = buffer1[i] / buffer2[i];
   }

   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#ifdef __MQL5__
int TimeDay(datetime dt) {
   MqlDateTime dt_struct;
   TimeToStruct(dt, dt_struct);
   return (dt_struct.day);
}
#endif
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/* 예스트레이더용
// _vwap_bands :: 표준편차 계산에서 for 루틴을 제거한 버전

if (bdate[1] != bdate) then {
   value1 = avg(high, low, close);
   value2 = volume * value1 * value1;
   value3 = volume * value1;
   value4 = volume;
}
else {
   value1 = avg(high, low, close);
   value2 = value2[1] + (volume * value1 * value1);
   value3 = value3[1] + (volume * value1);
   value4 = value4[1] + volume;
}

value10 = value3 / value4;

value5	= squareroot(max((value2 / value4) - (value10 * value10), 0));

value11 = value10 + value5;
value12 = value10 - value5;

plot1(value10, "vwap");
plot2(value11, "upper");
plot3(value12, "lower");
*/