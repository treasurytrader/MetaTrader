//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Heiken Ashi Smoothed.mq4
//  mod by Raff
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#property copyright "Copyright (c)2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
#property strict

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 clrRed
#property indicator_color2 clrRoyalBlue
#property indicator_color3 clrRed
#property indicator_color4 clrRoyalBlue
#property indicator_width3 3
#property indicator_width4 3

//--- parameters
extern int ma_period1 = 12;
extern int ma_period2 = 26;

//--- buffers
double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];
double buffer5[];
double buffer6[];
double buffer7[];
double buffer8[];

//--- global variables
int    windowindex;
string shortname;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator initialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnInit(void)
{
   //--- checking input data
   //--- indicator buffers mapping
   IndicatorBuffers(8);
   SetIndexBuffer(0, buffer1); SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexBuffer(1, buffer2); SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexBuffer(2, buffer3); SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexBuffer(3, buffer4); SetIndexEmptyValue(3, EMPTY_VALUE);
   SetIndexBuffer(4, buffer5); SetIndexEmptyValue(4, EMPTY_VALUE);
   SetIndexBuffer(5, buffer6); SetIndexEmptyValue(5, EMPTY_VALUE);
   SetIndexBuffer(6, buffer7); SetIndexEmptyValue(6, EMPTY_VALUE);
   SetIndexBuffer(7, buffer8); SetIndexEmptyValue(7, EMPTY_VALUE);

   //--- drawing settings
   IndicatorDigits(_Digits);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexStyle(3, DRAW_HISTOGRAM);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexStyle(6, DRAW_NONE);
   SetIndexStyle(7, DRAW_NONE);

   //--- horizontal level
   //--- set short name
   shortname = StringConcatenate(WindowExpertName(), " (", ma_period1, ", ", ma_period2, ")");
   IndicatorShortName(shortname);

   //--- set global variables
   windowindex = WindowFind(shortname);

   //--- initialization done
   return (INIT_SUCCEEDED);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator deinitialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OnDeinit(const int reason)
{
   //---
   //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator iteration function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnCalculate (const int rates_total,      // size of input time series
                 const int prev_calculated,  // bars handled in previous call
                 const datetime &time[],     // Time
                 const double &open[],       // Open
                 const double &high[],       // High
                 const double &low[],        // Low
                 const double &close[],      // Close
                 const long &tick_volume[],  // Tick Volume
                 const long &volume[],       // Real Volume
                 const int &spread[])        // Spread
{
   //--- global variables
   double maOpen, maClose, maLow, maHigh;
   double haOpen, haHigh, haLow, haClose;

   //--- initialization of zero
   if (!prev_calculated)
   {
      for (int i=rates_total-1,j=rates_total-2;j<=i;i--)
      {
         if (open[i] < close[i])
         {
            buffer1[i] = buffer5[i] = low[i];
            buffer2[i] = buffer6[i] = high[i];
         }
         else
         {
            buffer1[i] = buffer5[i] = high[i];
            buffer2[i] = buffer6[i] = low[i];
         }
         buffer3[i] = buffer7[i] = open[i];
         buffer4[i] = buffer8[i] = close[i];
      }
   }

   //--- the main cycle of indicator calculation
   for (int i=rates_total-(prev_calculated?prev_calculated:2);0<=i;i--)
   {
      int period = fmin(rates_total-i, ma_period1);
      maOpen  = SMA( open, period, i);
      maHigh  = SMA( high, period, i);
      maLow   = SMA(  low, period, i);
      maClose = SMA(close, period, i);

      haOpen  = (buffer7[i+1] + buffer8[i+1]) / 2;
      haClose = (maOpen + maHigh + maLow + maClose) / 4;
      haHigh  = fmax(maHigh, fmax(haOpen, haClose));
      haLow   = fmin( maLow, fmin(haOpen, haClose));

      if (haOpen < haClose)
      {
         buffer5[i] = haLow;
         buffer6[i] = haHigh;
      }
      else
      {
         buffer5[i] = haHigh;
         buffer6[i] = haLow;
      }
      buffer7[i] = haOpen;
      buffer8[i] = haClose;

      period = fmin(rates_total-i, ma_period2);
      buffer1[i] = LWMA(buffer5, period, i);
      buffer2[i] = LWMA(buffer6, period, i);
      buffer3[i] = LWMA(buffer7, period, i);
      buffer4[i] = LWMA(buffer8, period, i);
   }

   //---
   return (rates_total);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  subroutines and functions
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

double SMA(const double &array[], int per, int bar)
{
   //---
   double sum = 0;
   for (int i = 0; i < per; i++) sum += array[bar+i];
   return(sum / per);
   //---
}

double LWMA(const double &array[], int per, int bar)
{
   //---
   double Sum = 0;
   double Weight = 0;
   for(int i = 0; i < per; i++)
   {
      Weight += (per - i);
      Sum    += array[bar+i] * (per - i);
   }
   double lwma = 0;
   if (0.0 < Weight) lwma = Sum / Weight;
   // else lwma = 0;
   return(lwma);
   //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~