
//+------------------------------------------------------------------+
//|                                                RemoveCaption.mq4 |
//|                                           Copyright 2011, Xaphod |
//|                               http://www.forexfactory.com/xaphod |
//+------------------------------------------------------------------+

#property copyright "Copyright 2011, Xaphod"
#property link      "http://www.forexfactory.com/xaphod"
#property strict

#import "user32.dll"
  int SetWindowLongW(int hWnd, int nIndex, int dwNewLong);
  int GetWindowLongW(int hWnd, int nIndex);
  int SetWindowPos(int hWnd, int hWndInsertAfter, int X, int Y, int cx, int cy, int uFlags);
  int GetParent(int hWnd);
#import

#define GWL_STYLE         -16
#define WS_CAPTION        0x00C00000
#define WS_BORDER         0x00800000
#define WS_SIZEBOX        0x00040000
#define WS_DLGFRAME       0x00400000
#define SWP_NOSIZE        0x0001
#define SWP_NOMOVE        0x0002
#define SWP_NOZORDER      0x0004
#define SWP_NOACTIVATE    0x0010
#define SWP_FRAMECHANGED  0x0020

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnStart() {
  int iChartParent = GetParent(ChartGetInteger(ChartID(), CHART_WINDOW_HANDLE, 0));
  int iNewStyle = GetWindowLongW(iChartParent, GWL_STYLE) & (~(WS_BORDER | WS_DLGFRAME | WS_SIZEBOX));
  if (0 < iChartParent && 0 < iNewStyle) {
    SetWindowLongW(iChartParent, GWL_STYLE, iNewStyle);
    SetWindowPos(iChartParent, 0, 0, 0, 0, 0, SWP_NOZORDER | SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_FRAMECHANGED);
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
