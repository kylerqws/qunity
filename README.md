# Qunity Trading System

* **OHLC** indicator display OHLC series to multi-timeframe indicators;
* **ADXT** is trend indicator based on the ADX / ADXWilder indicator;
* **ADXMT** is multi-timeframe trend indicator based on the ADX / ADXWilder indicator;
* **ADXMT-F** indicator is ADXMT indicator with Fibonacci levels.

## Ichimoku Kinko Hyo

Corrected parameters for D1 timeframe of 5-day trading week is T8&nbsp;K22&nbsp;S44. To get daily lines on H4 timeframe chart, you need to multiply the daily parameters by 4 (number of H4 candles in one day), the result is T32&nbsp;K88&nbsp;S176.

## ADX Multi-Timeframe Trend with Fibonacci levels (ADXMT-F)

Trading system uses impulsive type of indicator. It uses two timeframes for futures: H4 and D1. H4 timeframe is for two days interval (8&nbsp;candles), D1 is for one week interval (5&nbsp;candles). Both screens use Welles Wilder's ADX indicator, and a filter of 20.
