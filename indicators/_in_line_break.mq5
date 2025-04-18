
//+-----------------------------------------------------------------+
//|                                                  3LineBreak.mq5 |
//|                              Copyright © 2004, Poul_Trade_Forum |
//|                                                        Aborigen |
//|                                         http://forex.kbpauk.ru/ |
//+-----------------------------------------------------------------+

#property copyright " Copyright © 2004, Poul_Trade_Forum"
#property link      " http://forex.kbpauk.ru/"
#property version   "1.00"

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

#property indicator_chart_window

#property indicator_buffers 3
#property indicator_plots   1

#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrGreen, C'178,106,34'
// #property indicator_width1 2
// #property indicator_label1  "UpTend; DownTrend;"

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

input int LinesBreak = 3;

double HBuffer[];
double LBuffer[];
double CBuffer[];
bool   Swing;

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

int OnInit(void) {
   SetIndexBuffer(0, HBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, LBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, CBuffer, INDICATOR_COLOR_INDEX);

   ArraySetAsSeries(HBuffer, true);
   ArraySetAsSeries(LBuffer, true);
   ArraySetAsSeries(CBuffer, true);

   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

   string short_name = MQLInfoString(MQL_PROGRAM_NAME);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);

   return (INIT_SUCCEEDED);
}

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
   //---
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low,  true);

   bool swing = Swing;

   for (int i = rates_total - (prev_calculated ? prev_calculated : LinesBreak + 1); 0 <= i; i--) {
      if (rates_total != prev_calculated && 0 == i) Swing = swing;

      double H = high[ArrayMaximum(high, i + 1, LinesBreak)];
      double L = low [ArrayMinimum(low,  i + 1, LinesBreak)];

      if ( swing && low [i] < L) swing = false;
      if (!swing && high[i] > H) swing = true;

      HBuffer[i] = high[i];
      LBuffer[i] = low [i];

      if (swing) CBuffer[i] = 0;
      else       CBuffer[i] = 1;
   }

   return(rates_total);
}

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+
