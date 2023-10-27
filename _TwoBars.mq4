//+------------------------------------------------------------------+
#property copyright "Harry Gui"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2

double Up[],Dn[];
extern int arrow_indent=22;
bool pause = false;
bool bullishSignLast = false, bearishSignLast = false;
bool firstSignal = true;
//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorDigits(Digits);
   
   SetIndexBuffer(0,Up);
   SetIndexBuffer(1,Dn);
   SetIndexStyle(0,DRAW_ARROW,EMPTY);
   SetIndexStyle(1,DRAW_ARROW,EMPTY);
   
   SetIndexLabel(0,"Example");
   
   SetIndexArrow(0,233);
   SetIndexArrow(1,234);
   
   return(0);
}
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],
                const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[])
{ 
   int i,CountBars = Bars-1;
   
   //debug mode
   //if(!pause) pause = true;
   //else return(0);
   //end
   
   //CountBars = 60; //debug
   
   for(i=CountBars; i>0; i--)
   {
      Up[i] = 0.0;
      Dn[i] = 0.0;
      
      //Bearish Signal
      if(
      Close[i] < Close[i+2] //The close of third(current) bar is less than the close of first bar
      && Close[i+1] < Close[i+2] //The close of second bar is less than the close of first bar
      && Close[i] < Low[i+2] // The close of third(current) bar is less than the low of first bar  
      && High[i+1] < High[i+2] //The high of second bar should not exceed the high of triger bar
      && High[i] < High[i+2] //The high of third(current) bar should not exceed the high of triger bar
      && Low[i] < Low[i+1]
      )
      {
         //Print(TimeToStr(Time[i]), " :: ", Close[i], "  <  ", Close[i+2], " :: ", TimeToStr(Time[i+2]), " bullishSignLast:",bullishSignLast, " bearishSignLast:", bearishSignLast);
         if(bullishSignLast || firstSignal)
         {
            firstSignal = false;
            Dn[i]= Close[i];//High[i]+arrow_indent*Point; //down arrow
            bullishSignLast = false;
            bearishSignLast = true;
         }
         
      }
      
      //Bullish Signal
      if(
      Close[i] > Close[i+2] 
      && Close[i+1] > Close[i+2] 
      && Close[i] > High[i+2]  
      && Low[i+1] > Low[i+2] 
      && Low[i] > Low[i+2] 
      && High[i] > High[i+1]
      )
      {
         //Print(TimeToStr(Time[i]), " :: ", Close[i], "  >  ", Close[i+2], " :: ", TimeToStr(Time[i+2]), " bullishSignLast:",bullishSignLast, " bearishSignLast:", bearishSignLast);
        
         if(bearishSignLast || firstSignal)
         {
            firstSignal = false;
            Up[i]= Close[i];//Low[i]-arrow_indent*Point; //up arrow
            bearishSignLast = false;
            bullishSignLast = true;
         }
         
      }
   
   }
   return(0);
}
//+------------------------------------------------------------------+
int deinit() { return(0); }
//+------------------------------------------------------------------+

