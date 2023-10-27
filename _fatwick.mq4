//+------------------------------------------------------------------+
//|                                                      FatWick.mq4 |
//|                                      Copyright © 2016, Harry Gui |
//|                                    http://www.AcornInvesting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Harry Gui, AcornInvesting.com"
#property link      "http://www.AcornInvesting.com"
#property version   "1.0"
#property strict
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_width1 2
#property indicator_width2 1
#property indicator_color1 Black 
#property indicator_color2 Black

double _aCloudPaintLow[],_aCloudPaintHigh[];

extern int MaxBarsForCalculation = 1200; //Max Bars For Calculation

static datetime PREVTIME;// = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int deinit() { /*ObjectsDeleteAll();*/ return(0); }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int init()
{
   SetIndexBuffer(0,_aCloudPaintLow);
   SetIndexBuffer(1,_aCloudPaintHigh);
   
   SetIndexLabel(0,"Low");
   SetIndexLabel(1,"High");
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,indicator_width1);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,indicator_width2);
   return(0);
}

int start()
{
   int __countedBars = IndicatorCounted(), __limit, __bar;
   
   if(__countedBars > 0) __countedBars--; 
   __limit = Bars - __countedBars;
   
   for(__bar = 0; __bar < __limit; __bar++)
   {
      _drawSingleBar(__bar);
   }
   
   /*if(PREVTIME == Time[0]) 
   {
      _drawSingleBar(0);
      return(0);
   }
   else
   {
      for(int __bar=0; __bar<_getCountBars(); __bar++)
      {
         _drawSingleBar(__bar);
      }
   }
   PREVTIME = Time[0];*/
   return(0);
}

void _drawSingleBar(int __bar)
{
   _aCloudPaintLow[__bar]     = High[__bar];
   _aCloudPaintHigh[__bar]    = Low[__bar];
}

int _getCountBars()
{
   int __countBars;
   if(MaxBarsForCalculation) __countBars = MaxBarsForCalculation;
   else __countBars = iBars(NULL, PERIOD_CURRENT) - 26;
   return __countBars;
}