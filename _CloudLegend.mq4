//+------------------------------------------------------------------+
//|                                                   CloudBoard.mq4 |
//|                                      Copyright © 2016, Harry Gui |
//|                                   http://www.AcornInvesting.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Harry Gui, AcornInvesting.com"
#property link      "http://www.AcornInvesting.com"
#property version   "1.0"
//#property strict //breaks array for some reason, need fixing!
#property indicator_chart_window

extern bool UseCustomPipSize = false; // UseCustomPipSize: if true, pip size will be based on DecimalPlaces input parameter.
extern int DecimalPlaces = 0; // DecimalPlaces: how many decimal places in a pip?
extern double AlertIfSpreadAbove = 0; // AlertIfSpreadAbove: if > 0 alert will sound when sprea above the value.

extern color font_color = clrBlack; 
string font = "Arial Black";
extern int corner = 1; // corner: 0 - for top-left corner, 1 - top-right, 2 - bottom-left, 3 - bottom-right
extern int ATR_Daily = 20;
extern int ATR_Cur = 14;
extern int ADX = 14;
extern uchar sBuy = 233;
extern uchar sSell = 234;
extern uchar sNeutral = 232;

int const font_size = 10;
int const font_size_group1 = 15;
int const arrow_size = 15;
int const arrow_size_group1 = 20;
color font_colour_warning = clrRed;
int n_digits = 1;
double divider = 1;
bool alert_done = false;
double _pointToPip = 1/Point/10; //pow(10,Digits)/10;
double senkou_spanA,senkou_spanB,tenkan_sen,kijun_sen;
double _valueATR,_valueRange;
int scaleX=0,scaleY=20,offsetX=0,offsetY=0;
long _current_chart_id=ChartID(); 
datetime LastHighAlert = D'1970.01.01';
string _arrayTexts[] = {   "txtSpread",
                           "txtATR_D",
                           "txtRange",
                           "txtATR_Cur",
                           "txtADX"/*,
                           "txtMACDHistWeekly",   "txtCloudKijunWeeklySignal",  "txtCloudTKWeeklySignal",  "txtCloudWeeklySignal", "txtCloudWeekly", 
                           "txtMACDHistDaily",   "txtCloudKijunDailySignal",   "txtCloudTKDailySignal",   "txtCloudDailySignal",  "txtCloudDaily",  
                           "txtMACDHist4H",   "txtCloudKijun4HSignal",      "txtCloudTK4HSignal",      "txtCloud4HSignal",     "txtCloud4H",     
                           "txtMACDHist1H",   "txtCloudKijun1HSignal",      "txtCloudTK1HSignal",      "txtCloud1HSignal",     "txtCloud1H",     
                           "txtMACDHist30M",   "txtCloudKijun30MSignal",     "txtCloudTK30MSignal",     "txtCloud30MSignal",    "txtCloud30M",    
                           "txtMACDHist15M",   "txtCloudKijun15MSignal",     "txtCloudTK15MSignal",     "txtCloud15MSignal",    "txtCloud15M",    
                           "txtMACDHist5M",   "txtCloudKijun5MSignal",      "txtCloudTK5MSignal",      "txtCloud5MSignal",     "txtCloud5M"  */   
						      };
//MACD start
/*
#property indicator_separate_window*/
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Blue
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
double HistogramBufferDaily[];
double HistogramBuffer4H[];
double HistogramBuffer1H[];

//---- variables
double alpha = 0;
double alpha_1 = 0;
bool AllowSignalPopup      = true;
bool AllowSignalToEmail    = true;
int _signalCloudBreakCur = 0;
static datetime PREVTIME;

//MACD finish
int init()
{
   //IndicatorBuffers(10);
   LastHighAlert = Time[0];
   int __row = 0, __index = 0;
   _createObject(_arrayTexts[__index], __row);__row++;__index++;//spread
   _createObject(_arrayTexts[__index], __row);__row++;__index++;//ATR daily
   _createObject(_arrayTexts[__index], __row);__row++;__index++;//Range intraday
   _createObject(_arrayTexts[__index], __row);__row++;__index++;//ATR current time frame
   _createObject(_arrayTexts[__index], __row);__row++;__index++;//ADX
   
   //W1
   _createObject(_arrayTexts[__index], __row, 2, 0);  __index++;
   _createObject(_arrayTexts[__index], __row, 2+10, 0);  __index++;
   _createObject(_arrayTexts[__index], __row, 18+10);    __index++;
   _createObject(_arrayTexts[__index], __row, 33+10);    __index++;
   _createObject(_arrayTexts[__index], __row, 48+10);    __row++;__index++;
   
   //D1
   _createObject(_arrayTexts[__index], __row, 0, 5);     __index++;
   _createObject(_arrayTexts[__index], __row, 0+10, 5);     __index++;
   _createObject(_arrayTexts[__index], __row, 15+10, 5);    __index++;
   _createObject(_arrayTexts[__index], __row, 30+10, 5);    __index++;
   _createObject(_arrayTexts[__index], __row, 45+10, 5);    __row++;__index++;
   
   //H4
   _createObject(_arrayTexts[__index], __row, 0, 5);     __index++;
   _createObject(_arrayTexts[__index], __row, 0+10, 5);     __index++;
   _createObject(_arrayTexts[__index], __row, 15+10, 5);    __index++;
   _createObject(_arrayTexts[__index], __row, 30+10, 5);    __index++;
   _createObject(_arrayTexts[__index], __row, 45+10, 7);    __row++;__index++;
   
   //H1
   _createObject(_arrayTexts[__index], __row, 0, 5);     __index++;
   _createObject(_arrayTexts[__index], __row, 0+10, 5);     __index++;
   _createObject(_arrayTexts[__index], __row, 15+10, 5);    __index++;
   _createObject(_arrayTexts[__index], __row, 30+10, 5);    __index++;
   _createObject(_arrayTexts[__index], __row, 45+10, 9);    __row++;__index++;

   _createObject(_arrayTexts[__index], __row, 2, 15);    __index++;
   _createObject(_arrayTexts[__index], __row, 2+10, 15);    __index++;
   _createObject(_arrayTexts[__index], __row, 18+10, 15);   __index++;
   _createObject(_arrayTexts[__index], __row, 33+10, 15);   __index++;
   _createObject(_arrayTexts[__index], __row, 48+10, 20);   __row++;__index++;

   _createObject(_arrayTexts[__index], __row, 2, 15);    __index++;
   _createObject(_arrayTexts[__index], __row, 2+10, 15);    __index++;
   _createObject(_arrayTexts[__index], __row, 18+10, 15);   __index++;
   _createObject(_arrayTexts[__index], __row, 33+10, 15);   __index++;
   _createObject(_arrayTexts[__index], __row, 48+10, 20);   __row++;__index++;

   _createObject(_arrayTexts[__index], __row, 2, 15);    __index++;
   _createObject(_arrayTexts[__index], __row, 2+10, 15);    __index++;
   _createObject(_arrayTexts[__index], __row, 18+10, 15);   __index++;
   _createObject(_arrayTexts[__index], __row, 33+10, 15);   __index++;
   _createObject(_arrayTexts[__index], __row, 48+10, 20);   __row++;__index++;
   
   /**/
   SetIndexBuffer(0,MACDLineBuffer);
   SetIndexBuffer(1,SignalLineBuffer);
   SetIndexBuffer(2,HistogramBuffer);
   SetIndexBuffer(3,HistogramSignalBuffer);
   
   
   if (UseCustomPipSize)
   {
      divider = MathPow(0.1, DecimalPlaces) / Point;
      n_digits = (int)MathAbs(MathLog10(divider));
   }
   
   double spread = MarketInfo(Symbol(), MODE_SPREAD);
   
   _outputSpread(spread);
   _outputATR_D();
   _outputRange();
   _outputATR_Cur();
   _outputADX();
   _outputCloud();
   
   //MACD START
   /**/
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
	
   //MACD FINISH
   return(0);
}
void _createObject(string __objectName, int __row, int __extraGapX=0, int __extraGapY=0)
{
   ObjectCreate(_current_chart_id,__objectName, OBJ_LABEL, 0, 0, 0);
   ObjectSet(__objectName, OBJPROP_CORNER, corner);
   ObjectSet(__objectName, OBJPROP_XDISTANCE, __row * scaleX + offsetX + __extraGapX);
   ObjectSet(__objectName, OBJPROP_YDISTANCE, __row * scaleY + offsetY + __extraGapY);
}
int start()
{
   RefreshRates();
   
   double spread = (Ask - Bid) / Point /10;
   _outputSpread(spread);
   
   if (AlertIfSpreadAbove > 0)
   {
      if (NormalizeSpread(spread) < AlertIfSpreadAbove) alert_done = false;
      else if (!alert_done)
      {
         PlaySound("alert.wav");
         alert_done = true;
      }
   }
   _outputATR_D();
   _outputRange();
   _outputATR_Cur();
   _outputADX();
   _outputCloud();
   
   //MACD START
   /*
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
   */
   //MACD FINISH
   return(0);
}
//MACD START
/**/
int _getCountBars()
{
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
   /*
   for(int i=500; i>=__indexCutoff; i--)
   {
      MACDLineBuffer[i] = iMA(NULL,PERIOD_CURRENT,FastMAPeriod,0,MODE_EMA,PRICE_CLOSE,i) - iMA(NULL,PERIOD_CURRENT,SlowMAPeriod,0,MODE_EMA,PRICE_CLOSE,i);
      SignalLineBuffer[i] = alpha*MACDLineBuffer[i] + alpha_1*SignalLineBuffer[i+1];
      HistogramBuffer[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
      if(Period() == PERIOD_D1) HistogramBufferDaily[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
      if(Period() == PERIOD_H4) HistogramBuffer4H[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
      if(Period() == PERIOD_H1) HistogramBuffer1H[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
      //Print(", HistogramBuffer[1]", HistogramBuffer[__indexCutoff], ", MACDLineBuffer[1]::", MACDLineBuffer[__indexCutoff],", SignalLineBuffer[1]::", SignalLineBuffer[__indexCutoff]          );
  
   }*/
}

//MACD FINISH
void _outputCloud()
{
   _drawSignal(PERIOD_W1,  "txtCloudWeekly", "W1: ",  "txtCloudWeeklySignal",  "txtCloudTKWeeklySignal", "txtCloudKijunWeeklySignal",  "txtMACDHistWeekly", font_size,        arrow_size);
   _drawSignal(PERIOD_D1,  "txtCloudDaily",  "D1: ",  "txtCloudDailySignal",   "txtCloudTKDailySignal",  "txtCloudKijunDailySignal",   "txtMACDHistDaily",  font_size_group1, arrow_size_group1);
   
   _drawSignal(PERIOD_H4,  "txtCloud4H",     "H4: ",  "txtCloud4HSignal",      "txtCloudTK4HSignal",     "txtCloudKijun4HSignal",      "txtMACDHist4H",     font_size_group1, arrow_size_group1);
   _drawSignal(PERIOD_H1,  "txtCloud1H",     "H1: ",  "txtCloud1HSignal",      "txtCloudTK1HSignal",     "txtCloudKijun1HSignal",      "txtMACDHist1H",     font_size_group1, arrow_size_group1);
   /*_drawSignal(PERIOD_M30, "txtCloud30M",    "M30: ", "txtCloud30MSignal",     "txtCloudTK30MSignal",    "txtCloudKijun30MSignal",     "txtMACDHist30M",    font_size,        arrow_size);
   _drawSignal(PERIOD_M15, "txtCloud15M",    "M15: ", "txtCloud15MSignal",     "txtCloudTK15MSignal",    "txtCloudKijun15MSignal",     "txtMACDHist15M",    font_size,        arrow_size);
   _drawSignal(PERIOD_M5,  "txtCloud5M",     "M5: ",  "txtCloud5MSignal",      "txtCloudTK5MSignal",     "txtCloudKijun5MSignal",      "txtMACDHist5M",     font_size,        arrow_size);
   */
}
void _outputSpread(double spread)
{
   ObjectSetText("txtSpread", "Spread:" + DoubleToString(NormalizeSpread(spread), n_digits) + " pips", font_size, font, font_color);
}
void _outputATR_D()
{
   _valueATR = iATR(NULL,PERIOD_D1,ATR_Daily,0);
   ObjectSetText("txtATR_D", "ATR("+IntegerToString(ATR_Daily)+"D):" + DoubleToString(_valueATR * _pointToPip,0) + " pips", font_size, font, font_color);
}
void _outputATR_Cur()
{
   _valueATR = iATR(NULL,PERIOD_CURRENT,ATR_Cur,0);
   ObjectSetText("txtATR_Cur", _getPeriod(Period())+"-ATR("+IntegerToString(ATR_Cur)+"):" + DoubleToString(_valueATR * _pointToPip,0) + " pips", font_size, font, font_color);
}
void _outputADX()
{
   double __adx = iADX(NULL,PERIOD_D1,ADX,PRICE_CLOSE,MODE_MAIN,0);
   if(__adx > 20) ObjectSetText("txtADX", "ADX("+IntegerToString(ADX)+"D): " + DoubleToString(__adx,0), font_size, font, font_color);
   else ObjectSetText("txtADX", "ADX("+IntegerToString(ADX)+"D): " + DoubleToString(__adx,0), font_size, font, font_colour_warning);
}
void _outputRange()
{
   _valueRange = MathAbs(iHigh(NULL,PERIOD_D1,0) - iLow(NULL,PERIOD_D1,0));
   if(_valueRange < _valueATR) ObjectSetText("txtRange", "DailyRange:" + DoubleToString(_valueRange*_pointToPip,0) + " pips", font_size, font, font_color);
   else ObjectSetText("txtRange", "DailyRange:" + DoubleToString(_valueRange*_pointToPip,0) + " pips", font_size, font, font_colour_warning);
}
void _drawSignal( int __timeFrame, string __objectTxtName, string __objectTxtText, string __objectTxtSignal, 
                  string __objectTxtSignal2, string __objectTxtSignal3, string __objectTxtSignal4, 
                  int __font_size, int __arrow_size, bool __allowAlert = false)
{
   int __period = 0;
   senkou_spanA = iIchimoku(NULL,__timeFrame,9,26,52,MODE_SENKOUSPANA,__period);
   senkou_spanB = iIchimoku(NULL,__timeFrame,9,26,52,MODE_SENKOUSPANB,__period);
   
   ObjectSetText(__objectTxtName, __objectTxtText, __font_size, font, font_color);
   
   //signal 1
   if(iOpen(NULL,__timeFrame,__period) > senkou_spanA && iOpen(NULL,__timeFrame,__period) > senkou_spanB)
   {
      ObjectSetText(__objectTxtSignal,CharToStr(sBuy),__arrow_size,"Wingdings",Lime);
   }
   else if(iOpen(NULL,__timeFrame,__period) < senkou_spanA && iOpen(NULL,__timeFrame,__period) < senkou_spanB)
   {
      ObjectSetText(__objectTxtSignal,CharToStr(sSell),__arrow_size,"Wingdings",Red);
   }
   else
   {
      ObjectSetText(__objectTxtSignal,CharToStr(sNeutral),__arrow_size,"Wingdings",Black); 
   }
   //signal 2
   tenkan_sen = iIchimoku(NULL,__timeFrame,9,26,52,MODE_TENKANSEN,__period);
   kijun_sen = iIchimoku(NULL,__timeFrame,9,26,52,MODE_KIJUNSEN,__period);
   
   if(iOpen(NULL,__timeFrame,__period) > tenkan_sen && iOpen(NULL,__timeFrame,__period) > kijun_sen && tenkan_sen > kijun_sen)
   {
      ObjectSetText(__objectTxtSignal2,CharToStr(sBuy),__arrow_size,"Wingdings",Lime);
   }
   else if(iOpen(NULL,__timeFrame,__period) < tenkan_sen && iOpen(NULL,__timeFrame,__period) < kijun_sen && tenkan_sen < kijun_sen)
   {
      ObjectSetText(__objectTxtSignal2,CharToStr(sSell),__arrow_size,"Wingdings",Red);
   }
   else
   {
      ObjectSetText(__objectTxtSignal2,CharToStr(sNeutral),__arrow_size,"Wingdings",Black); 
   }
   //signal 3
   if(iOpen(NULL,__timeFrame,__period) > kijun_sen)
   {
      ObjectSetText(__objectTxtSignal3,CharToStr(sBuy),__arrow_size,"Wingdings",Lime);
   }
   else if(iOpen(NULL,__timeFrame,__period) < kijun_sen)
   {
      ObjectSetText(__objectTxtSignal3,CharToStr(sSell),__arrow_size,"Wingdings",Red);
   }
   else
   {
      ObjectSetText(__objectTxtSignal3,CharToStr(sNeutral),__arrow_size,"Wingdings",Black); 
   }
   //signal 4
   //ObjectSetText(__objectTxtSignal4,CharToStr(sBuy),__arrow_size,"Wingdings",Lime);
   //_getMACDHistValue(__timeFrame, 0);
   /*
      if(_getMACDHistValue(__timeFrame, 1 > _getMACDHistValue(__timeFrame, 2))
      {
         ObjectSetText(__objectTxtSignal4,CharToStr(sBuy),__arrow_size,"Wingdings",Lime);
         if(__timeFrame == PERIOD_D1) HistogramBufferDaily[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
         if(__timeFrame == PERIOD_H4) HistogramBuffer4H[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
         if(__timeFrame == PERIOD_H1) HistogramBuffer1H[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
      }
      else
      {
         ObjectSetText(__objectTxtSignal4,CharToStr(sSell),__arrow_size,"Wingdings",Red);
      }
   */
}
/*
double _getMACDHistValue(string __timeFrame, int __index)
{
   double __MACDLineBuffer, __SignalLineBuffer, __HistogramBuffer;
   
   int i=__index;
   //for(int i=2; i>=0; i--)
   //{
      MACDLineBuffer[i] = iMA(NULL,__timeFrame,FastMAPeriod,0,MODE_EMA,PRICE_CLOSE,i) - iMA(NULL,__timeFrame,SlowMAPeriod,0,MODE_EMA,PRICE_CLOSE,i);
      __MACDLineBuffer = iMA(NULL,__timeFrame,FastMAPeriod,0,MODE_EMA,PRICE_CLOSE,i) - iMA(NULL,__timeFrame,SlowMAPeriod,0,MODE_EMA,PRICE_CLOSE,i);
      //SignalLineBuffer[i] = alpha*MACDLineBuffer[i] + alpha_1*SignalLineBuffer[i+1];
      __SignalLineBuffer = alpha*MACDLineBuffer[i] + alpha_1*SignalLineBuffer[i+1];
      SignalLineBuffer[i] = __SignalLineBuffer;
      
      HistogramBuffer[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
      __HistogramBuffer = __MACDLineBuffer - __SignalLineBuffer;
      
      //Print(__timeFrame,", HistogramBuffer[i]", HistogramBuffer[i], ",__HistogramBuffer:", __HistogramBuffer, ", MACDLineBuffer[i]::", MACDLineBuffer[i],", SignalLineBuffer[i]::", SignalLineBuffer[i]          );
      //Print(__timeFrame,", __HistogramBuffer:",__HistogramBuffer,"::", MACDLineBuffer[i],":::", __SignalLineBuffer);
   //}
   return __HistogramBuffer;
}*/

double NormalizeSpread(double spread)
{
   return(NormalizeDouble(spread / divider, n_digits));
}
int deinit()
{
   for(int __x=0;__x<ArraySize(_arrayTexts); __x++)
   {
      ObjectDelete(_arrayTexts[__x]);
   }
   
   //ObjectsDeleteAll(); 
   return(0);
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