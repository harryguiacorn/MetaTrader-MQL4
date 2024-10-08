//+------------------------------------------------------------------+
//|                                                        Cloud.mq4 |
//|                                      Copyright © 2016, Harry Gui |
//|                                   http://www.AcornInvesting.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Harry Gui, AcornInvesting.com"
#property link      "http://www.AcornInvesting.com"
#property version   "1.0"
#property strict
#property indicator_chart_window

#property indicator_buffers 8
#property indicator_width1 5
#property indicator_width2 5
#property indicator_color1 Lime 
#property indicator_color2 Tomato
#property indicator_color3 Lime
#property indicator_color4 Tomato
#property indicator_color5 clrDarkViolet
#property indicator_color6 clrDarkViolet
#property indicator_color7 clrGold
#property indicator_color8 clrGold

input bool Show_Alert               = true; // Allow Alert
input bool Show_SignalCandlePaint   = false; // Show TKx Arrow Signal
input bool Show_SignalDotPaint      = true; // Show TKx Dot Signal
input bool Show_PARSARPaint         = false; // Show PARSAR Signal

int MaxBarsForCalculation = NULL; //Max Bars For Calculation //= 1200; NULL
input int ADX = 14;

input bool AllowSignalCloudBreak          = true;
input bool AllowSignalConfirmedCloudBreak = false;
input bool AllowSignalCloudBounce         = false;
input bool AllowSignalTKCross             = true;
input bool AllowSignalPARSAR              = false;
input bool AllowSignalTKCrossWeak         = false;
input bool AllowSignalTKCrossMedium       = true;
input bool AllowAlertTKCrossMedium        = false;

bool AllowIndependentTKCrossSignal4h = false; // TODO: fix
bool AllowIndependentTKCrossSignal1d = false; // TODO: fix

bool AllowAlertTKRetracementTouch   = true;
bool AllowSignalToEmail             = true;

double   _aCloudArrowBullish[],_aCloudArrowBearish[],
         _aCloudPaintLow[],_aCloudPaintHigh[],
         _aCloudParsarBullish[],_aCloudParsarBearish[],
         _aCloudBreakBullish[],_aCloudBreakBearish[];

double tenkan_sen;
double kijun_sen;
double chikou_span_27p;
double chikou_span_28p;
double senkou_spanA;
double senkou_spanB;
double senkou_spanA_1p;
double senkou_spanB_1p;
double senkou_spanA_2p;
double senkou_spanB_2p;
double chikou_senkou_spanA_27p;
double chikou_senkou_spanB_27p;
double chikou_senkou_spanA_28p;
double chikou_senkou_spanB_28p;
double parsar;
int _signalCloudBreakPrev = 0;
int _decimalRiskATR = 1;
static datetime PREVTIME;// = 0;

//+------------------------------------------------------------------+
int init()
{
   SetIndexBuffer(0,_aCloudArrowBullish);
   SetIndexBuffer(1,_aCloudArrowBearish);
   SetIndexBuffer(2,_aCloudPaintLow);
   SetIndexBuffer(3,_aCloudPaintHigh);
   SetIndexBuffer(4,_aCloudParsarBullish);
   SetIndexBuffer(5,_aCloudParsarBearish);
   SetIndexBuffer(6,_aCloudBreakBullish);
   SetIndexBuffer(7,_aCloudBreakBearish);
   
   SetIndexLabel(0,"Bullish Signal");
   SetIndexLabel(1,"Bearish Signal");
   SetIndexLabel(2,"Low");
   SetIndexLabel(3,"High");
   SetIndexLabel(4,"Bullish Signal");
   SetIndexLabel(5,"Bearish Signal");
   SetIndexLabel(6,"Cloud Break Bullish Signal");
   SetIndexLabel(7,"Cloud Break Bearish Signal");
   
   int __sizeDotPaintSmall = 3;
   int __sizeDotPaintBig = 6;
   int __sizeDotPARSAR = 4;
   if(!Show_SignalDotPaint)
   {
      SetIndexStyle(0,DRAW_NONE,EMPTY,__sizeDotPaintBig);
      SetIndexStyle(1,DRAW_NONE,EMPTY,__sizeDotPaintBig);
      
      SetIndexStyle(6,DRAW_NONE,EMPTY,__sizeDotPaintSmall);
      SetIndexStyle(7,DRAW_NONE,EMPTY,__sizeDotPaintSmall);
   }
   else
   {
      SetIndexStyle(0,DRAW_ARROW,EMPTY,__sizeDotPaintBig);
      SetIndexStyle(1,DRAW_ARROW,EMPTY,__sizeDotPaintBig);
      
      SetIndexStyle(6,DRAW_ARROW,EMPTY,__sizeDotPaintSmall);
      SetIndexStyle(7,DRAW_ARROW,EMPTY,__sizeDotPaintSmall);
   }
   if(Show_SignalCandlePaint)
   {
      SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,indicator_width1);
      SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,indicator_width2);
   }
   else
   {
      SetIndexStyle(2,DRAW_NONE,EMPTY,indicator_width1);
      SetIndexStyle(3,DRAW_NONE,EMPTY,indicator_width2);
   }
   if(Show_PARSARPaint)
   {
      SetIndexStyle(4,DRAW_ARROW,EMPTY,__sizeDotPARSAR);
      SetIndexStyle(5,DRAW_ARROW,EMPTY,__sizeDotPARSAR);
   }
   else
   {
      SetIndexStyle(4,DRAW_NONE,EMPTY,__sizeDotPARSAR);
      SetIndexStyle(5,DRAW_NONE,EMPTY,__sizeDotPARSAR);
   }
   SetIndexArrow(0,108);//233
   SetIndexArrow(1,108);//234
   SetIndexArrow(4,108);//233
   SetIndexArrow(5,108);//234
   SetIndexArrow(6,108);//233
   SetIndexArrow(7,108);//234
   
   //_updateBarsMaxRange();
   
   return(0);
}
//+------------------------------------------------------------------+
int start()
{   
   if(PREVTIME == Time[0]) 
   {
      _drawSignalCurrentTimeFrame(0, ChartPeriod(), false); //update current bar
      _drawSignalCurrentTimeFrameForwards(0, ChartPeriod(), false); //update Cloud Break signal
      return(0);
   }
   else
   {
      _updateBarsMaxRange();
   }
   //run H4 and D1 signal
   if(AllowIndependentTKCrossSignal4h) _drawSignalIndependentTimeFrame(PERIOD_H4, Show_Alert);
   if(AllowIndependentTKCrossSignal1d) _drawSignalIndependentTimeFrame(PERIOD_D1, Show_Alert);
   
   PREVTIME = Time[0];
   return(0);
}
void _updateBarsMaxRange()
{
   for(int __bar=0; __bar<_getCountBars(); __bar++)//calculate backwards
   {
      _drawSignalCurrentTimeFrame(__bar, ChartPeriod(), Show_Alert);
   }
   for(int __bar=_getCountBars(); __bar>0; __bar--)//calculate forwards from the begining of hisorical bars for cloud break
   {
      _drawSignalCurrentTimeFrameForwards(__bar, ChartPeriod(), Show_Alert);
   }
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
double _getIchimokuComponent(int __timeframe, int __mode_name, int __bar)
{
   return iIchimoku(NULL,__timeframe,9,26,52,__mode_name,__bar);
}

void _drawSignalIndependentTimeFrame(int __timeFrame, bool __allowAlertPopup)
{
   //Print(ChartPeriod() ," vs ",  __timeFrame);
   for(int __bar=0; __bar<_getCountBars(); __bar++)//calculate backwards
   {
      if(ChartPeriod() != __timeFrame) _drawSignalCurrentTimeFrame(__bar, ChartPeriod(), __allowAlertPopup);
   }
   for(int __bar=_getCountBars(); __bar>0; __bar--)//calculate forwards from the begining of hisorical bars for cloud break
   {
      if(ChartPeriod() != __timeFrame) _drawSignalCurrentTimeFrameForwards(__bar, ChartPeriod(), __allowAlertPopup);
   }
}
void _drawSignalTKCross(int __bar, int __timeFrame, bool __allowAlertPopup)
{  
   bool __paintCandle = true;
   int __offsetBarCur = 1, __offsetBarPrev = 2;
   senkou_spanA_1p = _getIchimokuComponent(__timeFrame, MODE_SENKOUSPANA, __bar + __offsetBarCur);
   senkou_spanB_1p = _getIchimokuComponent(__timeFrame, MODE_SENKOUSPANB, __bar + __offsetBarCur);
   if(_getIchimokuComponent(__timeFrame, MODE_TENKANSEN, __bar + __offsetBarCur) > _getIchimokuComponent(__timeFrame, MODE_KIJUNSEN, __bar + __offsetBarCur) && //TK cross
      _getIchimokuComponent(__timeFrame, MODE_TENKANSEN, __bar + __offsetBarPrev) <= _getIchimokuComponent(__timeFrame, MODE_KIJUNSEN, __bar + __offsetBarPrev))//check prior lines
   {
      if(iClose(NULL,__timeFrame,__bar+__offsetBarCur) > MathMax(senkou_spanA_1p, senkou_spanB_1p))
      {
         if(AllowSignalTKCross) _signalLong(__bar, __timeFrame, __allowAlertPopup, 3, __paintCandle); //"Strong TK Bullish"
      }
      else if(iClose(NULL,__timeFrame,__bar+__offsetBarCur) < MathMin(senkou_spanA_1p, senkou_spanB_1p))
      {
         if(AllowSignalTKCross && AllowSignalTKCrossWeak) _signalLong(__bar, __timeFrame, __allowAlertPopup, 4, __paintCandle); //"Weak TK Bullish"
      }
      else
      {
         __allowAlertPopup = AllowAlertTKCrossMedium;//Allow Medium TK paint on chart but disable pop up alert
         if(AllowSignalTKCross  && AllowSignalTKCrossMedium) _signalLong(__bar, __timeFrame, __allowAlertPopup, 5, __paintCandle); //"Medium TK Bullish"
      }
   }
   if(_getIchimokuComponent(__timeFrame, MODE_TENKANSEN, __bar + __offsetBarCur) < _getIchimokuComponent(__timeFrame, MODE_KIJUNSEN, __bar + __offsetBarCur) && //TK cross
      _getIchimokuComponent(__timeFrame, MODE_TENKANSEN, __bar + __offsetBarPrev) >= _getIchimokuComponent(__timeFrame, MODE_KIJUNSEN, __bar + __offsetBarPrev))//check prior lines
   {
      if(iClose(NULL,__timeFrame,__bar+__offsetBarCur) > MathMax(senkou_spanA_1p, senkou_spanB_1p))
      {
         if(AllowSignalTKCross && AllowSignalTKCrossWeak) _signalShort(__bar, __timeFrame, __allowAlertPopup, 6, __paintCandle); //"Weak TK Bearish"
      }
      else if(iClose(NULL,__timeFrame,__bar+__offsetBarCur) < MathMin(senkou_spanA_1p, senkou_spanB_1p))
      {
         if(AllowSignalTKCross) _signalShort(__bar, __timeFrame, __allowAlertPopup, 7, __paintCandle); //"Strong TK Bearish"
      }
      else
      {
         __allowAlertPopup = AllowAlertTKCrossMedium;//Allow Medium TK paint on chart but disable pop up alert
         if(AllowSignalTKCross  && AllowSignalTKCrossMedium) _signalShort(__bar, __timeFrame, __allowAlertPopup, 8, __paintCandle); //"Medium TK Bearish"
      }
   } 
}
void _drawSignalCurrentTimeFrameForwards(int __bar, int __timeFrame, bool __allowAlertPopup)
{
   int __offsetPos = 1;
   senkou_spanA_1p            = _getIchimokuComponent(PERIOD_CURRENT, MODE_SENKOUSPANA, __bar + __offsetPos);
   senkou_spanB_1p            = _getIchimokuComponent(PERIOD_CURRENT, MODE_SENKOUSPANB, __bar + __offsetPos);
   
   //if(__bar ==0) Alert(__bar+1, " senkou_spanA ",senkou_spanA, " senkou_spanB ", senkou_spanB," * ",__bar+2," senkou_spanA_2p ",senkou_spanA_2p, " senkou_spanB_2p ", senkou_spanB_2p);
            
   //---------------------------------- Cloud Break Begin----------------------------
   if(iClose(NULL,PERIOD_CURRENT,__bar+__offsetPos)> MathMax(senkou_spanA_1p,senkou_spanB_1p)) //price action above cloud
   {
      if(AllowSignalCloudBreak)
      {
         if(_signalCloudBreakPrev == -1 || _signalCloudBreakPrev == 0) 
         {
            _aCloudBreakBullish[__bar]=0.0;//init array
            _signalCloudBreakLong(__bar, __timeFrame, __allowAlertPopup, 11); //"Cloud Break"
            _signalCloudBreakPrev = 1;
         }
      }
   }
   if(iClose(NULL,PERIOD_CURRENT,__bar+__offsetPos) < MathMin(senkou_spanA_1p,senkou_spanB_1p)) //price action below cloud
   {
      if(AllowSignalCloudBreak)
      {
         if(_signalCloudBreakPrev == 1 || _signalCloudBreakPrev == 0) 
         { 
            _aCloudBreakBearish[__bar]=0.0;//init array
            _signalCloudBreakShort(__bar, __timeFrame, __allowAlertPopup, 12); //"Cloud Break"
            _signalCloudBreakPrev = -1;
         }
      }
   }
   //------------------------------------ Cloud Break End------------------------------
}
void _drawSignalCurrentTimeFrame(int __bar, int __timeFrame, bool __allowAlertPopup)
{
   tenkan_sen                 = _getIchimokuComponent(PERIOD_CURRENT, MODE_TENKANSEN,  __bar + 1);
   kijun_sen                  = _getIchimokuComponent(PERIOD_CURRENT, MODE_KIJUNSEN,   __bar + 1);
   senkou_spanA               = _getIchimokuComponent(PERIOD_CURRENT, MODE_SENKOUSPANA, __bar);
   senkou_spanB               = _getIchimokuComponent(PERIOD_CURRENT, MODE_SENKOUSPANB, __bar);
   senkou_spanA_1p            = _getIchimokuComponent(PERIOD_CURRENT, MODE_SENKOUSPANA, __bar + 1);
   senkou_spanB_1p            = _getIchimokuComponent(PERIOD_CURRENT, MODE_SENKOUSPANB, __bar + 1);
   senkou_spanA_2p            = _getIchimokuComponent(PERIOD_CURRENT, MODE_SENKOUSPANA, __bar + 2);
   senkou_spanB_2p            = _getIchimokuComponent(PERIOD_CURRENT, MODE_SENKOUSPANB, __bar + 2);
   
   chikou_span_27p            = iIchimoku(NULL,PERIOD_CURRENT,9,26,52,MODE_CHINKOUSPAN,__bar+27);
   chikou_span_28p            = iIchimoku(NULL,PERIOD_CURRENT,9,26,52,MODE_CHINKOUSPAN,__bar+28);
   
   chikou_senkou_spanA_27p    = iIchimoku(NULL,PERIOD_CURRENT,9,26,52,MODE_SENKOUSPANA,__bar+27);
   chikou_senkou_spanB_27p    = iIchimoku(NULL,PERIOD_CURRENT,9,26,52,MODE_SENKOUSPANB,__bar+27);
   chikou_senkou_spanA_28p    = iIchimoku(NULL,PERIOD_CURRENT,9,26,52,MODE_SENKOUSPANA,__bar+28);
   chikou_senkou_spanB_28p    = iIchimoku(NULL,PERIOD_CURRENT,9,26,52,MODE_SENKOUSPANB,__bar+28);
   
   double parsarCur           = iSAR(NULL, __timeFrame, 0.02, 0.2, __bar);
   double parsarPrev          = iSAR(NULL, __timeFrame, 0.02, 0.2, __bar + 1);
   
   _aCloudArrowBullish[__bar]=0.0; _aCloudArrowBearish[__bar]=0.0;//init array
   _aCloudParsarBullish[__bar]=0.0; _aCloudParsarBearish[__bar]=0.0;//init array
   
   if(AllowSignalTKCross) _drawSignalTKCross(__bar, __timeFrame, __allowAlertPopup);
   //------------------------------------------- PARSAR ------------------------------
   if(   AllowSignalPARSAR &&
         iClose(NULL,PERIOD_CURRENT,__bar) > senkou_spanA_1p &&
         iClose(NULL,PERIOD_CURRENT,__bar) > senkou_spanB_1p)   //price action above cloud
   { 
      if(parsarPrev > iClose(NULL,PERIOD_CURRENT,__bar+2) && parsarCur < iClose(NULL,PERIOD_CURRENT,__bar+1))
      {
         _signalPARSARLong(__bar, __timeFrame, __allowAlertPopup, 9); //"PARSAR Buy"
      }
   }
   if(   AllowSignalPARSAR &&
         iClose(NULL,PERIOD_CURRENT,__bar) < senkou_spanA_1p &&
         iClose(NULL,PERIOD_CURRENT,__bar) < senkou_spanB_1p)
   { 
      if(parsarPrev < iClose(NULL,PERIOD_CURRENT,__bar+2) && parsarCur > iClose(NULL,PERIOD_CURRENT,__bar+1))
      {
         _signalPARSARShort(__bar, __timeFrame, __allowAlertPopup, 10); //"PARSAR Sell"
      }
   }
   //------------------------------------------- PARSAR ------------------------------
   
   if(iClose(NULL,PERIOD_CURRENT,__bar+1)> MathMax(senkou_spanA_1p,senkou_spanB_1p))   //price action above cloud
   {
      if(chikou_span_27p > chikou_senkou_spanA_27p &&
         chikou_span_27p > chikou_senkou_spanB_27p)
      {
         if(chikou_span_28p < chikou_senkou_spanA_28p ||
            chikou_span_28p < chikou_senkou_spanB_28p)
         {
            if(AllowSignalConfirmedCloudBreak) _signalLong(__bar, __timeFrame, __allowAlertPopup, 1); //"Cloud Break with Chikou Span"
         }
         
         if(iClose(NULL,PERIOD_CURRENT,__bar+2) < senkou_spanA_2p ||
            iClose(NULL,PERIOD_CURRENT,__bar+2) < senkou_spanB_2p)
         {
            if(AllowSignalCloudBounce) _signalLong(__bar, __timeFrame, __allowAlertPopup, 2); //"Cloud Bounce"
         }
      }
   }
   if(iClose(NULL,PERIOD_CURRENT,__bar+1) < MathMin(senkou_spanA_1p,senkou_spanB_1p)) //price action below cloud
   {
      if(
         chikou_span_27p < chikou_senkou_spanA_27p &&
         chikou_span_27p < chikou_senkou_spanB_27p
         )
      {
         if(
            chikou_span_28p > chikou_senkou_spanA_28p ||
            chikou_span_28p > chikou_senkou_spanB_28p)
         {
            if(AllowSignalConfirmedCloudBreak) _signalShort(__bar, __timeFrame, __allowAlertPopup, 1); //"Cloud Break with Chikou Span"
         }
         if(
            iClose(NULL,PERIOD_CURRENT,__bar+2) > senkou_spanA_2p ||
            iClose(NULL,PERIOD_CURRENT,__bar+2) > senkou_spanB_2p)
         {
            if(AllowSignalCloudBounce) _signalShort(__bar, __timeFrame, __allowAlertPopup, 2); //"Cloud Bounce"
         }
      }
   }
}

string _getAlertTypeMessenge(int __alertyType)
{
   switch(__alertyType)
   {
      case 0:     return "Cloud Break";                  break;
      case 1:     return "Cloud Break with Chikou Span"; break;
      case 2:     return "Cloud Bounce";                 break;
      case 3:     return "Strong TK Bullish";            break;
      case 4:     return "Weak TK Bullish";              break;
      case 5:     return "Medium TK Bullish";            break;
      case 6:     return "Weak TK Bearish";              break;
      case 7:     return "Strong TK Bearish";            break;
      case 8:     return "Medium TK Bearish";            break;
      case 9:     return "PARSAR Bullish";               break;
      case 10:    return "PARSAR Bearish";               break;
      case 11:    return "Cloud Break Bullish";          break;
      case 12:    return "Cloud Break Bearish";          break;
      default:    return "Cloud Break";                  break;
   }
}
void _signalPARSARLong(int __bar, int __timeframe, bool __allowAlertPopup, int __alertType, bool __paintCandle = true)
{
   if(__paintCandle) _aCloudParsarBullish[__bar] = iSAR(NULL, __timeframe, 0.02, 0.2, __bar);
	double __riskPips = Close[__bar] - _aCloudParsarBullish[__bar];
	string __strRiskATR  = DoubleToStr(__riskPips / _getATR(PERIOD_CURRENT), _decimalRiskATR) + " ATR";
	_runAlertBullish(__bar, __timeframe, __allowAlertPopup, __alertType, 1, __strRiskATR);//validityThreshold remains throughout current candle
}
void _signalPARSARShort(int __bar, int __timeframe, bool __allowAlertPopup, int __alertType, bool __paintCandle = true)
{
   if(__paintCandle) _aCloudParsarBearish[__bar] = iSAR(NULL, __timeframe, 0.02, 0.2, __bar);
	double __riskPips = _aCloudParsarBearish[__bar] - Close[__bar];
	string __strRiskATR  = DoubleToStr(__riskPips / _getATR(PERIOD_CURRENT), _decimalRiskATR) + " ATR";
	_runAlertBearish(__bar, __timeframe, __allowAlertPopup, __alertType, 1, __strRiskATR);
}
void _signalCloudBreakLong(int __bar, int __timeframe, bool __allowAlertPopup, int __alertType, bool __paintCandle = true)
{
   int __offsetPos = 1;
   if(__paintCandle) _aCloudBreakBullish[__bar] = Open[__bar]; 
	if(ChartPeriod() != __timeframe) return; //prevents activation of 4h or/and daily independent signals
   _runAlertCloudBreakBullish(__bar + __offsetPos, __timeframe, __allowAlertPopup, __alertType, 1);//validityThreshold for alert during first 0.25 of candle timeframe.
   _runAlertBullish(__bar, __timeframe, __allowAlertPopup, __alertType, 1);//validityThreshold for alert during first 0.25 of candle timeframe.
}
void _signalCloudBreakShort(int __bar, int __timeframe, bool __allowAlertPopup, int __alertType, bool __paintCandle = true)
{  
   int __offsetPos = 1;
   if(__paintCandle) _aCloudBreakBearish[__bar] = Open[__bar];
	if(ChartPeriod() != __timeframe) return; //prevents activation of 4h or/and daily independent signals
   _runAlertCloudBreakBearish(__bar + __offsetPos, __timeframe, __allowAlertPopup, __alertType, 1);
   _runAlertBearish(__bar, __timeframe, __allowAlertPopup, __alertType, 1);
}

void _signalLong(int __bar, int __timeframe, bool __allowAlertPopup, int __alertType, bool __paintCandle = true)
{
   if(__paintCandle)
   {
      _aCloudArrowBullish[__bar] = Open[__bar]; //Low[__bar]
   	_aCloudPaintLow[__bar] = High[__bar];
   	_aCloudPaintHigh[__bar] = Low[__bar];
	}
	if(ChartPeriod() != __timeframe) return; //prevents activation of 4h or/and daily independent signals
   _runAlertBullish(__bar, __timeframe, __allowAlertPopup, __alertType, .25);//validityThreshold for alert during first 0.25 of candle timeframe.
}

void _signalShort(int __bar, int __timeframe, bool __allowAlertPopup, int __alertType, bool __paintCandle = true)
{  
   if(__paintCandle)
   {
      _aCloudArrowBearish[__bar] = Open[__bar]; //High[__bar]
      _aCloudPaintLow[__bar] = Low[__bar];
   	_aCloudPaintHigh[__bar] = High[__bar];
	}
	if(ChartPeriod() != __timeframe) return; //prevents activation of 4h or/and daily independent signals
   //Print(__timeframe,"-------------", ChartPeriod(), "--------", iTime(NULL, __timeframe,0),"-------------", Time[0]);
   _runAlertBearish(__bar, __timeframe, __allowAlertPopup, __alertType);
}
void _runAlertCloudBreakBullish(int __bar, int __timeframe, bool __allowAlertPopup, int __alertType, double __validityThreshold = 0.25, string __strRisk = "")
{
   if(__allowAlertPopup && _isAlertTimeRemainValid(Time[__bar], TimeCurrent(), __timeframe, __validityThreshold))
	{
	   string __strSubj  =  "Trade Alert";
      string __alertMsg =  ChartSymbol() + "[" + _getPeriod(__timeframe) + "][" +
                           _getAlertTypeMessenge(__alertType) + "][" +
                           _getADX() + "][" + __strRisk + "][" +
                           TimeToString(Time[__bar], TIME_DATE|TIME_MINUTES) + "]";
	   if(AllowSignalToEmail) SendMail(__strSubj, __alertMsg);
	   Alert(__alertMsg);
	}
}

void _runAlertCloudBreakBearish(int __bar, int __timeframe, bool __allowAlertPopup, int __alertType, double __validityThreshold = 0.25, string __strRisk = "")
{	
   if(__allowAlertPopup && _isAlertTimeRemainValid(Time[__bar], TimeCurrent(), __timeframe, __validityThreshold))
	{
	   string __strSubj  =  "Trade Alert";
      string __alertMsg =  ChartSymbol() + "[" + _getPeriod(__timeframe) + "][" +
                           _getAlertTypeMessenge(__alertType) + "][" +
                           _getADX() + "][" + __strRisk + "][" +
                           TimeToString(Time[__bar], TIME_DATE|TIME_MINUTES) + "]";
	   if(AllowSignalToEmail) SendMail(__strSubj, __alertMsg);
	   Alert(__alertMsg);
	}
}
void _runAlertBullish(int __bar, int __timeframe, bool __allowAlertPopup, int __alertType, double __validityThreshold = 0.25, string __strRisk = "")
{
   if(__allowAlertPopup /*&& __bar == 0*/ && _isAlertTimeRemainValid(Time[__bar], TimeCurrent(), __timeframe, __validityThreshold))
	{
	   string __strSubj  =  "Trade Alert";
      string __alertMsg =  ChartSymbol() + "[" + _getPeriod(__timeframe) + "][" +
                           _getAlertTypeMessenge(__alertType) + "][" +
                           _getADX() + "][" + __strRisk + "][" +
                           TimeToString(Time[__bar], TIME_DATE|TIME_MINUTES) + "]";
	   if(AllowSignalToEmail) SendMail(__strSubj, __alertMsg);
	   Alert(__alertMsg);
	}
}

void _runAlertBearish(int __bar, int __timeframe, bool __allowAlertPopup, int __alertType, double __validityThreshold = 0.25, string __strRisk = "")
{	
   if(__allowAlertPopup /*&& __bar == 0*/ && _isAlertTimeRemainValid(Time[__bar], TimeCurrent(), __timeframe, __validityThreshold))
	{
	   string __strSubj  =  "Trade Alert";
      string __alertMsg =  ChartSymbol() + "[" + _getPeriod(__timeframe) + "][" +
                           _getAlertTypeMessenge(__alertType) + "][" +
                           _getADX() + "][" + __strRisk + "][" +
                           TimeToString(Time[__bar], TIME_DATE|TIME_MINUTES) + "]";
	   if(AllowSignalToEmail) SendMail(__strSubj, __alertMsg);
	   Alert(__alertMsg);
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
double _getATR(int __period){   return iATR(NULL,__period,20,0);}

string _getADX()
{
   double __adx = iADX(NULL,PERIOD_CURRENT,ADX,PRICE_CLOSE,MODE_MAIN,0);
   if(__adx >= 20) return "Trendy";
   else return "Non-Trendy";
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
int deinit() 
{
   //ObjectDelete(ChartID(),

   //ObjectsDeleteAll();             
   return(0); 
}
