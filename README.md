# MetaTrader-MQL4 Scripts

## Advanced ADX

ADX Indicator for Trend Strength Measurement

This indicator provides insights into the strength of a trend, helping you identify periods of strong directional movement (trends) or ranging periods (choppy markets).

![unnamed](https://github.com/harryguiacorn/MetaTrader-MQL4/assets/1398153/b65a40a1-b1d5-46f3-a5ef-5fc97fd7b4ea)

Key Features:

- ADX Line (Yellow): Measures trend strength, ranging from 0 to 100. A value above 20 generally indicates a strong trend, while below 20 suggests a weak trend or choppy market.
Directional Movement Indicators (Green & Red Bars):
- +DI (Green): Represents buying pressure. A higher +DI than -DI suggests an uptrend.
- -DI (Red): Represents selling pressure. A higher -DI than +DI suggests a downtrend.

Benefits:

- Trend Strength Identification: Helps identify strong trends for potential trading opportunities.
- Trend Direction: Combined with +DI/-DI, you can gauge the direction of the trend (uptrend or downtrend).

## Cloud

The standard Ichimoku cloud indicator can be visually cluttered and overwhelming for traders. This indicator aims to simplify Ichimoku analysis by using colored dots to highlight significant signals without obscuring the chart.

![image](https://github.com/harryguiacorn/MetaTrader-MQL4/assets/1398153/15869731-dd16-4e64-a4b1-aa00a76b9e06)

![image](https://github.com/harryguiacorn/MetaTrader-MQL4/assets/1398153/6aa0b51a-4127-4597-94be-c23a43de259e)

- Green dots: Appear when the Tenkan-sen (blue line) crosses above the Kijun-sen (red line). This is typically seen as a bullish signal in Ichimoku Cloud analysis.
- Orange dots: Appear when the Tenkan-sen (blue line) crosses below the Kijun-sen (red line). This is typically seen as a bearish signal in Ichimoku Cloud analysis.
- Yellow dots: Appear when the price candles break above or below the Ichimoku Cloud. A break above the cloud is generally considered a bullish sign, while a break below is seen as bearish.
- Purple dots: Appear at the price point where it first breaks through the Parabolic SAR (SAR) indicator. These dots can be used as an initial stop-loss placement and can be gradually trailed up to lock in profits as the price moves favorably.

## Cloud Legend

![image](https://github.com/harryguiacorn/MetaTrader-MQL4/assets/1398153/dcbccce2-add3-41d2-8338-008b07dd111d)

### Current Spread and Volatility

- The Cloud Legend helps users identify the instrument's current spread (the difference between the bid and ask price).
- It also shows the Average True Range (ATR) for the past 20 days and the daily range.
- If the daily range is higher than the ATR, it suggests the chance of further price movement in either direction (up or down) may be reduced.

### Time Frame and Trend

- The Cloud Legend also displays the ATR for the current chart's time frame.
- The ADX (Average Directional Movement Index) reading indicates the trend strength of the instrument on the daily chart.
- A value below 20 generally suggests a choppy market with no clear direction, while a value above 20 suggests a stronger trend.

## Cloud Radar

The Cloud Radar screen gives a one-glance analysis of the instruments broken down into multi-timeframe, e.g. EURUSD is a potential candidate for a long position as weekly, 4h and 1h are above the cloud, therefore the Synergy score is a 3, while ADX is 41 which is in a trendy mode.

![image](https://github.com/harryguiacorn/MetaTrader-MQL4/assets/1398153/7c145828-13c1-48bb-a480-5b8b0615a0a9)

## Engulfing Bar
- Standard engulfing bar: The body of the second bar completely engulfs the body of the first bar, indicating a price reversal (bullish or bearish). For example, if the 1st bar is a bull bar and the 2nd bar's body is bigger and it's a bear bar, it qualifies as an engulfing bearish signal.
- Walter Peters' definition: This definition builds upon the standard engulfing bar. It requires not only the body of the second bar to engulf the first but also the range (the difference between the high and the low) of the second bar to be larger than the range of the first bar.

![image](https://github.com/harryguiacorn/MetaTrader-MQL4/assets/1398153/c2992082-abac-41e5-a9ee-db14719f650c)

## Fat Wick

This indicator increases the thickness of candle wicks, making them more visually prominent. This can help traders spot sharp price reversals and potential stop-hunting activity.

![image](https://github.com/harryguiacorn/MetaTrader-MQL4/assets/1398153/3eb03777-01d0-424e-ac06-a2de692536d3)

![image](https://github.com/harryguiacorn/MetaTrader-MQL4/assets/1398153/8027266c-f4be-4c78-98fd-f9aa32209d46)

## MACD - Cloud

The MACD indicator is used to gauge momentum and identify potential trading opportunities when the MACD histogram loses momentum, the Ichimoku cloud acts as the overall direction gauge. 

Therefore, when the MACD histogram ticks up when the price is above the Ichimoku cloud, it indicates the short-term downtrend momentum is coming to an end, and the uptrend is about to resume.

![image](https://github.com/harryguiacorn/MetaTrader-MQL4/assets/1398153/288f4705-8fb8-462b-9bf9-a5aab0eaf5c3)

## John Carter's Mastering the Trade (Chapter 8 - Scalper)
TRADING RULES FOR BUYS (SELLS ARE REVERSED)

- Set up a 24-hour chart on intraday charts so the overnight activity can be accounted for in this indicator setup. This can be used in all timeframes. The larger the timeframe, the larger the parameters and potential move. For daily charts I will use the regular session hours.

- After three consecutive higher closes, I go long at the market, at the close of the third bar in the sequence.

- The trade is valid until three consecutive lower closes occur, at which point I exit the trade. If the market is still open for an intraday trade, I will simultaneously exit a long and establish a new short position. I don't use a stop loss on this for intraday chart trades because the reversal signal is my exit strategy, whether it is a loss or a gain. For daily charts I will place a stop at the low of the bar that caused the signal to fire off, which is the first of three in the sequence of closes.

- If I'm in an intraday trade (15-minute chart or smaller) and the market closes before giving an exit signal, I will exit at the market at 4:10 p.m. Eastern.

- For timeframes that are 60 minutes and above, I will stay in them overnight and exit at the next signal. This could be the next day for a 60-minute chart, and it could be a month later for daily charts.

![image](https://github.com/harryguiacorn/MetaTrader-MQL4/assets/1398153/4f7e4552-7f51-46fa-8c89-b6911ec09cc1)

