//+------------------------------------------------------------------+
#property copyright ""

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

input int MAPeriod=14; // Period
input int BodyCoef=1;

double BodyStatBuffer[];
double Up[],Dn[];
int MAShift=-2;   // Shift

//+------------------------------------------------------------------+
int init()
{
   IndicatorDigits(Digits);
   
   SetIndexShift(2,MAShift);
   
   SetIndexBuffer(0,Up);
   SetIndexBuffer(1,Dn);
   SetIndexBuffer(2,BodyStatBuffer);
   
   SetIndexDrawBegin(2,MAShift+MAPeriod);
   
   SetIndexStyle(0,DRAW_ARROW,EMPTY,3);
   SetIndexStyle(1,DRAW_ARROW,EMPTY,3);
   SetIndexStyle(2,DRAW_LINE, EMPTY,3);
   
   SetIndexLabel(0,"Example");
   
   SetIndexArrow(0,233);
   SetIndexArrow(1,234);
   
   return(0);
}
//+------------------------------------------------------------------+
int start()
{   
   int i,j,CountBars=Bars-1;
   double BodyTotal;
   double BodyAverage;
   double BodyStat;
   
   for(i=0; i<CountBars; i++)
   {
      BodyTotal = 0.0;
      BodyAverage = 0.0;
      BodyStat = 0.0;
      
      Up[i]=0.0; Dn[i]=0.0;//init array
      
      //get average pips between open and close prices for the past periods.
      for(j=0; j<MAPeriod; j++)
      {
         BodyTotal += MathAbs(Open[j+1] - Close[j+1]);
      }
      BodyAverage = BodyTotal/MAPeriod;
      
      //BodyStat is the Stat2PreValue
      BodyStat = iMA(NULL,0,MAPeriod,0,MODE_SMA,PRICE_CLOSE,i);
      //graphical representation of Stat2PreValue
      //BodyStatBuffer[i]=iMA(NULL,0,MAPeriod,0,MODE_SMA,PRICE_CLOSE,i);
      
      //Bullish Signal
      if(
      Close[i+2] < Open[i+2] &&
      Close[i+1] - Open[i+1] > BodyCoef * BodyAverage &&
      Close[i+1] > Open[i+2] &&
      (Open[i+1] - Close[i+1])/2 < BodyStat &&
      Open[i+1] <= MathMax(Close[i+2], Low[i+2])
      )
      {
         //Up[i]= Low[i] - (High[i] - Low[i]); 
         Up[i]= Open[i] - Point; 
      }
      
      //Bearish Signal
      if(
      Close[i+2] > Open[i+2] 
      && Close[i+1] - Open[i+1] < BodyCoef * BodyAverage 
      && Close[i+1] < Open[i+2] 
      && (Open[i+1] + Close[i+1])/2 > BodyStat 
      && Open[i+1] >= MathMin(Close[i+2], High[i+2])
      )
      {
         Dn[i]= Open[i] + Point; 
      }
      
      //Traditional Signal without use of MA
      /*
      if(
      Close[i+2]<Open[i+2] //first bar being bearish
      && Close[i+1]>Open[i+1] //second bar being bullish
      && Open[i+2]<=Close[i+1] //open of first bar <= than close of second bar
      && Close[i+2]>=Open[i+1] //close of first bar >= than open of second bar
      ) 
      { 
         Up[i]= Low[i] - (High[i] - Low[i]); 
      }
      
      //Bearish Signal
      if(
      Close[i+2]>Open[i+2]
      &&Close[i+1]<Open[i+1]
      && Open[i+2]>=Close[i+1] 
      && Close[i+2]<=Open[i+1] 
      )
      { 
         Dn[i]= High[i] + (High[i] - Low[i]); 
      }
      */
   }
   
   return(0);
}
//+------------------------------------------------------------------+
int deinit() { return(0); }
//+------------------------------------------------------------------+

