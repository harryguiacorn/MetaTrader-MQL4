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









