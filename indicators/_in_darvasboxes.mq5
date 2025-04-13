
//+------------------------------------------------------------------+
//|                                                  DarvasBoxes.mq4 |
//|                                                           ign... |
//|                                      http://www.blenderar.com.ar |
//+------------------------------------------------------------------+
//
/*
   version 0.3
   Changelog: Major buxfix! Seeing the indicator i detected that the
   price broke the bottom and the top of the boxes in non apropiate moments.
   This was because a false verification of periods.
   Now the boxes are more real than the olders.

   version 0.4
   ChangeLog: This is a better implementation of the Darvas Algorithm method.
*/
#property copyright "ign..."
#property link      "http://www.blenderar.com.ar"

#property strict
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_plots   2

#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE

#property indicator_color1 clrDodgerBlue
#property indicator_color2 clrRed

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#define ShortName       "DarvasBoxes-0.1"
#define SET_BOXTOP      1
#define SAVE_BOXTOP     2
#define SET_BOXBOTTOM   3
#define SAVE_BOXBOTTOM  4
#define WAIT_SIGNAL     5

//---- buffers

double ExtMapBuffer1[]; // BoxTop
double ExtMapBuffer2[]; // BoxBottom

int    PrevState   = 0;
int    State       = SET_BOXTOP;
double BoxTop      = 0;
double BoxBottom   = 0;
int    BoxStartPos = 0;
int    BoxEndPos   = 0;
int    CurPos      = -1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit(void) {

   //---- indicators.
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexBuffer(1, ExtMapBuffer2);

#ifdef __MQL5__
   ArraySetAsSeries(ExtMapBuffer1, true);
   ArraySetAsSeries(ExtMapBuffer2, true);
#endif

   IndicatorSetString(INDICATOR_SHORTNAME, ShortName);
   //----
   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+

void OnDeinit(const int reason) {
   //----
   Comment("");
   //----
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
   ArraySetAsSeries(low, true);
#endif

   if (State == WAIT_SIGNAL && PrevState == WAIT_SIGNAL)
      Comment("State: Waiting Signal");
   else
      Comment("State #" + (string)State);
   /*
   if (!prev_calculated) {
      int length = fmax(rates_total - (Length), rates_total - 1);
      for (int i = rates_total - 1; length <= i; i--)
         buffer0[i] = buffer1[i] = buffer2[i] = EMPTY_VALUE;
   }
   */
   for (int i = rates_total - (prev_calculated ? prev_calculated : 2); 0 <= i; i--) {

      if (State == SET_BOXTOP) {
         BoxTop = high[i + 1];
         BoxBottom = low[i + 1];

         if (!PrevState) {
            BoxStartPos = i + 1;
         }

         PrevState = State;
         State = SAVE_BOXTOP;
      } else if (State == SAVE_BOXTOP) {
         if (BoxTop < high[i + 1]) {
            BoxTop = high[i + 1];
            if (BoxBottom > low[i + 1])
               BoxBottom = low[i + 1];

            if (!PrevState) {
               BoxStartPos = i + 1;
            }

            PrevState = State;
            State = SAVE_BOXTOP;
         } else {
            PrevState = State;
            State = SET_BOXBOTTOM;
         }
      } else if (State == SET_BOXBOTTOM) {
         if (BoxBottom > low[i + 1])
            BoxBottom = low[i + 1];
         if (BoxTop < high[i + 1]) {
            if (BoxTop < high[i + 1]) {
               BoxTop = high[i + 1];
               if (BoxBottom > low[i + 1])
                  BoxBottom = low[i + 1];

               if (!PrevState) {
                  BoxStartPos = i + 1;
               }

               PrevState = State;
               State = SAVE_BOXTOP;
            } else {
               PrevState = State;
               State = SET_BOXBOTTOM;
            }
         } else {
            PrevState = State;
            State = SAVE_BOXBOTTOM;
         }
      } else if (State == SAVE_BOXBOTTOM) {
         if (BoxTop < high[i + 1]) {
            BoxTop = high[i + 1];
            if (BoxBottom > low[i + 1])
               BoxBottom = low[i + 1];

            if (!PrevState) {
               BoxStartPos = i + 1;
            }

            PrevState = State;
            State = SAVE_BOXTOP;
         } else if (BoxBottom > low[i + 1]) {
            if (BoxBottom > low[i + 1])
               BoxBottom = low[i + 1];
            if (BoxTop < high[i + 1]) {
               if (BoxTop < high[i + 1]) {
                  BoxTop = high[i + 1];
                  if (BoxBottom > low[i + 1])
                     BoxBottom = low[i + 1];

                  if (!PrevState) {
                     BoxStartPos = i + 1;
                  }

                  PrevState = State;
                  State = SAVE_BOXTOP;
               } else {
                  PrevState = State;
                  State = SET_BOXBOTTOM;
               }
            } else {
               PrevState = State;
               State = SAVE_BOXBOTTOM;
            }
         } else {
            // Save BOXBOTTOM
            PrevState = State;
            State = WAIT_SIGNAL;
         }
      } else if (State == WAIT_SIGNAL) {
         if (PrevState == SAVE_BOXBOTTOM && BoxTop < high[i + 1]) {
            BoxTop = high[i + 1];
            if (BoxBottom > low[i + 1])
               BoxBottom = low[i + 1];

            if (!PrevState) {
               BoxStartPos = i + 1;
            }

            PrevState = State;
            State = SAVE_BOXTOP;
         } else if (PrevState == SAVE_BOXBOTTOM && BoxBottom > low[i + 1]) {
            BoxBottom = low[i + 1];
            if (BoxTop < high[i + 1]) {
               if (BoxTop < high[i + 1]) {
                  BoxTop = high[i + 1];
                  if (BoxBottom > low[i + 1])
                     BoxBottom = low[i + 1];

                  if (!PrevState) {
                     BoxStartPos = i + 1;
                  }

                  PrevState = State;
                  State = SAVE_BOXTOP;
               } else {
                  PrevState = State;
                  State = SET_BOXBOTTOM;
               }
            } else {
               PrevState = State;
               State = SAVE_BOXBOTTOM;
            }
         } else {

            PrevState = State;

            if (BoxBottom > low[i + 1]) {
               // Sell Signal
               PrevState = 0;
               State = SET_BOXTOP;
            }

            if (BoxTop < high[i + 1]) {
               // Buy Signal
               PrevState = 0;
               State = SET_BOXTOP;
            }
         }
      }

      // draw_boxtop(i);
      // draw_boxbottom(i);
      draw_box(i);
   }

   ExtMapBuffer1[0] = BoxTop;
   ExtMapBuffer2[0] = BoxBottom;

   //----
   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void draw_box(int pos) {

   for (int i = BoxStartPos; i > pos; i--) {
      ExtMapBuffer1[i] = BoxTop;
      ExtMapBuffer2[i] = BoxBottom;
   }
}
/*
void draw_boxtop(int pos) {

   for (int i = BoxStartPos; i > pos; i--)
      ExtMapBuffer1[i] = BoxTop;
}

void draw_boxbottom(int pos) {

   for (int i = BoxStartPos; i > pos; i--)
      ExtMapBuffer2[i] = BoxBottom;
}
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
