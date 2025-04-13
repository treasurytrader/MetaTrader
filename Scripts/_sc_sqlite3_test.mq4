
// https://expertadviser-bighope.blogspot.com/2014/08/newmt4-de-sqlite3.html

//+------------------------------------------------------------------+
//|                                                  SQLite3test.mq4 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property show_inputs
#include <sqlite3.mqh>
input string dbns="C:\Testdb.db";//ﾃﾞｰﾀﾍﾞｰｽ名（ﾌﾙﾊﾟｽ）

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start(){
    string sql = "";
   int i;
   //インスタンス
     CSQLite3 sqlite(dbns);

   //テーブルの作成
     sql = "CREATE TABLE IF NOT EXISTS `Test` (`id` INTEGER, `time` TEXT, `open_price` DOUBLE)";
     if(sqlite.execute(sql)!= SQLITE_OK)sqlite.errmsg();

   //入力
     sql = "INSERT INTO 'Test' VALUES (?,?,?)";
     //トランザクション
     if(sqlite.execute("BEGIN")!=SQLITE_OK)sqlite.errmsg();

     for(i=0;i<Bars;i++){
       if(sqlite.prepare(sql)!=SQLITE_OK)sqlite.errmsg();
       if(sqlite.bind_int(1,Bars-i)!=SQLITE_OK)sqlite.errmsg();
       if(sqlite.bind_text(2,TimeToStr(Time[i]))!=SQLITE_OK)sqlite.errmsg();
       if(sqlite.bind_double(3,Open[i])!=SQLITE_OK)sqlite.errmsg();
       sqlite.next_row();
     }
     //トランザクション終了
     if(sqlite.execute("COMMIT")!=SQLITE_OK)sqlite.errmsg();

     //ステートメントの解法
     sqlite.finalize();

   //出力
     sql = "SELECT COUNT(*) FROM  'Test'";
     if(sqlite.prepare(sql)!=SQLITE_OK)sqlite.errmsg();
     sqlite.next_row();
     Print("Bars=",IntegerToString(Bars)," ﾃﾞｰﾀﾍﾞｰｽ内のﾃﾞｰﾀ数=",sqlite.get_text(0));

     //ステートメントの解法
     sqlite.finalize();

   //抽出
     sql = "SELECT * FROM 'Test'" ;
     if(sqlite.prepare(sql)!=SQLITE_OK)sqlite.errmsg();
     while(sqlite.next_row()){
       Print(IntegerToString(
                               sqlite.get_int(0))," : ",
                               sqlite.get_text(1)," : ",
                               DoubleToStr(sqlite.get_double(2),Digits));
     }

     //ステートメントの解法
     sqlite.finalize();
   //ﾃﾞｰﾀﾍﾞｰｽを閉じる。
   sqlite.db_close();

  return (0);
  }