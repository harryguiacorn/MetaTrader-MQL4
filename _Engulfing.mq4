//+------------------------------------------------------------------+
#property copyright ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

double Up[],Dn[];
bool shownInfo=false;

//---- input parameters
extern int BiggestCandlePeriod=6;
//+------------------------------------------------------------------+
int init()
{
   SetIndexBuffer(0,Up);
   SetIndexBuffer(1,Dn);

   SetIndexStyle(0,DRAW_ARROW,EMPTY,3);
   SetIndexStyle(1,DRAW_ARROW,EMPTY,3);
   
   SetIndexArrow(0,233);
   SetIndexArrow(1,234);
   
   return(0);
}
//+------------------------------------------------------------------+
int start()
{   
   int i,CountBars=Bars-1;
   double sum=0;
   
   for(i=0; i<CountBars; i++)
   {
      Up[i]=0.0; Dn[i]=0.0;//init array
      
      //Bullish Signal
      if(
      Close[i+2]<Open[i+2] //first bar being bearish
      && Close[i+1]>Open[i+1] //second bar being bullish
      && Open[i+2]<=Close[i+1] //open of first bar <= than close of second bar
      && Close[i+2]>=Open[i+1] //close of first bar >= than open of second bar
      ) 
      { 
         
         if(_biggestCandle(i+1,BiggestCandlePeriod))
         {
            Up[i]= Open[i]; 
         }
      }
      
      //Bearish Signal
      if(
      Close[i+2]>Open[i+2]
      && Close[i+1]<Open[i+1]
      && Open[i+2]>=Close[i+1] 
      && Close[i+2]<=Open[i+1] 
      )
      { 
         if(_biggestCandle(i+1,BiggestCandlePeriod))
         {
            Dn[i]= Open[i]; 
         }
      }
      
   }
   
   return(0);
}

bool _biggestCandle(int __engulfingCandleIndex, int __numberPreviousCandles)
{
   double __tempCandleRange, __engulfingCandleRange = MathAbs(Close[__engulfingCandleIndex] - Open[__engulfingCandleIndex]);

   for(int __i=__engulfingCandleIndex+1;__i<__engulfingCandleIndex+__numberPreviousCandles+1;__i++)
   {
      __tempCandleRange = MathAbs(Close[__i] - Open[__i]);
      if(__engulfingCandleRange < __tempCandleRange) return false;   
   }
   return true;
}

//+------------------------------------------------------------------+
int deinit() { return(0); }
//+------------------------------------------------------------------+

