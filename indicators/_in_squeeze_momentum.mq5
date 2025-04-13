
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_separate_window

#property indicator_buffers 9
#property indicator_plots 6

#property indicator_type1 DRAW_HISTOGRAM
#property indicator_type2 DRAW_HISTOGRAM
#property indicator_type3 DRAW_HISTOGRAM
#property indicator_type4 DRAW_HISTOGRAM
#property indicator_type5 DRAW_ARROW
#property indicator_type6 DRAW_ARROW

#property indicator_color1 clrDimGray
#property indicator_color2 C'50,50,50'
#property indicator_color3 clrDimGray
#property indicator_color4 C'50,50,50'
#property indicator_color5 clrDimGray
#property indicator_color6 C'50,50,50'
/*
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input int period = 20;

double On[], Off[], linregsrc[], range[];
double upup[], updn[], dndn[], dnup[], linreg[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit()
  {
    SetIndexBuffer(0, upup);
    SetIndexBuffer(1, updn);
    SetIndexBuffer(2, dndn);
    SetIndexBuffer(3, dnup);
    SetIndexBuffer(4, On);
    SetIndexBuffer(5, Off);
    SetIndexBuffer(6, linregsrc);
    SetIndexBuffer(7, linreg);
    SetIndexBuffer(8, range);
#ifdef __MQL4__
    SetIndexArrow(4, 167);
    SetIndexArrow(5, 167);
#else
    ArraySetAsSeries(upup, true);
    ArraySetAsSeries(updn, true);
    ArraySetAsSeries(dndn, true);
    ArraySetAsSeries(dnup, true);
    ArraySetAsSeries(On, true);
    ArraySetAsSeries(Off, true);
    ArraySetAsSeries(linregsrc, true);
    ArraySetAsSeries(linreg, true);
    ArraySetAsSeries(range, true);

    PlotIndexSetInteger(4, PLOT_ARROW, 158);
    PlotIndexSetInteger(5, PLOT_ARROW, 158);
#endif
    IndicatorSetString(INDICATOR_SHORTNAME, "\0"/*MQLInfoString(MQL_PROGRAM_NAME)*/);

    return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
  {
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
                const long &volume[], const int &spread[])
  {
#ifdef __MQL5__
    ArraySetAsSeries( high, true);
    ArraySetAsSeries(  low, true);
    ArraySetAsSeries(close, true);
#endif

    for (int i = rates_total - (prev_calculated ? prev_calculated : period + 1); 0 <= i; i--)
      {
        double sma = SMA(close, period, i);
        // double dev = iStdDev(NULL, 0, period, 0, MODE_SMA, PRICE_CLOSE, i);
        double dev = 0.0;
        for (int k = 0; period > k; k++) dev += pow(close[i + k] - sma, 2);
        dev = sqrt(dev / period);

        // double atr = iATR(NULL, PERIOD_CURRENT, period, i);
        range[i]   = tr(high, low, close, i);
        double atr = SMA(range, period, i);
        bool   sqz = (atr > dev);

        On[i]  = !sqz ? 0 : EMPTY_VALUE;
        Off[i] =  sqz ? 0 : EMPTY_VALUE;

        double hi = high[iHighest(NULL, 0, MODE_HIGH, period, i)];
        double lo = low [ iLowest(NULL, 0,  MODE_LOW, period, i)];
        //  double ma = iMA(NULL, 0, period, 0, MODE_SMA, PRICE_CLOSE, i);

        linregsrc[i] = close[i] - ((((hi + lo) / 2.0) + sma) / 2.0);
        linreg[i]    = linreg(linregsrc, period, i);

        upup[i] = linreg[i] > 0 && linreg[i] >= nz(linreg[i+1]) ? linreg[i] : EMPTY_VALUE;
        updn[i] = linreg[i] > 0 && linreg[i] <  nz(linreg[i+1]) ? linreg[i] : EMPTY_VALUE;
        dndn[i] = linreg[i] < 0 && linreg[i] <= nz(linreg[i+1]) ? linreg[i] : EMPTY_VALUE;
        dnup[i] = linreg[i] < 0 && linreg[i] >  nz(linreg[i+1]) ? linreg[i] : EMPTY_VALUE;
      }

    return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double linreg(double &src[], int p, int i)
  {
    double Ey = 0;
    double Exy = 0;
    double c;

    for (int x = 0; x <= p - 1; x++)
      {
        c    = src[x + i];
        Ey  += c;
        Exy += x * c;
      }

    double Ex   = p * (p - 1) * 0.5;
    double Ex2  = (p - 1) * p * (2 * p - 1) / 6;
    double Sum2 = Ex * Ey;
    double q1   = p * Exy - Sum2;
    double q2   = Ex * Ex - p * Ex2;

    double slope     = q2 != 0 ? q1 / q2 : 0;
    double intercept = (Ey - slope * Ex) / p;
    double linregval = intercept + slope * (p - 1);

    return (linregval);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double tr(const double &high[], const double &low[], const double &close[], int i)
  {
    double t1 = high[i] - low[i];
    double t2 = fabs(high[i] - close[i + 1]);
    double t3 = fabs(low[i]  - close[i + 1]);
    return fmax(fmax(t1, t2), t3);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double SMA(const double &array[], int per, int bar)
  {
    double sum = 0;
    for (int i = 0; per > i; i++) sum += array[bar + i];
    return (sum / per);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double nz(double check, double val = 0)
  {
    return (check == EMPTY_VALUE ? val : check);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
