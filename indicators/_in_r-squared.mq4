#property description "R-Squared"
#property strict

//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 clrDimGray
#property indicator_color2 clrDarkGreen

//---- input parameters
extern int period = 14;  // Period of indicator

//---- indicator buffers
double buffer1[], buffer2[], buffer3[];

//--- global variables
double level;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator initialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnInit(void) {
  //--- checking input data
  //--- indicator buffers
  IndicatorBuffers(3);
  SetIndexBuffer(0, buffer1); SetIndexLabel(0, "R-Squared");
  SetIndexBuffer(1, buffer2); SetIndexLabel(1, "R-Squared");
  SetIndexBuffer(2, buffer3);
  //--- drawing settings
  IndicatorDigits(2);
  SetIndexStyle(0, DRAW_HISTOGRAM);
  SetIndexStyle(1, DRAW_HISTOGRAM);
  SetIndexStyle(2, DRAW_NONE);
  //--- horizontal level
  level = CalcLevel(period);
  SetLevelValue(0, level);
  SetLevelValue(1, 1.0 - level);
  IndicatorSetInteger(INDICATOR_LEVELCOLOR, 1973790);
  IndicatorSetInteger(INDICATOR_LEVELSTYLE, -1);
  IndicatorSetInteger(INDICATOR_LEVELWIDTH, -1);
  //--- set short name
  IndicatorShortName(WindowExpertName() + " (" + (string)period + ")");
  //--- set global variables
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

int OnCalculate(const int rates_total,     // size of input time series
                const int prev_calculated, // bars handled in previous call
                const datetime &time[],    // Time
                const double &open[],      // Open
                const double &high[],      // High
                const double &low[],       // Low
                const double &close[],     // Close
                const long &tick_volume[], // Tick Volume
                const long &volume[],      // Real Volume
                const int &spread[])       // Spread
{
  //--- global variables
  //--- initialization of zero
  if (!prev_calculated) {
    for (int i = rates_total - 1, j = rates_total - (period + 1); j <= i; i--) {
      buffer1[i] = buffer2[i] = buffer3[i] = EMPTY_VALUE;
    }
  }
  //--- the main cycle of indicator calculation
  for (int i = rates_total - (prev_calculated ? prev_calculated : period + 1);
       0 <= i; i--) {
    buffer3[i] = RSquared(close, period, i);

    if (level < buffer3[i] && buffer3[i + 1] < buffer3[i]) {
      buffer1[i] = EMPTY_VALUE;
      buffer2[i] = buffer3[i];
    } else {
      buffer1[i] = buffer3[i];
      buffer2[i] = EMPTY_VALUE;
    }
  }
  //----
  return (rates_total);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// R-Squared
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

double RSquared(const double &value[], int length, int bar) {
  static double Ex = length * (length - 1) * 0.5;
  static double Ex2 = (length - 1.0) * length * (2.0 * length - 1.0) / 6.0;

  double Ey = 0.0, Exy = 0.0, Ey2 = 0.0;

  for (int i = 0; i < length; i++) {
    // Ex  += i;
    // Ex2 += i * i;
    Ey += value[bar + i];
    Exy += value[bar + i] * i;
    Ey2 += value[bar + i] * value[bar + i];
  }

  double q1 = length * Exy - Ex * Ey;
  double q2 = length * Ex2 - Ex * Ex;
  double q3 = length * Ey2 - Ey * Ey;

  double result = 0.0;
  if (q1 && q2 && q3) result = q1 / sqrt(q2 * q3);
  result *= result;

  return (result);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// R-Squared CalcLevel
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

double CalcLevel(double per) {
  double per1, lev1, lenper, levdif;
  if (120 < per) return (0.03);
  else if (60 < per) { per1 = 60; lev1 = 0.06; lenper = 60; levdif = 0.03; }
  else if (50 < per) { per1 = 50; lev1 = 0.08; lenper = 10; levdif = 0.02; }
  else if (30 < per) { per1 = 30; lev1 = 0.13; lenper = 20; levdif = 0.05; }
  else if (25 < per) { per1 = 25; lev1 = 0.16; lenper =  5; levdif = 0.03; }
  else if (20 < per) { per1 = 20; lev1 = 0.20; lenper =  5; levdif = 0.04; }
  else if (14 < per) { per1 = 14; lev1 = 0.27; lenper =  6; levdif = 0.07; }
  else if (10 < per) { per1 = 10; lev1 = 0.40; lenper =  4; levdif = 0.13; }
  else if ( 5 < per) { per1 =  5; lev1 = 0.77; lenper =  5; levdif = 0.37; }
  else return (0.77);

   double result = lev1 - (per - per1) * (levdif / lenper);
   return (result);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~