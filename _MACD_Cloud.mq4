//+------------------------------------------------------------------+
//|                                                         MACD.mq4 |
//|                                      Copyright © 2016, Harry Gui |
//|                                                                  |
//+------------------------------------------------------------------+
// This is the correct computation and display of MACD.
#property copyright "Copyright © "
#property link      ""
//#property strict

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Magenta
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 4
#property indicator_width4 4

//---- input parameters
extern int  FastMAPeriod=12;
extern int  SlowMAPeriod=26;
extern int  SignalMAPeriod=9;
extern bool DisplayHistogram  = true;
extern bool DisplayMALines    = false;
extern bool DisplayCurrentHistogram = false;
double senkou_spanA_1p;
double senkou_spanB_1p;
//---- buffers
double MACDLineBuffer[];
double SignalLineBuffer[];
double HistogramBuffer[];
double HistogramSignalBuffer[];

//---- variables
double alpha = 0;
double alpha_1 = 0;
bool AllowSignalPopup      = true;
bool AllowSignalToEmail    = true;
int ADX = 14;
int _signalCloudBreakCur = 0;
static datetime PREVTIME;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   //---- indicators
   SetIndexStyle(0,DisplayMALines?DRAW_LINE:DRAW_NONE,EMPTY, indicator_width1);
   SetIndexBuffer(0,MACDLineBuffer);
   SetIndexDrawBegin(0,SlowMAPeriod);
   SetIndexStyle(1,DisplayMALines?DRAW_LINE:DRAW_NONE,STYLE_DOT, indicator_width2);
   SetIndexBuffer(1,SignalLineBuffer);
   SetIndexDrawBegin(1,SlowMAPeriod+SignalMAPeriod);
   SetIndexStyle(2,DisplayHistogram?DRAW_HISTOGRAM:DRAW_NONE, EMPTY, indicator_width3);
   SetIndexBuffer(2,HistogramBuffer);
   SetIndexDrawBegin(2,SlowMAPeriod+SignalMAPeriod);
   
   SetIndexStyle(3,DisplayHistogram?DRAW_HISTOGRAM:DRAW_NONE, EMPTY, indicator_width4);
   SetIndexBuffer(3,HistogramSignalBuffer);
   SetIndexDrawBegin(3,SlowMAPeriod+SignalMAPeriod);
   //---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+FastMAPeriod+","+SlowMAPeriod+","+SignalMAPeriod+","+DisplayCurrentHistogram+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"Histogram");
   SetIndexLabel(3,"HistogramSignal");
   //----
	alpha = 2.0 / (SignalMAPeriod + 1.0);
	alpha_1 = 1.0 - alpha;
   //----
   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   if(PREVTIME == Time[0]) 
   {
      _draw(_getCountBars());
      return(0);
   }
   else
   {
      _draw(_getCountBars());
   }
   PREVTIME = Time[0];
   return(0);
}
int _getCountBars()
{
   /*int __countBars;
   if(MaxBarsForCalculation) __countBars = MaxBarsForCalculation;
   else __countBars = iBars(NULL, PERIOD_CURRENT) - 26;
   return __countBars;*/
   
   int limit;
   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if (counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if (counted_bars>0) counted_bars--;
   return limit = Bars - counted_bars;
}
void _draw(int limit)
{   
   int __indexCutoff;
   if(DisplayCurrentHistogram==true) __indexCutoff = 0;
   else __indexCutoff = 1;
   
   for(int i=limit; i>=__indexCutoff; i--)
   {
      MACDLineBuffer[i] = iMA(NULL,PERIOD_CURRENT,FastMAPeriod,0,MODE_EMA,PRICE_CLOSE,i) - iMA(NULL,PERIOD_CURRENT,SlowMAPeriod,0,MODE_EMA,PRICE_CLOSE,i);
      SignalLineBuffer[i] = alpha*MACDLineBuffer[i] + alpha_1*SignalLineBuffer[i+1];
      HistogramBuffer[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
      
      if(_signalCloudBreakCur == 0) _signalCloudBreakCur = _cloudDirectionByBar(i); //init
      if(_cloudDirectionByBar(i) == 1 && _signalCloudBreakCur == -1) _signalCloudBreakCur = 1; //bullish cloud break adjusts signal to positive
      if(_cloudDirectionByBar(i) == -1 && _signalCloudBreakCur == 1) _signalCloudBreakCur = -1;
      
      if(   (_cloudDirectionByBar(i) == 1 || _cloudDirectionByBar(i) == 0) &&              //price above cloud
            _signalCloudBreakCur == 1 &&
            HistogramBuffer[i+1] < HistogramBuffer[i] && 
            HistogramBuffer[i+2] > HistogramBuffer[i+1])
      {
         if(MACDLineBuffer[i+1] - SignalLineBuffer[i+1] < 0)
         {
            HistogramSignalBuffer[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
         }
         
         //if(i==0) _runAlert(i,Period(), AllowSignalPopup, 0);
      }
      if(   (_cloudDirectionByBar(i) == -1 || _cloudDirectionByBar(i) == 0) &&              //price below cloud
            _signalCloudBreakCur == -1 &&
            HistogramBuffer[i+1] > HistogramBuffer[i] &&
            HistogramBuffer[i+2] < HistogramBuffer[i+1])
      {
         if(MACDLineBuffer[i+1] - SignalLineBuffer[i+1] > 0)
         {
            HistogramSignalBuffer[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
         }
         //if(i==0) _runAlert(i,Period(), AllowSignalPopup, 1);
      }
   }
}
void _runAlert(int __bar, int __timeframe, bool __allowAlertPopup, int __alertType, double __validityThreshold = 0.25, string __strRisk = "")
{	
   if(__allowAlertPopup && _isAlertTimeRemainValid(iTime(NULL, __timeframe, 0), TimeCurrent(), __timeframe, __validityThreshold))
	{
	   string __strSubj  =  "Trade Alert";
      string __alertMsg =  ChartSymbol() + "[" + _getPeriod(__timeframe) + "][" +
                           _getAlertTypeMessenge(__alertType) + "][" +
                           _getADX() + "][" + __strRisk + "][" +
                           TimeToString(Time[__bar], TIME_DATE|TIME_MINUTES) + "]";
	   //if(AllowSignalToEmail) SendMail(__strSubj, __alertMsg);
	   //Alert(__alertMsg);
	}
}
bool _isAlertTimeRemainValid(datetime __timeSlotBegin, datetime __timeCurrent, int __timeframe, double __validityThreshold = 0.25)
{
   double __timeElapsed = double(__timeCurrent) - double(__timeSlotBegin);
   double __timeElapsedThreshold = __timeframe * 60 * __validityThreshold;
   //Print(" timeCurrent ", __timeCurrent," timeSlotBegin ", __timeSlotBegin," timeElapsed: ", __timeElapsed, " timeElapsedThreshold: ", __timeElapsedThreshold," validityThreshold ",__validityThreshold);
   if (__timeElapsed > __timeElapsedThreshold) return false;
   return true;
}

string _getAlertTypeMessenge(int __alertyType)
{
   switch(__alertyType)
   {
      case 0:     return "MACD Tick Up";     break;
      case 1:     return "MACD Tick Down";   break;
      default:    return "";                 break;
   }
}

int _cloudDirectionByBar(int __bar)
{
   senkou_spanA_1p   = _getIchimokuComponent(PERIOD_CURRENT, MODE_SENKOUSPANA, __bar + 1);
   senkou_spanB_1p   = _getIchimokuComponent(PERIOD_CURRENT, MODE_SENKOUSPANB, __bar + 1);
   
   if(   iClose(NULL,PERIOD_CURRENT,__bar) > senkou_spanA_1p &&
         iClose(NULL,PERIOD_CURRENT,__bar) > senkou_spanB_1p)   //price action above cloud
   {return 1;}
   else if(    iClose(NULL,PERIOD_CURRENT,__bar) < senkou_spanA_1p &&
               iClose(NULL,PERIOD_CURRENT,__bar) < senkou_spanB_1p)   //price action below cloud
   {return -1;}
   else return 0;//inside cloud
}

double _getIchimokuComponent(int __timeframe, int __mode_name, int __bar)
{
   return iIchimoku(NULL,__timeframe,9,26,52,__mode_name,__bar);
}
string _getPeriod(int __timeFrame)
{
   switch(__timeFrame)
   {
      case 1:     return ("1M");    break;
      case 5:     return ("5M");    break;
      case 15:    return ("15M");   break;
      case 30:    return ("30M");   break;
      case 60:    return ("1H");    break;
      case 240:   return ("4H");    break;
      case 1440:  return ("1D");    break;
      case 10080: return ("1W");    break;
      case 43200: return ("1MN");   break;
      default:    return ("0M");    break;
   }
}
string _getADX()
{
   double __adx = iADX(NULL,PERIOD_CURRENT,ADX,PRICE_CLOSE,MODE_MAIN,0);
   if(__adx >= 20) return "Trendy";
   else return "Non-Trendy";
}