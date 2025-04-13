
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 clrFireBrick
#property indicator_color2 clrRoyalBlue

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//--- buffers
double up[], dn[], chng_rt[], rawVBE_up[], rawVBE_dn[];

//--- global variables
double VBE_up[][6], VBE_dn[][6], up_chg[][6], dn_chg[][6];
double fcstVBE_up[6], fcstVBE_dn[6], up_cor[6], dn_cor[6];
int period[6] = {21, 17, 13, 9, 5, 2};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit(void) {
   //---
   IndicatorBuffers(5);

   SetIndexBuffer(0, up);
   SetIndexBuffer(1, dn);
   SetIndexBuffer(2, rawVBE_up); // 원시 VBE
   SetIndexBuffer(3, rawVBE_dn);
   SetIndexBuffer(4, chng_rt); // 가격 변동률

   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexStyle(4, DRAW_NONE);

   return (INIT_SUCCEEDED);
   //---
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

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {

   //--- emulation of indicator buffers in an expert advisor
   if (ArrayRange(up_chg, 0) != rates_total) {
      ArraySetAsSeries(VBE_up, false);
      ArraySetAsSeries(VBE_dn, false);
      ArraySetAsSeries(up_chg, false);
      ArraySetAsSeries(dn_chg, false);
      //---
      ArrayResize(VBE_up, rates_total);
      ArrayResize(VBE_dn, rates_total);
      ArrayResize(up_chg, rates_total);
      ArrayResize(dn_chg, rates_total);
      //---
      ArraySetAsSeries(VBE_up, true);
      ArraySetAsSeries(VBE_dn, true);
      ArraySetAsSeries(up_chg, true);
      ArraySetAsSeries(dn_chg, true);
   }

   //--- initialization of zero
   if (!prev_calculated) {
      for (int i = rates_total - 2, j = rates_total - 64; j <= i; i--) {
         chng_rt[i] = (close[i] / close[i + 1] - 1.);
      }
   }

   //--- the main cycle of indicator calculation
   for (int i = rates_total - (prev_calculated ? prev_calculated : 64); 0 <= i; i--) {
      chng_rt[i] = (close[i] / close[i + 1] - 1);  // 가격 변동률
      double average = SMA(chng_rt, period[0], i); // 가격변동률의 평균

      // 가격변동률의 표준편차
      double dev = 0.0;
      for (int j = 0; j < period[0]; j++)
         dev += pow(chng_rt[i + j], 2);
      dev = sqrt(dev / period[0]);

      // 원시 VBE
      rawVBE_up[i] = close[i] * (1. + (average + (dev * 2.)));
      rawVBE_dn[i] = close[i] * (1. + (average - (dev * 2.)));

      //---
      for (int j = 0; j <= 5; j++) {
         // 원시VBE를 가중이평으로 평활화
         VBE_up[i][j] = LWMA(rawVBE_up, period[j], i);
         VBE_dn[i][j] = LWMA(rawVBE_dn, period[j], i);

         // VBE의 변동률
         if (0 < VBE_up[i + 1][j])
            up_chg[i][j] = (VBE_up[i][j] - VBE_up[i + 1][j]) / VBE_up[i + 1][j];
         if (0 < VBE_dn[i + 1][j])
            dn_chg[i][j] = (VBE_dn[i][j] - VBE_dn[i + 1][j]) / VBE_dn[i + 1][j];
      }

      //---
      fcstVBE_up[0] = VBE_up[i][0];
      fcstVBE_dn[0] = VBE_dn[i][0];

      for (int j = 1; j <= 5; j++) {
         // 21일 VBE변동률과 17, 13, 9, 5, 2 변동률간의 상관도
         up_cor[j] = Correlation(up_chg, 63, i, j);
         dn_cor[j] = Correlation(dn_chg, 63, i, j);
         // 이전값에 상관도와 변동률을 곱해서 계산
         fcstVBE_up[j] = fcstVBE_up[j - 1] * (1. + (up_chg[i][j] * up_cor[j]));
         fcstVBE_dn[j] = fcstVBE_dn[j - 1] * (1. + (dn_chg[i][j] * dn_cor[j]));
      }

      for (int j = 5; 0 <= j; j--) {
         up[i + j] = fcstVBE_up[5 - j];
         dn[i + j] = fcstVBE_dn[5 - j];
      }
   }

   //---
   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Correlation(double &ind[][6], int length, int bar, int k) {
   double ret = 0.0;
   int counter1 = 0, counter2 = 0;

   for (int i = 0, j = length - 1; i <= j; i++) {
      if ((ind[bar + i + 1][0] <= ind[bar + i][0] &&
           ind[bar + i + 1][k] <= ind[bar + i][k]) ||
          (ind[bar + i + 1][0] > ind[bar + i][0] &&
           ind[bar + i + 1][k] > ind[bar + i][k])) {
         counter1++;
      } else
         counter2++;
   }
   if (0 != counter1 + counter2) {
      ret = (double)(counter1 - counter2) / (double)(counter1 + counter2);
   }

   return (ret);
}

double SMA(double &array[], int per, int bar) {
   double Sum = 0.;
   for (int i = 0; i < per; i++)
      Sum += array[bar + i];
   return (Sum / per);
}

double LWMA(double &array[], int per, int bar) {
   double Sum = 0.;
   double Weight = 0.;
   double lwma = 0.;

   for (int i = 0; i < per; i++) {
      Weight += (per - i);
      Sum += array[bar + i] * (per - i);
   }
   if (0 < Weight)
      lwma = Sum / Weight;
   return (lwma);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
