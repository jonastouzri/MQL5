//+------------------------------------------------------------------+
//|                                            PositionHandlerV2.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>

class PositionHandlerV2{

   double LOT;                      // 100.000

   
   double risk;                     // risk percentage of equity
   double riskRewardRatio;          // risk to reward ratio percentage
   double triggerRatio;                  // percentage of rrr where trailing sl will be adjusted
   
   
   double openPrice;                // trigger -> somewhere btw openPrice and tp
   double slPrice;                 
   double triggerPrice;          
   double tpPrice;
   
   double slPoints;
   double lotSize;
   
   ulong position;
   CTrade trade;
   
   //+++++++++++++++++++++++++++++++++++++
   
   PositionHandlerV2(double _risk, double _riskRewardRatio){
   
      risk = _risk;
      riskRewardRatio = _riskRewardRatio;
      triggerRatio = riskRewardRatio/2;
      
      LOT  = (long) 1/Point();   // fixme cast?
   }
   
   
   //+++++++++++++++++++++++++++++++++++++
   // price when selling
   double 
   getBidPrice(){
      return SymbolInfoDouble(_Symbol, SYMBOL_BID);    
   }

   //+++++++++++++++++++++++++++++++++++++
   // price when buying
   double 
   getAskPrice(){
      return SymbolInfoDouble(_Symbol, SYMBOL_ASK);    
   }
   //+++++++++++++++++++++++++++++++++++++
   // fixme in buffer class
   double
   getAtr(ulong lookBack, ulong index){
      
      int atrHandle = iATR(_Symbol,_Period, 14);
      double atr[];
      ArraySetAsSeries(atr, true);
      CopyBuffer(atrHandle, 0 ,0, (int)lookBack, atr);
      return atr[index];
   }
   //+++++++++++++++++++++++++++++++++++++
   double 
   getLotSize(){      
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double moneyAtRisk = equity*risk/100;
      double posSize = moneyAtRisk / slPoints;              // 10 euro / 5pip(50points) = 10/0,0005 = 20000
      return posSize/LOT;                                   // 20000/100000 = 0.2

   }
   
   
   //+++++++++++++++++++++++++++++++++++++
   //+++++++++++++++++++++++++++++++++++++
   void
   initLongPosition(){          
      openPrice = NormalizeDouble(getAskPrice(), _Digits);
      slPrice = NormalizeDouble(openPrice - 2*getAtr(2, 1), _Digits);
      slPoints = NormalizeDouble(openPrice-slPrice, _Digits);
      tpPrice = NormalizeDouble(openPrice + slPoints*riskRewardRatio, _Digits); 
      triggerPrice = NormalizeDouble(openPrice + slPoints*triggerRatio, _Digits); 
      lotSize = NormalizeDouble(getLotSize(), 2);                
   }
   //+++++++++++++++++++++++++++++++++++++
   
   void
   initShortPosition(){          
      openPrice = NormalizeDouble(getBidPrice(), _Digits);
      slPrice = NormalizeDouble(openPrice + 2*getAtr(2, 1), _Digits);
      slPoints = NormalizeDouble(slPrice-openPrice, _Digits);
      tpPrice = NormalizeDouble(openPrice - slPoints*riskRewardRatio, _Digits); 
      triggerPrice = NormalizeDouble(openPrice - slPoints*triggerRatio, _Digits); 
      lotSize = NormalizeDouble(getLotSize(), 2);                
   }
   
   //+++++++++++++++++++++++++++++++++++++
   bool
   openLongPosition(){
      initLongPosition();
      
  
      if(!trade.Buy(lotSize, _Symbol, openPrice, slPrice, tpPrice)){
         Print("LONG POSITION FAILED = ", TimeCurrent());
         return false;
      }

      position = trade.ResultOrder();
      return true;
   
   }
   //+++++++++++++++++++++++++++++++++++++
   bool
   openShortPosition(){
   
      initShortPosition();
      if(!trade.Sell(lotSize, _Symbol, openPrice, slPrice, tpPrice)){
         Print("SHORT POSITION FAILED = ", TimeCurrent());
         return false;
      }

      position = trade.ResultOrder();
      return true;
      
   }
   
   //+++++++++++++++++++++++++++++++++++++
   bool
   updateLongPosition(){
   
   
   
   
   
   }
   //+++++++++++++++++++++++++++++++++++++
   bool
   updateShortPosition(){
   
   
   
   }


};
