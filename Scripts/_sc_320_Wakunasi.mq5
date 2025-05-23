//+------------------------------------------------------------------+
//|                                                 320_WakuNasi.mq5 |
//|                                      (c) 2021 さいとさんにぃまる |
//|                                        https://site-320.com/mt4/ |
//+------------------------------------------------------------------+
//|2021/12/22 Ver 3.00                                               |
//|  新規作成。                                                      |
//|  (バージョンを統一するため新規作成だがVer 3.00から開始する)      |
//+------------------------------------------------------------------+
#property copyright   "(c) 2021 さいとさんにぃまる"
#property link        "https://site-320.com/mt4/"
#property version     "3.00"
#property strict
#property description "MT5向けの320_WakuNasiもどきです。"
#property description "チャートのキャプションが消えたように見せかけます。"
#property description "また、枠も細くなったように見せかけます。"
#property description "利用時は、「DLLの使用を許可する」にチェックを入れてください。"

/*-- インポートするDLL用の構造体 -----------------------------------*/
struct WINDOWINFO         //ウィンドウ情報
{
   int   cbSize;          //WINDOWINFOのサイズ
   int   rcWindowLeft;    //ウィンドウの左座標
   int   rcWindowTop;     //ウィンドウの上座標
   int   rcWindowRight;   //ウィンドウの右座標
   int   rcWindowBottom;  //ウィンドウの下座標
   int   rcClientLeft;    //クライアント領域の左座標
   int   rcClientTop;     //クライアント領域の上座標
   int   rcClientRight;   //クライアント領域の右座標
   int   rcClientBottom;  //クライアント領域の下座標
   int   dwStyle;         //ウィンドウのスタイル
   int   dwExStyle;       //ウィンドウの拡張スタイル
   int   dwWindowStatus;  //ウィンドウのステータス
   int   cxWindowBorders; //ウィンドウの境界の幅(ピクセル単位)
   int   cyWindowBorders; //ウィンドウの境界の高さ(ピクセル単位)
   int   atomWindowType;  //The window class atom
   short wCreatorVersion; //ウィンドウを作成したアプリケーションのWindowsバージョン
};

/*-- インポートするDLLの宣言 ---------------------------------------*/
#import "user32.dll"
   int GetParent(int hWnd);
   int GetWindow(int hWnd, int wCmd);
   int GetWindowInfo(int hwnd, WINDOWINFO &pwi);
   int SetWindowPos(int hWnd, int hWndInsertAfter, int X, int Y, int cx, int cy, int uFlags);
#import

/*-- メイン処理で使用する構造体 ------------------------------------*/
struct INFO  //ウィンドウ変更情報
{
   int WHND; //ウィンドウハンドル
   int X;    //変更後のウィンドウ左座標
   int Y;    //変更後のウィンドウ上座標
   int W;    //変更後のウィンドウ右座標
   int H;    //変更後のウィンドウ下座標
};

//+------------------------------------------------------------------+
//|スクリプトのメイン処理                                            |
//+------------------------------------------------------------------+
void OnStart()
{
   //変数宣言
   INFO info[];
   ArrayResize(info, 0);
   WINDOWINFO wi, wim;
   int SWP_FLAGS = 0;

   //MDIのクライアント領域を取得
   int wHandle = (int)ChartGetInteger(0, CHART_WINDOW_HANDLE);
   if (wHandle == 0) {
      Alert("No MDI.");
      return;
   }
   wim.cbSize = sizeof(WINDOWINFO);
   if (!GetWindowInfo(GetParent(GetParent(wHandle)), wim)) {
      Alert("GetWindowInfo Error. (",GetLastError(),")");
      return;
   }

   //最初のチャートのチャートIDを取得
   long wChartID = ChartFirst();
   //チャートIDが取得できた場合
   while (wChartID > 0) {
      //チャートのウィンドウハンドルを取得
      wHandle = GetParent((int)ChartGetInteger(wChartID, CHART_WINDOW_HANDLE));
      //ウィンドウハンドルを取得できた場合
      if (wHandle > 0) {
         //チャートの座標を取得
         wi.cbSize = sizeof(WINDOWINFO);
         if (!GetWindowInfo(wHandle, wi)) {
            Alert("GetWindowInfo Error. (",GetLastError(),")");
            return;
         }
         //MDIクライアント領域からはみ出ているチャートが1つでもある場合は
         //すでに当スクリプトが実行済みと判断し、位置とサイズの変更は行わない(*1)
         if (wi.rcWindowLeft   < wim.rcClientLeft  ||
             wi.rcWindowTop    < wim.rcClientTop   ||
             wi.rcWindowRight  > wim.rcClientRight ||
             wi.rcWindowBottom > wim.rcClientBottom) SWP_FLAGS = 0x00000003; //SWP_NOSIZE, SWP_NOMOVE
         //ウィンドウハンドルと算出した座標を配列に追加する
         ArrayResize(info, ArrayRange(info, 0) + 1);
         int idx = ArrayRange(info, 0) - 1;
         info[idx].WHND = wHandle;
         info[idx].X = wi.rcWindowLeft    - wim.rcClientLeft - wi.cxWindowBorders;
         info[idx].Y = wi.rcWindowTop     - wim.rcClientTop  - (wi.rcClientTop - wi.rcWindowTop);
         info[idx].W = (wi.rcWindowRight  - wi.rcWindowLeft) + wi.cxWindowBorders;
         info[idx].H = (wi.rcWindowBottom - wi.rcWindowTop)  + (wi.rcClientTop - wi.rcWindowTop);
         //チャートが右端の場合
         if (wi.rcWindowRight >= wim.rcClientRight - 2) {
            info[idx].W = info[idx].W + wi.cxWindowBorders;
         }
         //チャートが下段の場合
         if (wi.rcWindowBottom >= wim.rcClientBottom - 2) {
            info[idx].H = info[idx].H + wi.cyWindowBorders;
         }
      }
      //次のチャートのチャートIDを取得
      wChartID = ChartNext(wChartID);
   }

   //ウィンドウの位置とサイズを変更する
   //※すでに当スクリプトが実行済みと判断して位置とサイズの変更は行わない(*1)場合も
   //  この処理を行うのは、チャートをクリックしてキャプションが見えている状態に
   //  なった場合に、それを隠す(キャプションが消えたように見せかける)ため。
   for (int i = ArrayRange(info, 0) - 1; i >= 0; i--)
      SetWindowPos(info[i].WHND, 0, info[i].X, info[i].Y, info[i].W, info[i].H, SWP_FLAGS);
}
//+------------------------------------------------------------------+
