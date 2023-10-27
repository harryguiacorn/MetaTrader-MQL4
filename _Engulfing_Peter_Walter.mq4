//+------------------------------------------------------------------+
#property copyright ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

double Up[],Dn[];
bool shownInfo=false;
double _fraction = 1/Digits();
double _offsetArrow = 20 * _fraction; //offset arrow by x pips 
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
      Close[i+1] > Open[i+1] &&
      Open[i+1] <= Close[i+2] &&
      Open[i+1] <= Open[i+2] &&
      Close[i+1] >= Open[i+2] &&
      Close[i+1] >= Close[i+2] &&
      High[i+1] > High[i+2] &&
      Low[i+1] < Low[i+2]
      ) 
      { 
         Up[i]= Close[i+1] - _offsetArrow;
         //ObjectCreate("Bullish",OBJ_TEXT);
         ObjectSetText("Bullish", DoubleToStr(Ask-Bid, Digits));
      }
      
      //Bearish Signal
      if(
      Close[i+1] < Open[i+1] &&
      Open[i+1] >= Close[i+2] &&
      Open[i+1] >= Open[i+2] &&
      Close[i+1] <= Open[i+2] &&
      Close[i+1] <= Close[i+2] &&
      High[i+1] > High[i+2] &&
      Low[i+1] < Low[i+2]
      )
      { 
         Dn[i]= Close[i+1] + _offsetArrow;
      }
      
   }
   
   return(0);
}
//+------------------------------------------------------------------+
int deinit() { return(0); }
//+------------------------------------------------------------------+

