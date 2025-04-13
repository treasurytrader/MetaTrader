
#property strict
#property indicator_chart_window

//--- indicator settings
#property indicator_buffers 3
// #property indicator_color1 clrDarkOrange
// #property indicator_color2 clrTeal
// #property indicator_color3 clrTeal

//--- input parameters
input int    period     = 13;
input double multiplier = 2.0;

//--- buffers
double buffer0[], buffer1[], buffer2[];

//--- global variables
int    windowindex;
string shortname;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator initialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnInit(void) {
  //--- checking input data
  //--- indicator buffers
  IndicatorBuffers(3);
  SetIndexBuffer(0, buffer0);
  SetIndexLabel(0, "regression");
  SetIndexBuffer(1, buffer1);
  SetIndexLabel(1, "resistance");
  SetIndexBuffer(2, buffer2);
  SetIndexLabel(2, "support");

  //--- drawing settings
  IndicatorDigits(_Digits);
  SetIndexStyle(0, DRAW_LINE, EMPTY, EMPTY, clrTeal);
  SetIndexStyle(1, DRAW_LINE, EMPTY, EMPTY, clrDimGray);
  SetIndexStyle(2, DRAW_LINE, EMPTY, EMPTY, clrDimGray);

  //--- horizontal level
  //--- set short name
  shortname = StringConcatenate(WindowExpertName(), " (");
  if (_Period < PERIOD_D1)
    shortname += StringConcatenate(DoubleToString((double)period / ((double)PERIOD_D1 / (double)_Period), 1), ", ");
  shortname += StringConcatenate(period, ")");
  IndicatorShortName(shortname);

  //--- set global variables
  windowindex = WindowFind(shortname);

  //--- initialization done
  return (INIT_SUCCEEDED);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator deinitialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OnDeinit(const int reason) {
  //---
  //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator iteration function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])

{
  //--- global variables
  for (int i = 0, j = rates_total - period; 3 > i; i++) SetIndexDrawBegin(i, j);

  //--- initialization of zero
  //--- the main cycle of indicator calculation
  //--- calculate linear regression
  static double sumx  = period * (period - 1.0) * 0.5;
  static double sumx2 = period * (period - 1.0) * (2.0 * period - 1.0) / 6.0;
  static double c = sumx2 * period - sumx * sumx;

  if (0.0 == c) {
    // Print("Error in linear regression!");
    return (0);
  }

  double sumy = 0.0, sumxy = 0.0;

  for (int i = 0; i < period; i++) {
    sumy  += close[i];
    sumxy += close[i] * i;
    // sumx  += i;
    // sumx2 += i * i;
  }

  double b = (sumxy * period - sumx * sumy) / c;
  double a = (sumy - sumx * b) / period;

  //---
  double sq = 0.0;

  for (int i = 0; i < period; i++) {
    buffer0[i] = a + b * i;
    sq += pow(close[i] - buffer0[i], 2);
  }
  sq = sqrt(sq / period) * multiplier;

  for (int i = 0; i < period; i++) {
    buffer1[i] = buffer0[i] + sq;
    buffer2[i] = buffer0[i] - sq;
  }

  //---
  return (rates_total);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~