
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_plots   2

#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE

#property indicator_color1 clrDarkCyan
#property indicator_color2 clrCrimson

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Upper[];
double Lower[];

bool   BuySignal;
bool   SellSignal;
int    CurrentBar;

double boxBottom       = DBL_MAX;
double boxTop          = DBL_MIN;
bool   buySignal;
double currentBarHigh  = DBL_MIN;
double currentBarLow   = DBL_MAX;
bool   isRealtime;
int    savedCurrentBar = -1;
bool   sellSignal;
int    startBarActBox;
int    state;

int    prevCurrentBar   = -1;
double boxBottomSeries[];
double boxTopSeries[];
double currentBarHighSeries[];
double currentBarLowSeries[];
int    startBarActBoxSeries[];
int    stateSeries[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit(void) {

   SetIndexBuffer(0, Upper);
   SetIndexBuffer(1, Lower);

#ifdef __MQL5__
   ArraySetAsSeries(Upper, true);
   ArraySetAsSeries(Lower, true);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
#else
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
#endif

   ArraySetAsSeries(boxBottomSeries,      true);
   ArraySetAsSeries(boxTopSeries,         true);
   ArraySetAsSeries(currentBarHighSeries, true);
   ArraySetAsSeries(currentBarLowSeries,  true);
   ArraySetAsSeries(startBarActBoxSeries, true);
   ArraySetAsSeries(stateSeries,          true);

   IndicatorSetString(INDICATOR_SHORTNAME, MQLInfoString(MQL_PROGRAM_NAME));

   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+

void OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
#ifdef __MQL5__
   ArraySetAsSeries(high, true);
   ArraySetAsSeries( low, true);
#endif

   if (rates_total > ArraySize(stateSeries)) {
      ArrayResize(boxBottomSeries,      rates_total);
      ArrayResize(boxTopSeries,         rates_total);
      ArrayResize(currentBarHighSeries, rates_total);
      ArrayResize(currentBarLowSeries,  rates_total);
      ArrayResize(startBarActBoxSeries, rates_total);
      ArrayResize(stateSeries,          rates_total);
   }
   /*
   if (!prev_calculated) {
      int length = fmax(rates_total - (Length), rates_total - 1);
      for (int i = rates_total - 1; length <= i; i--)
         buffer0[i] = buffer1[i] = buffer2[i] = EMPTY_VALUE;
   }
   */
   for (int idx = rates_total - (prev_calculated ? prev_calculated : 2); 0 <= idx; idx--) {

      Upper[idx] = EMPTY_VALUE;
      Lower[idx] = EMPTY_VALUE;

      BuySignal  = false;
      SellSignal = false;
      CurrentBar = rates_total - (idx + 1);

      // if (BarsArray[idx].BarsType.IsRemoveLastBarSupported && CurrentBar < prevCurrentBar)
      if (CurrentBar < prevCurrentBar) {
         boxBottom      = boxBottomSeries[idx];
         boxTop         = boxTopSeries[idx];
         currentBarHigh = currentBarHighSeries[idx];
         currentBarLow  = currentBarLowSeries[idx];
         startBarActBox = startBarActBoxSeries[idx];
         state          = stateSeries[idx];
      }

      if (savedCurrentBar == -1) {
         currentBarHigh  = high[idx];
         currentBarLow   = low[idx];
         state           = GetNextState();
         savedCurrentBar = CurrentBar;
      } else if (savedCurrentBar != CurrentBar) {
         // Check for new bar
         // currentBarHigh = (isRealtime && Calculate == Calculate.OnEachTick) ? high[1] : high[idx];
         // currentBarLow = (isRealtime && Calculate == Calculate.OnEachTick) ? low[1] : low[idx];
         currentBarHigh = (isRealtime) ? high[idx + 1] : high[idx];
         currentBarLow  = (isRealtime) ?  low[idx + 1] :  low[idx];

         // Today buy/sell signal is triggered
         if ((state == 5 && currentBarHigh > boxTop) || (state == 5 && currentBarLow < boxBottom)) {
            if (state == 5 && currentBarHigh > boxTop) BuySignal  = true;
            else                                       SellSignal = true;

            state          = 0;
            startBarActBox = CurrentBar;
         }

         state = GetNextState();
         // Draw with today
         if (boxBottom == DBL_MAX)
            for (int i = CurrentBar - startBarActBox; i >= 0; i--) {
               Upper[idx + i] = boxTop;
            }
         else
            for (int i = CurrentBar - startBarActBox; i >= 0; i--) {
               Upper[idx + i] = boxTop;
               Lower[idx + i] = boxBottom;
            }
      } else {
         isRealtime = true;

         // Today buy/sell signal is triggered
         if ((state == 5 && currentBarHigh > boxTop) || (state == 5 && currentBarLow < boxBottom)) {
            if (state == 5 && currentBarHigh > boxTop) BuySignal  = true;
            else                                       SellSignal = true;

            startBarActBox = CurrentBar + 1;
            state          = 0;
         }

         // Draw with today
         if (boxBottom == DBL_MAX) {
            Upper[idx] = boxTop;
         } else {
            Upper[idx] = boxTop;
            Lower[idx] = boxBottom;
         }
      }

      // if (BarsArray[idx].BarsType.IsRemoveLastBarSupported)
         boxBottomSeries[idx]      = boxBottom;
         boxTopSeries[idx]         = boxTop;
         currentBarHighSeries[idx] = currentBarHigh;
         currentBarLowSeries[idx]  = currentBarLow;
         startBarActBoxSeries[idx] = startBarActBox;
         stateSeries[idx]          = state;
         prevCurrentBar            = CurrentBar;
      // }
   }

   //---
   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetNextState() {

   switch (state) {
      case 0:
             boxTop    = currentBarHigh;
             boxBottom = DBL_MAX;
             return 1;

      case 1:
             if (boxTop > currentBarHigh) return 2;
             else {
                boxTop = currentBarHigh;
                return 1;
             }

      case 2:
             if (boxTop > currentBarHigh) {
                boxBottom = currentBarLow;
                return 3;
             }
             else {
                boxTop = currentBarHigh;
                return 1;
             }

      case 3:
             if (boxTop > currentBarHigh) {
                if (boxBottom < currentBarLow) return 4;
                else {
                   boxBottom = currentBarLow;
                return 3;
                }
             }
             else {
                boxTop    = currentBarHigh;
                boxBottom = DBL_MAX;
                return 1;
             }

      case 4:
             if (boxTop > currentBarHigh) {
                if (boxBottom < currentBarLow) return 5;
                else {
                   boxBottom = currentBarLow;
                   return 3;
                }
             }
             else {
                boxTop    = currentBarHigh;
                boxBottom = DBL_MAX;
                return 1;
             }

      case 5: return 5;

      default: // Should not happen

      return state;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
