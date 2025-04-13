
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property indicator_chart_window

#property indicator_buffers 3
#property indicator_plots 3

#property indicator_color1 C'80,80,80'
#property indicator_color2 C'80,80,80'
#property indicator_color3 C'80,80,80'

#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input int   indPeriod = 16;          // Period
      color indColor  = C'50,50,50'; // Color

double buffer0[];
double buffer1[];
double buffer2[];
double upperLine, lowerLine, middleLine;
// int start, bar;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit()
  {
    /*
    indInit(0, buffer0, "Donchian Channel High");
    indInit(1, buffer1, "Donchian Channel Low");
    indInit(2, buffer2, "Donchian Channel Middle");
    */

    SetIndexBuffer(0, buffer0);
    SetIndexBuffer(1, buffer1);
    SetIndexBuffer(2, buffer2);
    IndicatorSetString(INDICATOR_SHORTNAME, "Donchian (" + IntegerToString(indPeriod) + ")");

    return(INIT_SUCCEEDED);
  }

void indInit(int index, double &buffer[], string label)
  {
    SetIndexBuffer(index, buffer, INDICATOR_DATA);
    PlotIndexSetInteger(index, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(index, PLOT_LINE_WIDTH, 0);
    // PlotIndexSetInteger(index, PLOT_DRAW_BEGIN, indPeriod - 1);
    // PlotIndexSetInteger(index, PLOT_SHIFT, 1);
    PlotIndexSetInteger(index, PLOT_LINE_COLOR, indColor);
    PlotIndexSetString(index, PLOT_LABEL, label);
    PlotIndexSetDouble(index, PLOT_EMPTY_VALUE, EMPTY_VALUE);
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
    if (rates_total < indPeriod) return (0);

    //--- preliminary calculations
    int start;
    if (0 == prev_calculated)
      start = indPeriod;
    else
      start = prev_calculated - 1;

    //--- the main loop of calculations
    for (int i = start; rates_total > i && !IsStopped(); i++)
      {
        buffer0[i] = Highest(high, indPeriod, i);
        buffer1[i] = Lowest(low, indPeriod, i);
        buffer2[i] = (buffer0[i] + buffer1[i]) / 2.0;
      }

    //--- OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Highest(const double &array[], const int range, const int index)
  {
    double res = array[index];
    for (int i = index - 1; index - range < i && 0 <= i; i--)
      {
        if (res < array[i]) res = array[i];
      }
    return (res);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Lowest(const double &array[], const int range, const int index)
  {
    double res = array[index];
    for(int i = index - 1; index - range < i && 0 <= i; i--)
      {
        if (res > array[i]) res = array[i];
      }
    return(res);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
