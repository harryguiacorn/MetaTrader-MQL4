//+------------------------------------------------------------------+
//Chapter 8 Scalper 
#property copyright "Harry Gui"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 clrLime
#property indicator_color2 clrRed
#property indicator_color3 clrLime
#property indicator_color4 clrRed
#property indicator_color5 clrLime
#property indicator_color6 clrRed
#property indicator_width1 5
#property indicator_width2 5

static datetime PREVTIME = 0;
extern bool Show_Alert = false;
extern bool Show_Arrow = false;
bool _pause = false;
bool _bullishSignLast = false, _bearishSignLast = false;
bool _firstSignal = true;
double _aUp[],_aDn[];
double _aCloudPaintLowStrong[],_aCloudPaintHighStrong[],_aCloudPaintLowMild[],_aCloudPaintHighMild[];
double _fraction = 1/Digits();
double _offsetArrow = 20 * _fraction; //offset arrow by x pips 

double senkou_spanA;
double senkou_spanB;
//+------------------------------------------------------------------+
int init()
{
   IndicatorDigits(Digits);
   
   if(Show_Arrow)
   {
      SetIndexBuffer(0,_aUp);
      SetIndexBuffer(1,_aDn);
      SetIndexStyle(0,DRAW_ARROW,EMPTY,2);
      SetIndexStyle(1,DRAW_ARROW,EMPTY,2);
   }
   
   SetIndexBuffer(2,_aCloudPaintLowStrong);
   SetIndexBuffer(3,_aCloudPaintHighStrong);
   SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,indicator_width1,clrGreen);
   SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,indicator_width2,clrRed);
   
   SetIndexBuffer(4,_aCloudPaintLowMild);
   SetIndexBuffer(5,_aCloudPaintHighMild);
   SetIndexStyle(4,DRAW_HISTOGRAM,EMPTY,indicator_width1,clrPaleGreen);
   SetIndexStyle(5,DRAW_HISTOGRAM,EMPTY,indicator_width2,clrLightCoral);
   
   SetIndexLabel(0,"Scalper");
   
   SetIndexArrow(0,233);
   SetIndexArrow(1,234);
   
   return(0);
}
//+------------------------------------------------------------------+
int start()
{   
   int __period, __countBars = Bars - 26;
   
   if(PREVTIME == Time[0]) {
      //_drawScalperSignal(0);//keep checking last candlestick
      //return(0);
   }
   PREVTIME = Time[0];
   _clearPaint(0);//keep clearing current bar paints
   for(__period=0; __period<__countBars; __period++)
   {
      _drawScalperSignal(__period);
   }
   
   //debug mode
   //if(!_pause) _pause = true; else return(0); __countBars = 60; //debug
   //end
   
   return(0);
}
void _drawScalperSignal(int __i)
{
   _aUp[__i] = 0.0;
   _aDn[__i] = 0.0;
   
   //Bearish Signal
   if(
   High[__i+1] < High[__i+2]  
   && High[__i] < High[__i+2]
   && Close[__i] < Close[__i+2]
   && Close[__i+1] < Close[__i+2]
   && (Low[__i] < Low[__i+2] || Low[__i+1] < Low[__i+2])
   )
   {
      //Print(TimeToStr(Time[__i]), " :: ", Close[__i], "  <  ", Close[__i+2], " :: ", TimeToStr(Time[__i+2]), " _bullishSignLast:",_bullishSignLast, " _bearishSignLast:", _bearishSignLast);
      //if(_bullishSignLast || _firstSignal)
      //{
         _firstSignal = false;
         _aDn[__i]= High[__i] + _offsetArrow;
         _bullishSignLast = false;
         _bearishSignLast = true;
         _drawCloudSignal(__i, false, Show_Alert);
      //}
   }
   
   //Bullish Signal
   if(
   Low[__i+1] > Low[__i+2] //2nd candlestick becomes a trigger bar if low of 2nd candlestick is higher than 1st candlestick.
   && Low[__i] > Low[__i+2] //low of 3rd candlestick must be above low of 1st candlestick
   && Close[__i] > Close[__i+2] //close of 3rd must be above close of 2nd bar
   && Close[__i+1] > Close[__i+2] //close of 2nd must be above close of 1st bar
   && (High[__i] > High[__i+2] || High[__i+1] > High[__i+2])//at one point 2nd or 3rd made new high
   )
   {
      //Print(TimeToStr(Time[__i]), " :: ", Close[__i], "  >  ", Close[__i+2], " :: ", TimeToStr(Time[__i+2]), " _bullishSignLast:",_bullishSignLast, " _bearishSignLast:", _bearishSignLast);
     
      //if(_bearishSignLast || _firstSignal)
      //{
         _firstSignal = false;
         _aUp[__i]= Low[__i] - _offsetArrow;
         _bearishSignLast = false;
         _bullishSignLast = true;
         _drawCloudSignal(__i, true, Show_Alert);
      //}
   }
}

//---Cloud.mp4 begin----
void _drawCloudSignal(int __period, bool __bBullishScalperSignal, bool __customShowAlert)
{
   senkou_spanA               =iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,__period+1);
   senkou_spanB               =iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,__period+1);
   
   //_aCloudArrawBullish[__period]=0.0; _aCloudArrawBearish[__period]=0.0;//init array
   
   uint __offsetTimeShift = 0;
   
   if(__bBullishScalperSignal)
   {
      if (
         Close[__period+__offsetTimeShift] > senkou_spanA &&
         Close[__period+__offsetTimeShift] > senkou_spanB //bullish signal above the cloud
         )
      {
         _signalLong(__period, 1, __customShowAlert);
      }
      else _signalLong(__period, 0, __customShowAlert);
   
   }
   else
   {
      if (
         Close[__period+__offsetTimeShift] < senkou_spanA &&
         Close[__period+__offsetTimeShift] < senkou_spanB
         )
      {
         _signalShort(__period, 1, __customShowAlert);
         
      }
      else _signalShort(__period, 0, __customShowAlert);
   }
  
}

void _signalLong(int __period, int __signalType, bool __customShowAlert)
{
   //_clearPaint(__period);
   switch(__signalType)
     {
      case 1:
         _aCloudPaintLowStrong[__period] = High[__period];
   	   _aCloudPaintHighStrong[__period] = Low[__period];
         break;
      default:
         _aCloudPaintLowMild[__period] = High[__period];
         _aCloudPaintHighMild[__period] = Low[__period];
         break;
     }
     
	if(   __customShowAlert 
	      && __period == 0
	  )
	{
	   Alert(
	   //Print(
	            "Long ", 
	            ChartSymbol(), ", ",
	            _getPeriod(ChartPeriod()),", ",
	            TimeToString(Time[__period]),", GMT ",
	            TimeHour(TimeGMT())
	            );
	}
}

void _signalShort(int __period, int __signalType, bool __customShowAlert)
{
   //_clearPaint(__period);
   switch(__signalType)
     {
      case 1:
         _aCloudPaintLowStrong[__period]  = Low[__period];
   	   _aCloudPaintHighStrong[__period] = High[__period];
         break;
      default:
         _aCloudPaintLowMild[__period]    = Low[__period];
      	_aCloudPaintHighMild[__period]   = High[__period];
         break;
     }
	
	if(   __customShowAlert 
	      && __period == 0
	  )
	{
	   Alert(
	   //Print(
	            "Short ",
	            ChartSymbol(), ", ",
	            _getPeriod(ChartPeriod()),", ",
	            TimeToString(Time[__period]),", GMT ",
	            TimeHour(TimeGMT())
	            );
	}
}

void _clearPaint(int __period)
{
   if(ArraySize(_aCloudPaintLowStrong) >=__period) _aCloudPaintLowStrong[__period]  = 0;
   if(ArraySize(_aCloudPaintHighStrong)>=__period) _aCloudPaintHighStrong[__period] = 0;
   if(ArraySize(_aCloudPaintLowMild)   >=__period) _aCloudPaintLowMild[__period]    = 0;
   if(ArraySize(_aCloudPaintHighMild)  >=__period) _aCloudPaintHighMild[__period]   = 0;
}

string _getPeriod(int __timeFrame)
{
   switch(__timeFrame)
   {
      case 1:
         return ("1m");
         break;
      case 5:
         return ("5m");
         break;
      case 15:
         return ("15m");
         break;
      case 30:
         return ("30m");
         break;
      case 60:
         return ("60m");
         break;
      case 240:
         return ("240m");
         break;
      case 1440:
         return ("1d");
         break;
      case 10080:
         return ("1w");
         break;
      case 43200:
         return ("1m");
         break;
      default:
         return ("0m");
         break;
   }
}

//---Cloud.mp4 end----

//+------------------------------------------------------------------+
int deinit() { return(0); }
//+------------------------------------------------------------------+