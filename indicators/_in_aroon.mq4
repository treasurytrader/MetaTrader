#property strict

//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 clrRoyalBlue
#property indicator_color2 clrRed

//--- indicator parameters
extern int period = 10;

//--- indicator buffers
double UP[];
double DN[];

//--- global variables
int windowindex;
string shortname;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator initialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnInit(void) {
  //--- checking input data
  //--- indicator buffers mapping
  IndicatorBuffers(2);
  SetIndexBuffer(0, UP);
  SetIndexEmptyValue(0, EMPTY_VALUE);
  SetIndexBuffer(1, DN);
  SetIndexEmptyValue(1, EMPTY_VALUE);

  //--- drawing settings
  IndicatorDigits(2);
  SetIndexStyle(0, DRAW_LINE); // SetIndexDrawBegin(0, 200);
  SetIndexStyle(1, DRAW_LINE); // SetIndexDrawBegin(1, 200);

  //--- horizontal level
  SetLevelValue(0, 0.5);
  IndicatorSetInteger(INDICATOR_LEVELCOLOR, 1973790);
  IndicatorSetInteger(INDICATOR_LEVELSTYLE, -1);
  IndicatorSetInteger(INDICATOR_LEVELWIDTH, -1);

  //--- set short name
  shortname = StringConcatenate(WindowExpertName(), " (");
  if (_Period < PERIOD_D1)
    shortname += StringConcatenate(
        DoubleToString((double)period / ((double)PERIOD_D1 / (double)_Period),
                       1),
        ", ");
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
  if (-1 != ObjectFind(shortname))
    ObjectDelete(shortname);
  //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator iteration function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  //--- global variables
  static int length = period - 1;

  //--- initialization of zero
  if (!prev_calculated) {
    for (int i = rates_total - 1, j = rates_total - (period + 2); j <= i; i--) {
      UP[i] = DN[i] = EMPTY_VALUE;
    }
  }

  //--- the main cycle of indicator calculation
  for (int i =
           rates_total - (prev_calculated ? prev_calculated - 1 : period + 2);
       0 <= i; i--) {
    // int hh = Highest(NULL, PERIOD_CURRENT, MODE_HIGH, period+1, i);
    // int ll =  Lowest(NULL, PERIOD_CURRENT, MODE_LOW,  period+1, i);

    int hh = Highest(NULL, PERIOD_CURRENT, MODE_HIGH, period, i);
    int ll = Lowest(NULL, PERIOD_CURRENT, MODE_LOW, period, i);

    UP[i] = 1.0 * (length - (hh - i)) / length;
    DN[i] = 1.0 * (length - (ll - i)) / length;
  }

  //---
  if (UP[0] > DN[0])
    ShowValue(UP[0], shortname, windowindex, DN[0], indicator_color1);
  if (UP[0] < DN[0])
    ShowValue(DN[0], shortname, windowindex, UP[0], indicator_color2);

  //---
  return (rates_total);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  subroutines and functions
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void ShowValue(double value, string object_name, int index = 0,
               double compare = 0.0, color plus = clrRoyalBlue,
               color minus = clrRed, int digits = 2) {
  //---
  string text = DoubleToString(value, digits);
  color clr = clrGray;

  if (compare < value)
    clr = plus;
  if (compare > value)
    clr = minus;

  if (-1 == ObjectFind(object_name)) {
    ObjectCreate(object_name, OBJ_LABEL, index, 0, 0, 0, 0);
    ObjectSet(object_name, OBJPROP_CORNER, 1);
    ObjectSet(object_name, OBJPROP_XDISTANCE, 6);
    ObjectSet(object_name, OBJPROP_YDISTANCE, 1);
  }
  ObjectSetText(object_name, text, 8, NULL, clr);
  //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~