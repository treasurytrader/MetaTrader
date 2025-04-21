
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_chart_window

#property indicator_buffers 6
#property indicator_plots   3

#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_type4 DRAW_NONE
#property indicator_type5 DRAW_NONE
#property indicator_type6 DRAW_NONE

#property indicator_color1 clrSlateGray
#property indicator_color2 clrDodgerBlue
#property indicator_color3 clrFireBrick

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double buffer0[], buffer1[], buffer2[], buffer3[], buffer4[], buffer5[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit() {

   SetIndexBuffer(0, buffer0);
   SetIndexBuffer(1, buffer1);
   SetIndexBuffer(2, buffer2);
   SetIndexBuffer(3, buffer3);
   SetIndexBuffer(4, buffer4);
   SetIndexBuffer(5, buffer5);

   ArraySetAsSeries(buffer0, true);
   ArraySetAsSeries(buffer1, true);
   ArraySetAsSeries(buffer2, true);
   ArraySetAsSeries(buffer3, true);
   ArraySetAsSeries(buffer4, true);
   ArraySetAsSeries(buffer5, true);

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
#ifdef __MQL5__
   ArraySetAsSeries( time, true);
   ArraySetAsSeries( high, true);
   ArraySetAsSeries(  low, true);
   ArraySetAsSeries(close, true);
#endif

   if (!prev_calculated) {

      int    i   = rates_total - 1;
      double val = (high[i] + low[i] + close[i]) / 3.0;
      double vol = (double)fmax(tick_volume[i], 1);

      buffer3[i] = vol * val * val;
      buffer4[i] = vol * val;
      buffer5[i] = vol;

      buffer0[i] = buffer4[i] / buffer5[i];

      double dev = sqrt(fmax((buffer3[i] / buffer5[i]) - (buffer0[i] * buffer0[i]), 0));

      buffer1[i] = buffer0[i] + dev;
      buffer2[i] = buffer0[i] - dev;
      // for (int i = rates_total - 1, k = rates_total - 13; k <= i; i--) {}
   }

   for (int i = rates_total - (prev_calculated ? prev_calculated : 2); 0 <= i; i--) {

      double val = (high[i] + low[i] + close[i]) / 3.0;
      double vol = (double)fmax(tick_volume[i], 1);

      if (TimeDay(time[i + 1]) != TimeDay(time[i])) {

         buffer3[i] = vol * val * val;
         buffer4[i] = vol * val;
         buffer5[i] = vol;

         PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, rates_total - i - 1);
         PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, rates_total - i - 1);
         PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, rates_total - i - 1);

      } else {
         buffer3[i] = buffer3[i + 1] + (vol * val * val);
         buffer4[i] = buffer4[i + 1] + (vol * val);
         buffer5[i] = buffer5[i + 1] + vol;
      }

      buffer0[i] = buffer4[i] / buffer5[i];

      //--- standard deviation
      /*
      double dev = 0.0;
      for (int k = 0; buffer5[i] > k; k++) dev += pow(close[i + k] - buffer0[i], 2);
      dev = sqrt(dev / buffer5[i]);
      */
      double dev = sqrt(fmax((buffer3[i] / buffer5[i]) - (buffer0[i] * buffer0[i]), 0));

      buffer1[i] = buffer0[i] + dev;
      buffer2[i] = buffer0[i] - dev;
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