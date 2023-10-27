//+------------------------------------------------------------------+
//|                                             Keltner Channels.mq4 |
//|                                               Coded by Harry Gui |
//|                                      Copyright © 2016, Harry Gui |
//|                                    http://www.AcornInvesting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Harry Gui"
#property link      "http://www.AcornInvesting.com"
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 DarkTurquoise
#property indicator_color2 DarkTurquoise
#property indicator_color3 DarkTurquoise

#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 3

#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_DOT
#property indicator_width2 1

#property indicator_type3 DRAW_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_width3 3

extern int _periodEMA = 14;
extern int _periodATR = 14;
extern double _numberOfATR = 1.5;

double upper[], middle[], lower[];

int init()
{
   //SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,3);
   SetIndexShift(0,0);
   SetIndexDrawBegin(0,0);
   SetIndexBuffer(0,upper);
   SetIndexLabel(0,"Keltner Upper");
   
   //SetIndexStyle(1,DRAW_LINE,STYLE_DOT,1);
   SetIndexShift(1,0);
   SetIndexDrawBegin(1,0);
   SetIndexBuffer(1,middle);
   SetIndexLabel(1,"Keltner Middle");
   
   //SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,3);
   SetIndexShift(2,0);
   SetIndexDrawBegin(2,0);
   SetIndexBuffer(2,lower);
   SetIndexLabel(2,"Keltner Lower");
   return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   double avg;
   
   for(int x=0; x<limit; x++)
   {
      middle[x] = iMA(NULL, 0, _periodEMA, 0, MODE_EMA, PRICE_CLOSE, x);
      avg  = findAvg(_periodATR, x);
      upper[x] = middle[x] + avg * _numberOfATR;
      lower[x] = middle[x] - avg * _numberOfATR;
   }
   return(0);
}

double findAvg(int __period, int shift) 
{
   /*double sum=0;
   for (int x=shift;x<(shift+__period);x++) {     
      sum += High[x]-Low[x];
   }
   sum = sum/__period;
   return (sum);*/
   
   double _valueATR = iATR(NULL,PERIOD_CURRENT,__period,shift);
   return (_valueATR);
}