//+------------------------------------------------------------------+
//|                                                CurrencyIndex.mqh |
//|                             Copyright 2000-2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2000-2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#define SECONDS_IN_DAY    (24*60*60)   // количество секунд в сутках
#define SECONDS_IN_MINUTE 60           // количество секунд в минуте
#define MSECS_IN_MINIUTE  (60*1000)    // количество миллисекунд в минуте

//--- структура символа корзины
struct SymbolWeight
  {
   string            symbol;           // символ
   double            weight;           // вес
  };
  
//--- структура исторических данных
struct str_rates
  {
   int               index;            // индекс данных
   MqlRates          rates[];          // массив исторических данных
  };
  
//--- структура тиковых данных
struct str_ticks
  {
   int               index;            // индекс данных
   MqlTick           ticks[];          // массив тиков
  };
  
//--- перечисление типов цен
enum ENUM_RATES_VALUES
  {
   VALUE_OPEN,                         // цена Open
   VALUE_HIGH,                         // цена High
   VALUE_LOW,                          // цена Low
   VALUE_CLOSE                         // цена Close
  };

int ExtDigits=5;                       // точность измерения цены символа

//+------------------------------------------------------------------+
//| Обработка тиков                                                  |
//+------------------------------------------------------------------+
void ProcessTick(const string custom_symbol)
  {
   static long    last_time_msc=0;     // время в миллисекундах последнего тика
   static MqlTick synth_tick[1];       // структура последнего тика синтетического инструмента
   static MqlTick ticks[BASKET_SIZE];  // массив данных последних тиков корзины символов
   static MqlTick tick;                // вспомогательная переменная для получения данных и поиска времени
   int success_cnt=0;
   int change_cnt=0;
   
//--- инициализируем время тика синтетического символа
   synth_tick[0].time=0;
   
//--- в цикле по количеству символов в корзине инструментов
   for(int i=0; i<BASKET_SIZE; i++)
     {
      //--- получаем данные очередного символа
      if(SymbolInfoTick(ExtWeights[i].symbol,tick))
        {
         //--- увеличиваем количество успешных запросов данных
         success_cnt++;
         //--- получаем самое свежее время из списка символов корзины
         if(synth_tick[0].time==0)
           {
            synth_tick[0].time=tick.time;
            synth_tick[0].time_msc=tick.time_msc;
           }
         else
           {
            if(synth_tick[0].time_msc<tick.time_msc)
              {
               synth_tick[0].time=tick.time;
               synth_tick[0].time_msc=tick.time_msc;
              }
           }
         //--- сохраняем полученные данные по символу в массиве ticks в соответствии с индексом символа корзины
         ticks[i]=tick;
        }
     }
   //--- если получены тики всех инструментов корзины, и это новый тик
   if(success_cnt==BASKET_SIZE && synth_tick[0].time!=0 && last_time_msc<synth_tick[0].time_msc)
     {
      //--- сохраняем время последнего тика
      last_time_msc=synth_tick[0].time_msc;
      
      //--- рассчитываем значение цены Bid синтетического инструмента
      synth_tick[0].bid=MAIN_COEFF;
      for(int i=0; i<BASKET_SIZE; i++)
         synth_tick[0].bid*=MathPow(ticks[i].bid,ExtWeights[i].weight);
         
      //--- цена Ask равна цене Bid
      synth_tick[0].ask=synth_tick[0].bid;
      
      //--- добавляем в ценовую историю пользовательского инструмента новый тик
      CustomTicksAdd(custom_symbol,synth_tick);
     }
  }
//+------------------------------------------------------------------+
//| Инициализация сервиса                                            |
//+------------------------------------------------------------------+
bool InitService(const string custom_symbol,const string custom_group)
  {
   MqlRates rates[100];
   MqlTick  ticks[100];
   
//--- инициализируем пользовательский символ
   if(!CustomSymbolInitialize(custom_symbol,custom_group))
      return(false);
   ExtDigits=(int)SymbolInfoInteger(custom_symbol,SYMBOL_DIGITS);
   
//--- делаем активными все символы корзины инструментов, участвующие в расчёте индекса
   for(int i=0; i<BASKET_SIZE; i++)
     {
      //--- выбираем символ в окне "Обзор рынка"
      if(!SymbolSelect(ExtWeights[i].symbol,true))
        {
         PrintFormat("cannot select symbol %s",ExtWeights[i].symbol);
         return(false);
        }
      //--- запрашиваем исторические данные баров и тиков по выбранному символу
      CopyRates(ExtWeights[i].symbol,PERIOD_M1,0,100,rates);
      CopyTicks(ExtWeights[i].symbol,ticks,COPY_TICKS_ALL,0,100);
     }
     
//--- строим M1 бары за 1 месяц
   if(!PrepareRates(custom_symbol))
      return(false);
      
//--- получаем последние тики после построения M1 баров
   PrepareLastTicks(custom_symbol);
   
//--- сервис инициализирован
   Print(custom_symbol," datafeed started");
   return(true);
  }
//+------------------------------------------------------------------+
//| Инициализация пользовательского символа                          |
//+------------------------------------------------------------------+
bool CustomSymbolInitialize(string symbol,string group)
  {
   bool is_custom=false;
//--- если символ выбран в окне "Обзор рынка", получаем флаг, что это пользовательский символ
   bool res=SymbolSelect(symbol,true);
   if(res)
      is_custom=(bool)SymbolInfoInteger(symbol,SYMBOL_CUSTOM);

//--- если выбранный символ не пользовательский - создаём его
   if(!res)
     {
      if(!CustomSymbolCreate(symbol,group,"EURUSD"))
        {
         Print("cannot create custom symbol ",symbol);
         return(false);
        }
      //--- символ успешно создан - устанавливаем флаг, что это пользовательский символ
      is_custom=true;
      
      //--- помещаем созданный символ в окно "Обзор рынка"
      if(!SymbolSelect(symbol,true))
        {
         Print("cannot select custom symbol ",symbol);
         return(false);
        }
     }
     
//--- откроем график созданного пользовательского символа
   if(is_custom)
     {
      //--- получаем идентификатор первого окна открытых графиков
      long chart_id=ChartFirst();
      bool found=false;
      //--- в цикле по списку открытых графиков найдём график созданного пользовательского символа
      while(chart_id>=0)
        {
         //--- если график открыт - сообщаем об этом в журнал, ставим флаг найденного графика и выходим из цикла поиска
         if(ChartSymbol(chart_id)==symbol)
           {
            found=true;
            Print(symbol," chart found");
            break;
           }
         //--- на основании текущего выбранного графика получаем идентификатор следующего для очередной итерации поиска в цикле
         chart_id=ChartNext(chart_id);
        }
      
      //--- если график символа не найден среди открытых графиков
      if(!found)
        {
         //--- сообщаем об открытии графика M1 пользовательского символа,
         //--- получаем идентификатор открываемого графика и переходим на него 
         Print("open chart ",symbol,",M1");
         chart_id=ChartOpen(symbol,PERIOD_M1);
         ChartSetInteger(chart_id,CHART_BRING_TO_TOP,true);
        }
     }
//--- пользовательский символ инициализирован
   return(is_custom);
  }
//+------------------------------------------------------------------+
//| Подготовка исторических данных                                   |
//+------------------------------------------------------------------+
bool PrepareRates(const string custom_symbol)
  {
   str_rates symbols_rates[BASKET_SIZE];
   int       i,reserve=0;
   MqlRates  usdx_rates[];                                              // массив-таймсерия синтетического инструмента
   MqlRates  rate;                                                      // данные одного бара синтетического инструмента
   datetime  stop=(TimeCurrent()/SECONDS_IN_MINUTE)*SECONDS_IN_MINUTE;  // время бара M1 конечной даты
   datetime  start=stop-31*SECONDS_IN_DAY;                              // время бара M1 начальной даты
   datetime  start_date=0;
   
//--- копируем исторические данные M1 за месяц для всех символов корзины инструментов
   start/=SECONDS_IN_DAY;
   start*=SECONDS_IN_DAY;                                               // время бара D1 начальной даты
   for(i=0; i<BASKET_SIZE; i++)
     {
      if(CopyRates(ExtWeights[i].symbol,PERIOD_M1,start,stop,symbols_rates[i].rates)<=0)
        {
         PrintFormat("cannot copy rates for %s,M1 from %s to %s [%d]",ExtWeights[i].symbol,TimeToString(start),TimeToString(stop),GetLastError());
         return(false);
        }
      PrintFormat("%u %s,M1 rates from %s",ArraySize(symbols_rates[i].rates),ExtWeights[i].symbol,TimeToString(symbols_rates[i].rates[0].time));
      symbols_rates[i].index=0;
      //--- находим и устанавливаем минимальную ненулевую начальную дату из корзины символов
      if(start_date<symbols_rates[i].rates[0].time)
         start_date=symbols_rates[i].rates[0].time;
     }
   Print("start date set to ",start_date);
   
//--- резерв массива исторических данных для избежания перераспределения памяти при изменении размера массива
   reserve=int(stop-start)/60;
   
//--- установим начало всех исторических данных корзины символов на одну дату (start_date)
   for(i=0; i<BASKET_SIZE; i++)
     {
      int j=0;
      //--- до тех пор, пока j меньше количества данных в массиве rates и
      //--- время по индексу j в массиве меньше времени start_date - увеличиваем индекс
      while(j<ArraySize(symbols_rates[i].rates) && symbols_rates[i].rates[j].time<start_date)
         j++;
      //--- если индекс был увеличен, и он в пределах массива rates - уменьшим его на 1 для компенсации последнего приращения
      if(j>0 && j<ArraySize(symbols_rates[i].rates))
         j--;
      //--- запишем полученный индекс в структуру
      symbols_rates[i].index=j;
     }
      
//--- таймсерии USD index
   int    array_size=0;
   
//--- первый бар таймсерии M1
   rate.time=start_date;
   rate.real_volume=0;
   rate.spread=0;

//--- до тех пор, пока время бара меньше времени конечной даты таймсерии M1
   while(!IsStopped() && rate.time<stop)
     {
      //--- если исторические данные бара инструмента рассчитаны
      if(CalculateRate(rate,symbols_rates))
        {
         //--- увеличиваем массив-таймсерию на 1 и добавляем в него рассчитанные данные
         ArrayResize(usdx_rates,array_size+1,reserve);
         usdx_rates[array_size]=rate;
         array_size++;
         //--- сбросим размер резервного значения размера массива, так как он применяется только при первом изменении размера
         reserve=0;
        }
      
      //--- следующий бар таймсерии M1
      rate.time+=PeriodSeconds(PERIOD_M1);
      start_date=rate.time;
      
      //--- в цикле по списку инструментов корзины
      for(i=0; i<BASKET_SIZE; i++)
        {
         //--- получаем текущий индекс данных
         int j=symbols_rates[i].index;
         //--- пока j в пределах данных таймсерии и, если время бара по индексу j меньше времени, установленного для этого бара в rate.time, увеличиваем индекс j
         while(j<ArraySize(symbols_rates[i].rates) && symbols_rates[i].rates[j].time<rate.time)
            j++;
         //--- если j в пределах данных таймсерии и время в start_date меньше времени данных таймсерии по индексу j
         //--- и время в таймсерии по индексу j меньше, либо равно времени в rate.time - записывавем в start_date время из таймсерии по индексу j
         if(j<ArraySize(symbols_rates[i].rates) && start_date<symbols_rates[i].rates[j].time && symbols_rates[i].rates[j].time<=rate.time)
            start_date=symbols_rates[i].rates[j].time;
        }
      
      //--- в цикле по списку инструментов корзины
      for(i=0; i<BASKET_SIZE; i++)
        {
         //--- получаем текущий индекс данных
         int j=symbols_rates[i].index;
         //--- пока j в пределах данных таймсерии и, если время бара по индексу j меньше времени, установленного для этого бара в start_date, увеличиваем индекс j
         while(j<ArraySize(symbols_rates[i].rates) && symbols_rates[i].rates[j].time<=start_date)
            symbols_rates[i].index=j++;
        }
      //--- в rate.time запишем время из start_date для последующего бара
      rate.time=start_date;
     }
     
//--- добавляем в базу созданную таймсерию
   if(array_size>0)
     {
      if(!IsStopped())
        {
         int cnt=CustomRatesReplace(custom_symbol,usdx_rates[0].time,usdx_rates[ArraySize(usdx_rates)-1].time+1,usdx_rates);
         Print(cnt," ",custom_symbol,",M1 rates from ",usdx_rates[0].time," to ",usdx_rates[ArraySize(usdx_rates)-1].time," added");
        }
     }
//--- успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Подготовка последних тиков                                       |
//+------------------------------------------------------------------+
void PrepareLastTicks(const string custom_symbol)
  {
   str_ticks symbols_ticks[BASKET_SIZE];
   int       i,j,cnt,reserve=0;
   MqlTick   usdx_ticks[];                                        // массив тиков синтетического инструмента
   MqlTick   tick={0};                                            // данные одного тика синтетического инструмента

   long time_to=TimeCurrent()*1000;                               // время конца тиковых данных в миллисекундах
   long start_date=(time_to/MSECS_IN_MINIUTE)*MSECS_IN_MINIUTE;   // время открытия бара в миллисекундах со временем TimeCurrent()
   long time_from=start_date-MSECS_IN_MINIUTE;                    // время начала копирования тиковых данных в миллисекундах 

//--- если были тики за последнюю минуту
   if(SymbolInfoTick(custom_symbol,tick) && tick.time_msc>=start_date)
     {
      Print(custom_symbol," last tick at ",datetime(tick.time_msc/1000),":",IntegerToString(tick.time_msc%1000,3,'0'));
      str_rates symbols_rates[BASKET_SIZE];
      bool      copy_error=false;
      
      //--- в цикле по количеству символов в корзине инструментов
      for(i=0; i<BASKET_SIZE; i++)
        {
         //--- копируем два последних бара исторических данных инструмента
         if(CopyRates(ExtWeights[i].symbol,PERIOD_M1,0,2,symbols_rates[i].rates)!=2)
           {
            Print("cannot copy ",ExtWeights[i].symbol," rates [",GetLastError(),"]");
            copy_error=true;
            break;
           }
         symbols_rates[i].index=1;
        }
      
      //--- рассчитываем данные последней минуты
      if(!copy_error)
        {
         MqlRates rate;
         double   values[BASKET_SIZE]={0};
         rate.time=datetime(start_date/1000);
         rate.real_volume=0;
         rate.spread=0;
         
         //--- если исторические данные бара инструмента рассчитаны
         if(CalculateRate(rate,symbols_rates))
           {
            MqlRates usdx_rates[1];
            
            //--- заменяем рассчитанными данными бара историю последнего бара M1 пользовательского инструмента
            usdx_rates[0]=rate;
            cnt=CustomRatesUpdate(custom_symbol,usdx_rates);
            if(cnt==1)
              {
               Print(custom_symbol,",M1 last minute rate ",rate.time," added");
               //--- время в миллисекундах последующих добавляемых тииков
               start_date=tick.time_msc+1;
              }
           }
          else
            Print(custom_symbol,",M1 last minute rate ",rate.time," ",rate.open," ",rate.high," ",rate.low," ",rate.close," not updated");
        }
     }
     
//--- получаем все тики с начала предыдущей минуты
   for(i=0; i<BASKET_SIZE; i++)
     {
      if(CopyTicksRange(ExtWeights[i].symbol,symbols_ticks[i].ticks,COPY_TICKS_ALL,time_from,time_to)<=0)
        {
         PrintFormat("cannot copy ticks for %s",ExtWeights[i].symbol);
         return;
        }
      PrintFormat("%u %s ticks from %s",ArraySize(symbols_ticks[i].ticks),ExtWeights[i].symbol,TimeToString(symbols_ticks[i].ticks[0].time,TIME_DATE|TIME_SECONDS));
      symbols_ticks[i].index=0;
     }
     
//--- резерв массива тиков для избегания перераспределения памяти при изменении размера
   reserve=ArraySize(symbols_ticks[0].ticks);
   
//--- установим начало всех тиков на одну дату start_date
   j=0;
   while(j<ArraySize(symbols_ticks[0].ticks) && symbols_ticks[0].ticks[j].time_msc<start_date)
      j++;
   if(j>=ArraySize(symbols_ticks[0].ticks))
     {
      Print("no ticks at ",datetime(start_date/1000),":",IntegerToString(start_date%1000,3,'0')," (",start_date/1000,")" );
      return;
     }
   symbols_ticks[0].index=j;
   long time_msc=symbols_ticks[0].ticks[j].time_msc;
   for(i=1; i<BASKET_SIZE; i++)
     {
      j=0;
      while(j<ArraySize(symbols_ticks[i].ticks) && symbols_ticks[i].ticks[j].time_msc<time_msc)
         j++;
      if(j>0 && j<ArraySize(symbols_ticks[i].ticks))
         j--;
      symbols_ticks[i].index=j;
     }
     
//--- тики USD index
   double values[BASKET_SIZE]={0};
   int    array_size=0;
   
//--- первый тик
   tick.last=0;
   tick.volume=0;
   tick.flags=0;

//--- в цикле от индекса j (от начальной даты всех тиков корзины инструментов)
//--- по количеству полученных тиков первого инструмента корзины
   for(j=symbols_ticks[0].index; j<ArraySize(symbols_ticks[0].ticks); j++)
     {
      //--- записываем данные тика по индексу цикла j
      tick.time=symbols_ticks[0].ticks[j].time;          // время тика
      tick.time_msc=symbols_ticks[0].ticks[j].time_msc;  // время тика в миллисекундах
      
      //--- рассчитаем значение цены Bid по весам всех символов корзины инструментов
      values[0]=symbols_ticks[0].ticks[j].bid;
      symbols_ticks[0].index++;
      for(i=1; i<BASKET_SIZE; i++)
         values[i]=GetTickValue(symbols_ticks[i],symbols_ticks[0].ticks[j].time_msc);
      tick.bid=MAIN_COEFF;
      for(i=0; i<BASKET_SIZE; i++)
         tick.bid*=MathPow(values[i],ExtWeights[i].weight);
      //--- цена Ask равна рассчитанной цене Bid инструмента
      tick.ask=tick.bid;
      
      //--- добавляем рассчитанный тик в массив тиков синтетического инструмента
      ArrayResize(usdx_ticks,array_size+1,reserve);
      usdx_ticks[array_size]=tick;
      array_size++;
      
      //--- обнуляем размер резервированной памяти, так как он нужен только при первом ArrayResize
      reserve=0;
     }
     
//--- Добавляем в ценовую историю пользовательского инструмента данные из собранного массива тиков
   if(array_size>0)
     {
      Print(array_size," ticks from ",usdx_ticks[0].time,":",IntegerToString(usdx_ticks[0].time_msc%1000,3,'0')," prepared");
      cnt=CustomTicksAdd(custom_symbol,usdx_ticks);
      if(cnt>0)
         Print(cnt," ticks applied");
      else
         Print("no ticks applied");
     }
  }
//+------------------------------------------------------------------+
//| Расчёт цен и объёмов синтетического инструмента                  |
//+------------------------------------------------------------------+
bool CalculateRate(MqlRates& rate,str_rates& symbols_rates[])
  {
   double values[BASKET_SIZE]={0};
   long   tick_volume=0;
   int    i;
//--- получаем цены Open всех символов корзины инструментов в массив values[]
   for(i=0; i<BASKET_SIZE; i++)
      values[i]=GetRateValue(tick_volume,symbols_rates[i],rate.time,VALUE_OPEN);

//--- если тиковый объём нулевой, значит нет данных на этой минуте - возвращаем false
   if(tick_volume==0)
      return(false);
      
//--- запишем совокупный объем всех таймсерий
   rate.tick_volume=tick_volume;
   
//--- рассчитаем цену Open по ценам и весам всех инструментов корзины
   rate.open=MAIN_COEFF;
   for(i=0; i<BASKET_SIZE; i++)
      rate.open*=MathPow(values[i],ExtWeights[i].weight);
      
//--- рассчитаем цену High по ценам и весам всех инструментов корзины
   for(i=0; i<BASKET_SIZE; i++)
      values[i]=GetRateValue(tick_volume,symbols_rates[i],rate.time,VALUE_HIGH);
   rate.high=MAIN_COEFF;
   for(i=0; i<BASKET_SIZE; i++)
      rate.high*=MathPow(values[i],ExtWeights[i].weight);
      
//--- рассчитаем цену Low по ценам и весам всех инструментов корзины
   for(i=0; i<BASKET_SIZE; i++)
      values[i]=GetRateValue(tick_volume,symbols_rates[i],rate.time,VALUE_LOW);
   rate.low=MAIN_COEFF;
   for(i=0; i<BASKET_SIZE; i++)
      rate.low*=MathPow(values[i],ExtWeights[i].weight);
      
//--- рассчитаем цену Close по ценам и весам всех инструментов корзины
   for(i=0; i<BASKET_SIZE; i++)
      values[i]=GetRateValue(tick_volume,symbols_rates[i],rate.time,VALUE_CLOSE);
   rate.close=MAIN_COEFF;
   for(i=0; i<BASKET_SIZE; i++)
      rate.close*=MathPow(values[i],ExtWeights[i].weight);
      
//--- возвращаем результат проверки цен на корректность
   return(CheckRate(rate));
  }
//+------------------------------------------------------------------+
//| Возвращает указанную цену бара                                   |
//+------------------------------------------------------------------+
double GetRateValue(long &tick_volume,str_rates &symbol_rates,datetime time,ENUM_RATES_VALUES num_value)
  {
   double value=0;                  // получаемое значение
   int    index=symbol_rates.index; // индекс данных
   
//--- если индекс в пределах таймсерии
   if(index<ArraySize(symbol_rates.rates))
     {
      //--- в зависимости от типа запрашиваемых данных записываем соответствующее значение в переменную value
      switch(num_value)
        {
         //--- цена Open
         case VALUE_OPEN:
            if(symbol_rates.rates[index].time<time)
               value=symbol_rates.rates[index].close;
            else
              {
               if(symbol_rates.rates[index].time==time)
                 {
                  value=symbol_rates.rates[index].open;
                  //--- при запросе цены Open добавляем тиковый объём к переменной tick_volume, передаваемой по ссылке,
                  //--- для получения суммарного объёма всех символов корзины инструментов
                  tick_volume+=symbol_rates.rates[index].tick_volume;
                 }
              }
            break;
         //--- цена High
         case VALUE_HIGH:
            if(symbol_rates.rates[index].time<time)
               value=symbol_rates.rates[index].close;
            else
              {
               if(symbol_rates.rates[index].time==time)
                  value=symbol_rates.rates[index].high;
              }
            break;
         //--- цена Low
         case VALUE_LOW:
            if(symbol_rates.rates[index].time<time)
               value=symbol_rates.rates[index].close;
            else
              {
               if(symbol_rates.rates[index].time==time)
                  value=symbol_rates.rates[index].low;
              }
            break;
         //--- цена Close
         case VALUE_CLOSE:
            if(symbol_rates.rates[index].time<=time)
               value=symbol_rates.rates[index].close;
            break;
        }
     }
     
//--- возвращаем полученное значение
   return(value);
  }
//+------------------------------------------------------------------+
//| Проверка цен на корректность и возврат результата проверки       |
//+------------------------------------------------------------------+
bool CheckRate(MqlRates &rate)
  {
//--- если цены представляют собой не корректные действительные числа, или меньше, либо равны нулю - возвращаем false
   if(!MathIsValidNumber(rate.open) || !MathIsValidNumber(rate.high) || !MathIsValidNumber(rate.low) || !MathIsValidNumber(rate.close))
      return(false);
   if(rate.open<=0.0 || rate.high<=0.0 || rate.low<=0.0 || rate.close<=0.0)
      return(false);
      
//--- нормализуем цены до требуемого количества знаков
   rate.open=NormalizeDouble(rate.open,ExtDigits);
   rate.high=NormalizeDouble(rate.high,ExtDigits);
   rate.low=NormalizeDouble(rate.low,ExtDigits);
   rate.close=NormalizeDouble(rate.close,ExtDigits);
   
//--- корректируем при необходимости цены
   if(rate.high<rate.open)
      rate.high=rate.open;
   if(rate.low>rate.open)
      rate.low=rate.open;
   if(rate.high<rate.close)
      rate.high=rate.close;
   if(rate.low>rate.close)
      rate.low=rate.close;
      
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Возвращает значение тика                                         |
//+------------------------------------------------------------------+
double GetTickValue(str_ticks &symbol_ticks,long time_msc)
  {
   double value=0;
//--- если индекс данных, записанный в структуре symbol_ticks, находится в пределах массива тиков структуры
   if(symbol_ticks.index<ArraySize(symbol_ticks.ticks))
     {
      //--- получаем значение цены Bid из структуры по индексу данных
      value=symbol_ticks.ticks[symbol_ticks.index].bid;
      //--- если время в структуре в миллисекундах по индексу в структуре меньше переданного в функцию времени
      if(symbol_ticks.ticks[symbol_ticks.index].time_msc<time_msc)
        {
         //--- до тех пор, пока индекс находится в пределах таймсерии в структуре и
         //--- если время в структуре меньше переданного в функцию времени - увеличиваем индекс
         while(symbol_ticks.index<ArraySize(symbol_ticks.ticks) && symbol_ticks.ticks[symbol_ticks.index].time_msc<time_msc)
            symbol_ticks.index++;
        }
     }
//--- возвращаем полученное значение
   return(value);
  }
//+------------------------------------------------------------------+
