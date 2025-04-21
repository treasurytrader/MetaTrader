
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

int TimeDay(datetime dt) {

   MqlDateTime dt_struct;
   TimeToStruct(dt, dt_struct);

   return (dt_struct.day);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
