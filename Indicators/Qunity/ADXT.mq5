//+--------------------------------------------------------------------------------------------------------------------+
//|                                                                                                                    |
//|                                                                                                           ADXT.mq5 |
//|                                                                          Copyright 2022 - 2023, kyleRQWS@gmail.com |
//|                                                                                            https://vk.com/kylerqws |
//|                                                                                                                    |
//+--------------------------------------------------------------------------------------------------------------------+
#property copyright "Copyright 2022 - 2023, kyleRQWS@gmail.com"
#property link "https://vk.com/kylerqws"
#property version "1.00"

#define SHORT_NAME "ADXT"
#define INDICATOR_NAME "Qunity ADXT"

#property description INDICATOR_NAME " indicator based on the ADX / ADXWilder indicator"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 7
#property indicator_plots 6

#property indicator_label1 SHORT_NAME " ∷ Direction"
#property indicator_type1 DRAW_NONE
#property indicator_color1 clrNONE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

#property indicator_label2 SHORT_NAME " ∷ Strength"
#property indicator_type2 DRAW_COLOR_HISTOGRAM
#property indicator_color2 clrRed, clrOrange, clrGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 5

#property indicator_label3 SHORT_NAME " ∷ Open"
#property indicator_type3 DRAW_NONE
#property indicator_color3 clrNONE
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

#property indicator_label4 SHORT_NAME " ∷ High"
#property indicator_type4 DRAW_NONE
#property indicator_color4 clrNONE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

#property indicator_label5 SHORT_NAME " ∷ Low"
#property indicator_type5 DRAW_NONE
#property indicator_color5 clrNONE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1

#property indicator_label6 SHORT_NAME " ∷ Close"
#property indicator_type6 DRAW_NONE
#property indicator_color6 clrNONE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1

#include <Qunity/Chart/ADXTrend.mqh>

input ENUM_TIMEFRAMES CalcTimeframe = PERIOD_CURRENT;                         // Calculate Timeframe
input Qunity::Chart::ENUM_ADX_TYPES ADXType = Qunity::Chart::ADX_TYPE_WILDER; //   • ADX Type
input int ADXPeriod = 14;                                                     //   • ADX Period
input uchar ADXFilter = 15;                                                   //   • ADX Filter
input Qunity::ENUM_LOG_LEVELS LogLevel = Qunity::LOG_LEVEL_NO;                // Logging

Qunity::CLogger Logger;
Qunity::Chart::CADXTrend Trend;

int Calculateed = NULL;
string ShortName = NULL;

double StateBuffer[], StrengthBuffer[], ColorBuffer[], OpenBuffer[], HighBuffer[], LowBuffer[], CloseBuffer[];

//+--------------------------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                                           |
//+--------------------------------------------------------------------------------------------------------------------+
int OnInit(void)
{
    Logger.SetIdentity(SHORT_NAME);
    Logger.SetLogLevel(LogLevel);

    Trend.SetLogger(GetPointer(Logger));
    Trend.SetEnabled(true);
    Trend.SetTimeframe(CalcTimeframe);

    Trend.SetADXType(ADXType);
    Trend.SetADXPeriod(ADXPeriod);
    Trend.SetADXFilter(ADXFilter);

    if (!Trend.Init())
    {
        IndicatorSetString(INDICATOR_SHORTNAME, SHORT_NAME " ∷ Failed to initialize indicator core");

        return Error("Failed to initialize %indicator", INIT_FAILED);
    };

    ShortName = Trend.GetName();
    Logger.SetIdentity(ShortName);

    SetIndexBuffer(0, StateBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, StrengthBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, ColorBuffer, INDICATOR_COLOR_INDEX);
    SetIndexBuffer(3, OpenBuffer, INDICATOR_DATA);
    SetIndexBuffer(4, HighBuffer, INDICATOR_DATA);
    SetIndexBuffer(5, LowBuffer, INDICATOR_DATA);
    SetIndexBuffer(6, CloseBuffer, INDICATOR_DATA);

    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    IndicatorSetString(INDICATOR_SHORTNAME, StringFormat("%s ∷", ShortName));

    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, EMPTY_VALUE);

    return INIT_SUCCEEDED;
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                                                |
//+--------------------------------------------------------------------------------------------------------------------+
int OnCalculate(
    const int rates_total,
    const int prev_calculated,
    const datetime &time[],
    const double &open[],
    const double &high[],
    const double &low[],
    const double &close[],
    const long &tick_volume[],
    const long &volume[],
    const int &spread[])
{
    if (prev_calculated <= 0)
    {
        if (Calculateed == rates_total)
            return Calculateed;

        ArrayInitialize(StateBuffer, EMPTY_VALUE);
        ArrayInitialize(StrengthBuffer, EMPTY_VALUE);
        ArrayInitialize(ColorBuffer, EMPTY_VALUE);
        ArrayInitialize(OpenBuffer, EMPTY_VALUE);
        ArrayInitialize(HighBuffer, EMPTY_VALUE);
        ArrayInitialize(LowBuffer, EMPTY_VALUE);
        ArrayInitialize(CloseBuffer, EMPTY_VALUE);
    };

    int index = (prev_calculated > 0) ? prev_calculated - 1 : 0;
    while (index < rates_total && !IsStopped())
    {
        if (!Trend.Refresh(time[index], open[index], high[index], low[index], close[index]))
            return Error("Failed to refresh %indicator", index);

        StateBuffer[index] = Trend.GetState();
        StrengthBuffer[index] = Trend.GetStrength();
        ColorBuffer[index] = Trend.GetState() + 1;

        OpenBuffer[index] = Trend.GetPrice(Qunity::Chart::OHLC_INDEX_OPEN);
        HighBuffer[index] = Trend.GetPrice(Qunity::Chart::OHLC_INDEX_HIGH);
        LowBuffer[index] = Trend.GetPrice(Qunity::Chart::OHLC_INDEX_LOW);
        CloseBuffer[index] = Trend.GetPrice(Qunity::Chart::OHLC_INDEX_CLOSE);

        index++;
    };

    return Calculateed = index;
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Logging string output function                                                                                     |
//+--------------------------------------------------------------------------------------------------------------------+
void Log(const Qunity::ENUM_LOG_LEVELS level, const string message)
{
    if (level == Qunity::LOG_LEVEL_NO)
        return;

    string logMessage = message;

    StringReplace(logMessage, "%shortname", SHORT_NAME);
    StringReplace(logMessage, "%indicator", INDICATOR_NAME " indicator");

    Logger.Log(level, logMessage);
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Logging error string output function                                                                               |
//+--------------------------------------------------------------------------------------------------------------------+
int Error(const string message, const int result = NULL)
{
    Log(Qunity::LOG_LEVEL_ERROR, message);

    return result;
};
//+--------------------------------------------------------------------------------------------------------------------+
