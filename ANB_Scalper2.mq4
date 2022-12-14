//+------------------------------------------------------------------+
//|                                                 ANB_Scalper2.mq4 |
//|                                                   Agustin Bottos |
//|                                 https://www.agustinbottos.com.ar |
//+------------------------------------------------------------------+
#property copyright "Agustin Bottos"
#property link      "https://www.agustinbottos.com.ar"
#property version   "1.00"
#property strict

extern string FiboComment="FIBO SETTINGS";
extern int fibo_candles=60;
extern int fibo_magic=12132321;


double lastbid=0;
double lastask=0;
datetime  lastorderfibo;
bool stoch_sell_signal=false;
int stoch_sell_signal_tick_duration=0;
bool fibo_sell_signal[7];
int fibo_sell_signal_tick_duration=0;
bool stoch_buy_signal=false;
int stoch_buy_signal_tick_duration=0;
bool fibo_buy_signal[7];
int fibo_buy_signal_tick_duration=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
   fibo_scalper(PERIOD_H1,fibo_candles);
   lastask=Ask;
   lastbid=Bid;
  }
//+------------------------------------------------------------------+



// FIBO SCALPER SOURCE CODE //

void fibo_scalper(int period,int Candles){


double level[7];

int lowestcandle=iLowest(_Symbol,period,MODE_LOW,Candles,0);
int highestcandle=iHighest(_Symbol,period,MODE_HIGH,Candles,0);


double lowestprice=iLow(_Symbol,period,lowestcandle);
double highestprice=iHigh(_Symbol,period,highestcandle);

double difference=highestprice-lowestprice;

level[0]=lowestprice;
level[1]=NormalizeDouble(lowestprice+(difference*0.236),Digits);
level[2]=NormalizeDouble(lowestprice+(difference*0.382),Digits);
level[3]=NormalizeDouble(lowestprice+(difference*0.5),Digits);
level[4]=NormalizeDouble(lowestprice+(difference*0.618),Digits);
level[5]=NormalizeDouble(lowestprice+(difference*0.786),Digits);
level[6]=highestprice;


double macd= iMACD(_Symbol,period,12,26,9,PRICE_CLOSE,MODE_MAIN,0);

if (TimeCurrent()>(lastorderfibo+(60*60))){
for (int x=1;x<7;x++){

if (fibo_get_cant_orders()==0){
if (fibo_signal_sell(level[x],x)){
if (stoch_fibo_sell_signal(period)){
if (macd>0){

int SellTicket=OrderSend(Symbol(), OP_SELL, 0.01, Bid, 3, 0, level[x-1], "Fibonacci Scalper", fibo_magic, 0);
lastorderfibo=TimeCurrent();
}}}
}else{
if (fibo_get_last_order_type()==1){
if (Bid - fibo_get_last_order_price() >= 120*_Point){
if (fibo_signal_sell(level[x],x)){
if (stoch_fibo_sell_signal(period)){
if (macd>0){
fibo_modify_orders(level[x-1]);
int SellTicket=OrderSend(Symbol(), OP_SELL, fibo_get_last_order_lots()*2, Bid, 3, 0, level[x-1], "Fibonacci Scalper", fibo_magic, 0);
lastorderfibo=TimeCurrent();
}}}}}}}


for (int x=0;x<6;x++){

if (fibo_get_cant_orders()==0){
if (fibo_signal_buy(level[x],x)){
if (stoch_fibo_buy_signal(period)){
if (macd<0){
int BuyTicket=OrderSend(Symbol(), OP_BUY, 0.01, Ask, 3, 0, level[x+1], "Fibonacci Scalper", fibo_magic, 0);
lastorderfibo=TimeCurrent();
}}}}else{
if (fibo_get_last_order_type()==2){
if (fibo_get_last_order_price() - Ask >= 120*_Point){
if (fibo_signal_buy(level[x],x)){
if (stoch_fibo_buy_signal(period)){
if (macd>0){
fibo_modify_orders(level[x+1]);
int BuyTicket=OrderSend(Symbol(), OP_BUY, fibo_get_last_order_lots()*2, Ask, 3, 0, level[x+1], "Fibonacci Scalper", fibo_magic, 0);
lastorderfibo=TimeCurrent();
}}}}}}

}}

}




bool stoch_fibo_sell_signal(int period){

double stochK0= iStochastic(_Symbol,period,5,3,3,MODE_SMA,0,MODE_MAIN,0);
double stochD0= iStochastic(_Symbol,period,5,3,3,MODE_SMA,0,MODE_SIGNAL,0);
double stochK1= iStochastic(_Symbol,period,5,3,3,MODE_SMA,0,MODE_MAIN,1);
double stochD1= iStochastic(_Symbol,period,5,3,3,MODE_SMA,0,MODE_SIGNAL,1);
if ((stochK0>80)&&(stochD0>80)){
stoch_sell_signal=true;

}
if ((stoch_sell_signal==true)&&(stoch_sell_signal_tick_duration<11)){
stoch_sell_signal_tick_duration++;
}else{
stoch_sell_signal=false;
stoch_sell_signal_tick_duration=0;
}
return stoch_sell_signal;
}


bool fibo_signal_sell(double level, int x){
if ((Bid<level)&&(lastbid>level)){
fibo_sell_signal[x]=true;
}
if ((fibo_sell_signal[x]==true)&&(fibo_sell_signal_tick_duration<11)){
fibo_sell_signal_tick_duration++;
}else{
fibo_sell_signal[x]=false;
fibo_sell_signal_tick_duration=0;
}
return fibo_sell_signal[x];

}

bool stoch_fibo_buy_signal(int period){

double stochK0= iStochastic(_Symbol,period,5,3,3,MODE_SMA,0,MODE_MAIN,0);
double stochD0= iStochastic(_Symbol,period,5,3,3,MODE_SMA,0,MODE_SIGNAL,0);
double stochK1= iStochastic(_Symbol,period,5,3,3,MODE_SMA,0,MODE_MAIN,1);
double stochD1= iStochastic(_Symbol,period,5,3,3,MODE_SMA,0,MODE_SIGNAL,1);
if ((stochK0<20)&&(stochD0<20)){

stoch_buy_signal=true;
}
if ((stoch_buy_signal==true)&&(stoch_buy_signal_tick_duration<11)){
stoch_buy_signal_tick_duration++;
}else{
stoch_buy_signal=false;
stoch_buy_signal_tick_duration=0;
}
return stoch_buy_signal;
}


bool fibo_signal_buy(double level, int x){
if ((Ask<level)&&(lastask>level)){
fibo_buy_signal[x]=true;
}
if ((fibo_buy_signal[x]==true)&&(fibo_buy_signal_tick_duration<11)){
fibo_buy_signal_tick_duration++;
}else{
fibo_buy_signal[x]=false;
fibo_buy_signal_tick_duration=0;
}
return fibo_buy_signal[x];

}


int fibo_get_cant_orders(){
int fibo_cant_orders=0;
for (int x=0;x<OrdersTotal();x++){
if (OrderSelect(x,SELECT_BY_POS)){
if (OrderSymbol()==_Symbol){
if (OrderMagicNumber()==fibo_magic){
fibo_cant_orders++;
}}}}
return fibo_cant_orders;
}

double fibo_get_last_order_price(){
double fibo_last_order_price=0;
for (int x=OrdersTotal()-1;x>-1;x--){
if (OrderSelect(x,SELECT_BY_POS)){
if (OrderSymbol()==_Symbol){
if (OrderMagicNumber()==fibo_magic){
fibo_last_order_price=OrderOpenPrice();
break;
}}}}
return fibo_last_order_price;
}

double fibo_get_last_order_lots(){
double fibo_last_order_lots=0;
for (int x=OrdersTotal()-1;x>-1;x--){
if (OrderSelect(x,SELECT_BY_POS)){
if (OrderSymbol()==_Symbol){
if (OrderMagicNumber()==fibo_magic){
fibo_last_order_lots=OrderLots();
break;
}}}}
return fibo_last_order_lots;
}



int fibo_get_last_order_type(){
int fibo_last_order_type=0;
for (int x=OrdersTotal()-1;x>-1;x--){
if (OrderSelect(x,SELECT_BY_POS)){
if (OrderSymbol()==_Symbol){
if (OrderMagicNumber()==fibo_magic){
if (OrderType()==OP_SELL){
fibo_last_order_type=1;
break;
}else{
fibo_last_order_type=2;
break;
}
}}}}
return fibo_last_order_type;
}


void fibo_modify_orders(double level){
for (int x=0;x<OrdersTotal();x++){
if (OrderSelect(x,SELECT_BY_POS)){
if (OrderSymbol()==_Symbol){
if (OrderMagicNumber()==fibo_magic){
OrderModify(OrderTicket(),OrderOpenPrice(),0,level,0,NULL);
}}
}
}


}