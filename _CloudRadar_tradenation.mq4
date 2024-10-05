//+------------------------------------------------------------------+
//|                                                 CloudRadar.mq4 |
//|                                        Copyright 2016. Harry Gui |
//|                                    http://www.AcornInvesting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016. Harry Gui"
#property link      "http://www.AcornInvesting.com"
#property version   "1.00"
#property strict
#property script_show_inputs
#property indicator_separate_window
extern uchar sBuy = 233;
extern uchar sSell = 234;
extern uchar sNeutral = 232;
extern color font_color = clrWhite; 
extern int ADX = 14;
input bool displayIntraDaySignal = true; // Display IntraDay Signal 

color font_colour_warning = clrRed;
color signal_colour_bearish = clrRed;
color signal_colour_bullish = clrLime;
color signal_colour_neutral = clrWhite;
color colourFont = clrWhite; 

string _font = "Arial Black";

int _arrowSize = 15;
int font_size = 10;
int corner = 0; // corner: 0 - for top-left corner, 1 - top-right, 2 - bottom-left, 3 - bottom-right
int offsetX=10,offsetY=20;
double senkou_spanA,senkou_spanB;
string _arrayCurrencyGroup1[] = {".US500.", ".USTEC.", ".US30.", ".DE40.", ".UK100."};
string _arrayCurrencyGroup2[] = {"EURUSD..", "GBPUSD..", "AUDUSD..", "USDCAD..", "NZDUSD.."};
string _arrayCurrencyGroup3[] = {"USDJPY..", "GBPJPY..", "EURJPY..", "AUDJPY..", "CADJPY.."};
string _arrayCurrencyGroup4[] = {"BrentFut.", "WTIFut."};
string _arrayCurrencyGroup5[] = {"GBPCAD..", "GBPAUD..", "GBPNZD.."};
string _arrayCurrencyGroup6[] = {"EURCAD..", "EURAUD..", "EURNZD..", "EURGBP.."}; //{"USB30YUSD", "USB10YUSD", "WTICOUSD", "DE10YBEUR", "XAUUSD", "XAGUSD"};
string _arrayCurrencyGroup7[] = {"AUDCAD..", "AUDNZD..", "NZDJPY..", "NZDCAD.."}; // {"CORNUSD", "WHEATUSD", "SUGARUSD", "SOYBNUSD", "NATGASUSD", "XCUUSD"};

string _arrayTimeFrameText[] = {"W1", "D1", "H4", "H1", "M30", "M15", "M5", "M1"};                           
int _arrayTimeFrameEnum[] = {PERIOD_W1, PERIOD_D1, PERIOD_H4, PERIOD_H1, PERIOD_M30, PERIOD_M15, PERIOD_M5, PERIOD_M1}; 
string _arrayTimeFrameTextW1D1H4H1[] = {"W1", "D1", "H4", "H1"};                           
int _arrayTimeFrameEnumW1D1H4H1[] = {PERIOD_W1, PERIOD_D1, PERIOD_H4, PERIOD_H1};  
  
int _arrayTimeFrameFilterEnum[] = {PERIOD_W1, PERIOD_D1, PERIOD_H4, PERIOD_H1, PERIOD_M30, PERIOD_M15, PERIOD_M5};  
bool hasRunOnce = false, debugMode = false;//DEBUG ONLY.                       
                           
int init()
{
   IndicatorShortName("CloudRadar");
   _drawGroup();
   return(0);
}
int _drawGroup()
{
   if(hasRunOnce && debugMode) return(0);
   else
   { 
      hasRunOnce = true;
      int __groupWidth = 460, __groupHeight = 150; // 275, 150;
      _createGroup(_arrayCurrencyGroup1,offsetX,                     offsetY,"Group1", 75);
      _createGroup(_arrayCurrencyGroup2,offsetX + __groupWidth,      offsetY,"Group2", 70);
      _createGroup(_arrayCurrencyGroup3,offsetX + __groupWidth * 2,  offsetY,"Group3", 70);
      
      _createGroup(_arrayCurrencyGroup4,offsetX,                     offsetY + __groupHeight,"Group4", 90);
      _createGroup(_arrayCurrencyGroup5,offsetX + __groupWidth,      offsetY + __groupHeight,"Group5", 90);
      _createGroup(_arrayCurrencyGroup6,offsetX + __groupWidth * 2,  offsetY + __groupHeight,"Group6", 90);
      
      _createGroup(_arrayCurrencyGroup7,offsetX ,                    offsetY + __groupHeight * 2,"Group7", 90);
   }
   return(0);
}
int start()
{
   _drawGroup();
   return(0);
}
void _createGroup(string& __arrayCurrencyGroup[], int __groupX = 20, int __groupY = 20, string __groupName = "", int __offsetX = 65)
{
   _createHeader(__arrayCurrencyGroup,__groupX,__groupY, __groupName, __offsetX);
   _createVerticalPair(__arrayCurrencyGroup,__groupX,__groupY);
}
void _createHeader(string& __arrayCurrencyGroup[], int __groupX, int __groupY, string __groupName, int __offsetX = 65)
{
   int __gapX = 30, __offsetTimeFrameY = 0, __offsetSignalX = 0, __offsetSignalY = 15, __scaleX = 50, __scaleY=20, __offsetScoreX = 20;
   
   string __objectName, __objectNameADX;
   string __arrayTimeFrameTextCopy[];
   int __arrayTimeFrameEnumCopy[];
   
   if(!displayIntraDaySignal) ArrayCopy(__arrayTimeFrameTextCopy,_arrayTimeFrameTextW1D1H4H1);
   else ArrayCopy(__arrayTimeFrameTextCopy,_arrayTimeFrameText);
   
   if(!displayIntraDaySignal) ArrayCopy(__arrayTimeFrameEnumCopy,_arrayTimeFrameEnumW1D1H4H1);
   else ArrayCopy(__arrayTimeFrameEnumCopy,_arrayTimeFrameEnum);

   //create timeframe header
   for (int __x=0;__x<ArraySize(__arrayTimeFrameTextCopy);__x++)
   {
      __objectName = "TimeFrame_" + __arrayTimeFrameTextCopy[__x] + "_" +__groupName;
      _createObject(__objectName,__groupX + __offsetX + __gapX * __x,__groupY + __offsetTimeFrameY);
      ObjectSetText(__objectName,__arrayTimeFrameTextCopy[__x], font_size, _font, colourFont);

   }
   //create score header "Synergy"
   __objectName = "Synergy_" +__groupName;
   _createObject(__objectName,__groupX + __offsetX + __gapX * ArraySize(__arrayTimeFrameTextCopy),__groupY + __offsetTimeFrameY);
   ObjectSetText(__objectName,"Synergy", font_size, _font, colourFont);
   
   //create score header "ADX"
   __objectNameADX = "ADX_" +__groupName;
   _createObject(__objectNameADX,__groupX + __offsetX + __gapX * ArraySize(__arrayTimeFrameTextCopy) + 70,__groupY + __offsetTimeFrameY);
   ObjectSetText(__objectNameADX,"ADX(D)", font_size, _font, colourFont);
   
   //create matrix
   for (int __y=0;__y<ArraySize(__arrayCurrencyGroup);__y++)
   {
      int __score = 0;
      for (int __x=0;__x<ArraySize(__arrayTimeFrameTextCopy);__x++)
      {
         int __tempScore = 0;
         
         __objectName = "Signal_" + __arrayCurrencyGroup[__y] + "_" + __arrayTimeFrameTextCopy[__x];
         _createObject(__objectName, __groupX + __offsetX + __gapX * __x + __offsetSignalX, __groupY + __offsetSignalY + __scaleY * __y);
         __tempScore += _drawSignal(__arrayCurrencyGroup[__y], __arrayTimeFrameEnumCopy[__x],"", "",__objectName);
         
         if(_existInArray(__arrayTimeFrameEnumCopy[__x],_arrayTimeFrameFilterEnum) == 1) __score += __tempScore;
         
         if(debugMode) Print("Search " + IntegerToString(__arrayTimeFrameEnumCopy[__x]) + " exist " + IntegerToString(_existInArray(__arrayTimeFrameEnumCopy[__x],_arrayTimeFrameFilterEnum)));
         
         if(__x == ArraySize(__arrayTimeFrameTextCopy)-1)
         {
            //create score
            __objectName = "Score_" + __arrayCurrencyGroup[__y];
            _createObject(__objectName,__groupX + __offsetX + __gapX * ArraySize(__arrayTimeFrameTextCopy)+__offsetScoreX, __groupY + __offsetSignalY + __scaleY * __y);
            ObjectSetText(__objectName,IntegerToString(__score), font_size, _font, _getSignalColour(__score));
            if(debugMode) Print(__objectName + "::" + IntegerToString(__tempScore));
            
            //create ADX for each row
            double __adx = iADX(__arrayCurrencyGroup[__y],PERIOD_D1,ADX,PRICE_CLOSE,MODE_MAIN,0);
            __objectName = "ADX_" + __arrayCurrencyGroup[__y];
            _createObject(__objectName,__groupX + __offsetX + __gapX * ArraySize(__arrayTimeFrameTextCopy)+__offsetScoreX + 50, __groupY + __offsetSignalY + __scaleY * __y);
            if(__adx > 20) ObjectSetText(__objectName, DoubleToString(__adx,0), font_size, _font, font_color);
            else ObjectSetText(__objectName, DoubleToString(__adx,0), font_size, _font, font_colour_warning);
            
         }
      }
   }
}
color _getSignalColour(int __score)
{
   if(__score > 0) return signal_colour_bullish;
   else if(__score < 0) return signal_colour_bearish;
   else return signal_colour_neutral;
}
void _createVerticalPair(string& __arrayCurrencyGroup[], int __groupX, int __groupY)
{
   int __offsetX = 0, __offsetY = 15, __scaleY=20;
   for (int __x=0;__x<ArraySize(__arrayCurrencyGroup);__x++)
   {
      //Print("Symbol=",MarketInfo(__arrayCurrencyGroup[__x],MODE_BID));
      string __objectName = "Currency_" + __arrayCurrencyGroup[__x];
      ObjectCreate(__objectName, OBJ_LABEL, WindowFind("CloudRadar"), 0, 0);
      ObjectSetText(__objectName,__arrayCurrencyGroup[__x], font_size, _font, colourFont);
      ObjectSet(__objectName, OBJPROP_CORNER, corner);
      ObjectSet(__objectName, OBJPROP_XDISTANCE, __groupX + __offsetX);
      ObjectSet(__objectName, OBJPROP_YDISTANCE, __groupY + __offsetY + __scaleY * __x);
   }
}
int _existInArray(int __elementToSearch, int& __arrayToBeSearched[])
{
   for(int __i=0;__i<ArraySize(__arrayToBeSearched);__i++)
   {
      if(__elementToSearch == __arrayToBeSearched[__i]) return 1;
   }
   return -1;
}
void _createObject(string __objectName, int __x, int __y)
{
   ObjectCreate(__objectName, OBJ_LABEL, WindowFind("CloudRadar"), 0, 0);
   ObjectSet(__objectName, OBJPROP_CORNER, corner);
   ObjectSet(__objectName, OBJPROP_XDISTANCE, __x);
   ObjectSet(__objectName, OBJPROP_YDISTANCE, __y);
}
int _drawSignal(string __currency,int __timeFrame, string __objectTxtName, string __objectTxtText, string __objectTxtSignal)
{
   int __period = 0, __signal = 0;
   senkou_spanA =iIchimoku(__currency,__timeFrame,9,26,52,MODE_SENKOUSPANA,__period+1);
   senkou_spanB =iIchimoku(__currency,__timeFrame,9,26,52,MODE_SENKOUSPANB,__period+1);
   
   ObjectSetText(__objectTxtName, __objectTxtText, font_size, _font, font_color);
   
   if(iClose(__currency,__timeFrame,__period+1) > senkou_spanA && iClose(__currency,__timeFrame,__period+1) > senkou_spanB)
   {
      ObjectSetText(__objectTxtSignal,CharToStr(sBuy),_arrowSize,"Wingdings",signal_colour_bullish);
      __signal = 1;
   }
   else if(iClose(__currency,__timeFrame,__period+1) < senkou_spanA && iClose(__currency,__timeFrame,__period+1) < senkou_spanB)
   {
      ObjectSetText(__objectTxtSignal,CharToStr(sSell),_arrowSize,"Wingdings",signal_colour_bearish);
      __signal = -1;
   }
   else
   {
      ObjectSetText(__objectTxtSignal,CharToStr(sNeutral),_arrowSize,"Wingdings",signal_colour_neutral); 
      __signal = 0;
   }
   return __signal;
}
int deinit()
{
   for(int __x=0;__x<ArraySize(_arrayTimeFrameText); __x++) ObjectDelete(_arrayTimeFrameText[__x]);
   _removeGroup(_arrayCurrencyGroup1,"Group1");
   _removeGroup(_arrayCurrencyGroup2,"Group2");
   _removeGroup(_arrayCurrencyGroup3,"Group3");
   _removeGroup(_arrayCurrencyGroup4,"Group4");
   _removeGroup(_arrayCurrencyGroup5,"Group5");
   _removeGroup(_arrayCurrencyGroup6,"Group6");
   _removeGroup(_arrayCurrencyGroup7,"Group7");
   return(0);
}
void _removeGroup(string& __arrayCurrencyGroup[], string __groupName = "")
{
   _removeHeader(__arrayCurrencyGroup, __groupName);
   _removeVerticalPair(__arrayCurrencyGroup);
}
void _removeHeader(string& __arrayCurrencyGroup[], string __groupName)
{
   string __objectName, __arrayTimeFrameTextCopy[];
   ArrayCopy(__arrayTimeFrameTextCopy,_arrayTimeFrameText);
   //remove timeframe header
   for (int __x=0;__x<ArraySize(__arrayTimeFrameTextCopy);__x++)__objectName = "TimeFrame_" + __arrayTimeFrameTextCopy[__x] + "_" +__groupName;ObjectDelete(__objectName);
   //remove score header
   __objectName = "Synergy_" +__groupName;
   ObjectDelete(__objectName);
   
   for (int __y=0;__y<ArraySize(__arrayCurrencyGroup);__y++)//remove matrix
   {
      for (int __x=0;__x<ArraySize(__arrayTimeFrameTextCopy);__x++) 
      {
         __objectName = "Signal_" + __arrayCurrencyGroup[__y] + "_" + __arrayTimeFrameTextCopy[__x];ObjectDelete(__objectName);
         if(__x == ArraySize(__arrayTimeFrameTextCopy)-1) {__objectName = "Score_" + __arrayCurrencyGroup[__y]; ObjectDelete(__objectName);}//remove score
      }
   }
}
void _removeVerticalPair(string& __arrayCurrencyGroup[])
{
   for (int __x=0;__x<ArraySize(__arrayCurrencyGroup);__x++) {string __objectName = "Currency_" + __arrayCurrencyGroup[__x]; ObjectDelete(__objectName);}
}
