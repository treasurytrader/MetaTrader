
//+-----------------------------------------------------------------+
//|                                               3LineBreak_V2.mq4 |
//|                              Copyright © 2004, Poul_Trade_Forum |
//|                                                        Aborigen |
//|                                         http://forex.kbpauk.ru/ |
//| minor changes for color and correct function names              |
//+-----------------------------------------------------------------+

#property copyright "Poul Trade Forum"
#property link      "http://forex.kbpauk.ru/"

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

#property indicator_chart_window

#property indicator_buffers 2

#property indicator_color1 clrGreen
#property indicator_color2 C'178,106,34'

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

input int LinesBreak = 3;

double HBuffer[];
double LBuffer[];
bool   Swing;

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

int OnInit(void) {
   SetIndexBuffer(0, HBuffer);
   SetIndexBuffer(1, LBuffer);

   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_HISTOGRAM);

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
   bool swing = Swing;

   for (int i = rates_total - (prev_calculated ? prev_calculated : LinesBreak + 1); 0 <= i; i--) {
      if (rates_total != prev_calculated && 0 == i) Swing = swing;

      double H = high[iHighest(NULL, 0, MODE_HIGH, LinesBreak, i + 1)];
      double L =  low[ iLowest(NULL, 0,  MODE_LOW, LinesBreak, i + 1)];

      if ( swing &&  low[i] < L) swing = false;
      if (!swing && high[i] > H) swing = true;

      if (swing) {
         HBuffer[i] = High[i];
         LBuffer[i] =  Low[i];
      }
      else {
         HBuffer[i] =  Low[i];
         LBuffer[i] = High[i];
      }
   }

   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

