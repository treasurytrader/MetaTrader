
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_chart_window

#property indicator_buffers 1
#property indicator_color1  C'50,70,90'

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

extern int   InpDepth     = 12;
extern int   InpDeviation = 5;
extern int   InpBackstep  = 3;
input  bool  ShowValue    = false;

extern bool  trendline  = false;
extern color resistance = clrFireBrick;
extern color support    = C'34,106,178';
extern int   shift      = 0;

extern bool  tradeline = false;
extern color breakout  = C'50,70,90';

extern bool  fibonacci = false;
extern color fibocolor = C'50,50,50';

double ZigZag[];

datetime preBar;
int      ExtLevel = 3; // recounting's depth of extremums
string   gname;
string   objarr[4];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit() {

   if (InpBackstep >= InpDepth) {
      Print("Backstep cannot be greater or equal to Depth");
      return (INIT_FAILED);
   }

   SetIndexBuffer(0, ZigZag);
   SetIndexEmptyValue(0, 0.0);
   SetIndexStyle(0, DRAW_SECTION);

   objarr[0] = "_resistance";
   objarr[1] = "_support";
   objarr[2] = "_breakout";
   objarr[3] = "_fibonacci";

   gname = MQLInfoString(MQL_PROGRAM_NAME);

   for (int i = 0; i < sizeof(objarr) / sizeof(string); i++)
      if (-1 != ObjectFind(objarr[i])) ObjectDelete(objarr[i]);

   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnDeinit(const int reason) {

   for (int i = 0; i < sizeof(objarr) / sizeof(string); i++)
      if (-1 != ObjectFind(objarr[i])) ObjectDelete(objarr[i]);

   ObjectsDeleteAll(0, 0, OBJ_TEXT);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {

   for (int i = rates_total - (prev_calculated ? prev_calculated : 1); 0 <= i; i--) {
      ZigZag[i] = iCustom(NULL, 0, "ZigZag", InpDepth, InpDeviation, InpBackstep, 0, i);
   }

   if (ShowValue && isNewBar(time[0])) {
      for (int k = ObjectsTotal((long)0); 0 <= k; k--) {
         string name = ObjectName(0, k);
         if (-1 != StringFind(name, gname)) ObjectDelete(0, name);
      }
   }

   DrawTrends(rates_total);

   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void DrawTrends (int rates_total) {

   static double previous = -1.0;
   if (previous == ZigZag[0]) return;
   previous = ZigZag[0];

   //--- get last up
   double save_0 = 0.0, save_1 = 0.0, save_2 = 0.0, save_3 = 0.0, save_4 = 0.0;
   int t_0 = 0, t_1 = 0, t_2 = 0, t_3 = 0, t_4 = 0;

   for (int i = 0, j = 0; j < shift + 6; i++) {
      if (rates_total - 1 <= i) return;
      if (0 != ZigZag[i]) {
         j++;
         if (j == shift + 1) {
            save_0 = ZigZag[i];
            t_0 = i;
         }
         if (j == shift + 2) {
            save_1 = ZigZag[i];
            t_1 = i;
         }
         if (j == shift + 3) {
            save_2 = ZigZag[i];
            t_2 = i;
         }
         if (j == shift + 4) {
            save_3 = ZigZag[i];
            t_3 = i;
         }
         if (j == shift + 5) {
            save_4 = ZigZag[i];
            t_4 = i;
         }
      }
   }

   //---

   bool   position = fabs(save_0 - save_1) > fabs(save_1 - save_2);
   double price0 = 0.0, price1 = 0.0, price2 = 0.0, price3 = 0.0;
   int    time0 = 0, time1 = 0, time2 = 0, time3 = 0;

   if (trendline) {
      if (position) {
         price0 = save_0;
         price1 = save_1;
         price2 = save_2;
         price3 = save_3;
         time0 = t_0;
         time1 = t_1;
         time2 = t_2;
         time3 = t_3;

      } else {
         price0 = save_1;
         price1 = save_2;
         price2 = save_3;
         price3 = save_4;
         time0 = t_1;
         time1 = t_2;
         time2 = t_3;
         time3 = t_4;
      }
      if (0 > ObjectFind (0, "_resistance")) {
         ObjectCreate    (0, "_resistance", OBJ_TREND, 0,
                          iTime(NULL, 0, time2), price2, iTime(NULL, 0, time0), price0);
         ObjectSetInteger(0, "_resistance", OBJPROP_BACK, true);
         ObjectSetInteger(0, "_resistance", OBJPROP_COLOR,
                          resistance);
      }
      ObjectMove(0, "_resistance", 0, iTime(NULL, 0, time2), price2);
      ObjectMove(0, "_resistance", 1, iTime(NULL, 0, time0), price0);
      if (0 > ObjectFind (0, "_support")) {
         ObjectCreate    (0, "_support", OBJ_TREND, 0,
                          iTime(NULL, 0, time3), price3, iTime(NULL, 0, time1), price1);
         ObjectSetInteger(0, "_support", OBJPROP_BACK, true);
         ObjectSetInteger(0, "_support", OBJPROP_COLOR, support);
      }
      ObjectMove(0, "_support", 0, iTime(NULL, 0, time3), price3);
      ObjectMove(0, "_support", 1, iTime(NULL, 0, time1), price1);
   }

   //---

   if (tradeline) {
      if (0 > ObjectFind (0, "_breakout")) {
         ObjectCreate    (0, "_breakout", OBJ_TREND, 0,
                          iTime(NULL, 0, t_1), save_1, iTime(NULL, 0, t_0), save_0);
         ObjectSetInteger(0, "_breakout", OBJPROP_RAY, true);
         ObjectSetInteger(0, "_breakout", OBJPROP_BACK, true);
         ObjectSetInteger(0, "_breakout", OBJPROP_COLOR, breakout);
      }
      ObjectMove(0, "_breakout", 0, iTime(NULL, 0, t_1), save_1);
      ObjectMove(0, "_breakout", 1, iTime(NULL, 0, t_0), save_0);
      /*
      ObjectGetValueByTime() 함수 line_id = 0 참조
      //---
      Trendline (OBJ_TREND)
      Trendline by angle (OBJ_TRENDBYANGLE)
      Gann line (OBJ_GANNLINE)
      Equidistant channel (OBJ_CHANNEL) - 2 lines
      Linear regression channel (OBJ_REGRESSION) - 3 lines
      Standard deviation channel (OBJ_STDDEVCHANNEL) - 3 lines
      Arrowed line (OBJ_ARROWED_LINE)
      */
      for (int i = t_1 - 5; t_0 <= i; i--) {
         datetime time = iTime(NULL, 0, i);
         if (save_1 < save_0 &&
             iLow(NULL, 0, i) <
                 ObjectGetValueByTime(0, "_breakout", time))
            ObjectMove(0, "_breakout", 1, time, iLow(NULL, 0, i));
         if (save_1 > save_0 &&
             iHigh(NULL, 0, i) >
                 ObjectGetValueByTime(0, "_breakout", time))
            ObjectMove(0, "_breakout", 1, time, iHigh(NULL, 0, i));
      }
   }

   //---

   if (fibonacci) {
      if (position) {
         price0 = save_1;
         price1 = save_0;
         time0 = t_1;
         time1 = t_0;
      } else {
         price0 = save_2;
         price1 = save_1;
         time0 = t_2;
         time1 = t_1;
      }
      ObjectDelete    (0, "_fibonacci");
      ObjectCreate    (0, "_fibonacci", OBJ_FIBO, 0,
                       iTime(NULL, 0, time0), price0, iTime(NULL, 0, time1), price1);
      ObjectSetInteger(0, "_fibonacci", OBJPROP_BACK, true);
      ObjectSetInteger(0, "_fibonacci", OBJPROP_COLOR, clrNONE);
      ObjectSetInteger(0, "_fibonacci", OBJPROP_LEVELCOLOR,
                       fibocolor);
   }

   //---
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool isNewBar(datetime current) {
   if (preBar == current) return (false);
   preBar = current;
   return (true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
