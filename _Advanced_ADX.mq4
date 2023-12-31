//+------------------------------------------------------------------+
//|                                                 Advanced_ADX.mq4 |
//|                                      Copyright © 2018, Harry Gui |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Harry Gui"
#property link      " "
//----
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
//----
extern int ADXPeriod = 14;
extern int _histWidth = 4;
//----
double ExtBuffer1[];
double ExtBuffer2[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0, ExtBuffer1);
   SetIndexStyle(0, DRAW_HISTOGRAM, 0, _histWidth);
//----
   SetIndexBuffer(1, ExtBuffer2);
   SetIndexStyle(1, DRAW_HISTOGRAM, 0, _histWidth);
//----
   IndicatorShortName("Advanced_ADX (" + ADXPeriod + ")");
   
   //--- set levels    
   IndicatorSetInteger(INDICATOR_LEVELS,1); 
   
   SetLevelStyle(STYLE_SOLID,2,Gold);
   SetLevelValue(0,20);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i, limit;
   double ADX0,ADX1,ADX2;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) 
       return(-1);
   if(counted_bars > 0) 
       counted_bars--;
   limit = Bars - counted_bars; 
//----   
   for(i = 0; i < limit ; i++)
     {
       ADX0 = iADX(NULL, 0, ADXPeriod, PRICE_CLOSE, MODE_MAIN, i);
       ADX1 = iADX(NULL, 0, ADXPeriod, PRICE_CLOSE, MODE_PLUSDI, i);
       ADX2 = iADX(NULL, 0, ADXPeriod, PRICE_CLOSE, MODE_MINUSDI, i);
       //----
       if(ADX1 >= ADX2)
         {
           ExtBuffer1[i] = ADX0;
           ExtBuffer2[i] = 0;
         }
       else
         {
           ExtBuffer1[i] = 0;
           ExtBuffer2[i] = ADX0;
         }
     }
   return(0);
  }
//+------------------------------------------------------------------+

