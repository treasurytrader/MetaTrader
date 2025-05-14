
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_separate_window

#property indicator_buffers 2

#property indicator_type1 DRAW_HISTOGRAM
#property indicator_type2 DRAW_HISTOGRAM

#property indicator_color1 clrGreen
#property indicator_color2 C'178,106,34'

#property indicator_width1 5
#property indicator_width2 5

#property indicator_minimum 0
#property indicator_maximum 1

#property indicator_height 11

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input ENUM_TIMEFRAMES time_frame = PERIOD_M15;
input int fast   = 12;
input int slow   = 26;
input int signal = 9;

double buffer0[];
double buffer1[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit(void) {

   IndicatorBuffers(2);

   SetIndexBuffer(0, buffer0);
   SetIndexBuffer(1, buffer1);

   IndicatorDigits(0);
   IndicatorSetString(INDICATOR_SHORTNAME, "\0"/*MQLInfoString(MQL_PROGRAM_NAME)*/);

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
   int shift = iBarShift(NULL, PERIOD_CURRENT, iTime(NULL, time_frame, 0)) + 1;

   for (int i = rates_total - (prev_calculated ? prev_calculated - shift : 1); 0 <= i; i--) {

      shift = 0 < i ? iBarShift(NULL, time_frame, time[i]) : 0;

      if (0.0 < iMACD(NULL, time_frame, fast, slow, signal, PRICE_CLOSE, MODE_MAIN, shift)) {
         buffer0[i] = 1;
         buffer1[i] = EMPTY_VALUE;
      }
      else {
         buffer0[i] = EMPTY_VALUE;
         buffer1[i] = 1;
      }
   }

   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
