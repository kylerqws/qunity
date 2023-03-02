//+--------------------------------------------------------------------------------------------------------------------+
//|                                                                                                                    |
//|                                                                                                           OHLC.mq5 |
//|                                                                          Copyright 2022 - 2023, kyleRQWS@gmail.com |
//|                                                                                            https://vk.com/kylerqws |
//|                                                                                                                    |
//+--------------------------------------------------------------------------------------------------------------------+
#property copyright "Copyright 2022 - 2023, kyleRQWS@gmail.com"
#property link "https://vk.com/kylerqws"
#property version "1.00"

#define SHORT_NAME "OHLC"
#define INDICATOR_NAME "Qunity OHLC"

#property description INDICATOR_NAME " indicator displays OHLC series of higher timeframes"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 1

#property indicator_label1 SHORT_NAME " ∷ Open;" SHORT_NAME " ∷ High;" SHORT_NAME " ∷ Low;" SHORT_NAME " ∷ Close"
#property indicator_type1 DRAW_COLOR_CANDLES
#property indicator_color1 clrRed, clrOrange, clrGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

#include <Qunity/Chart/OHLCSeries.mqh>

input ENUM_TIMEFRAMES CalcTimeframe = PERIOD_CURRENT;          // Calculate Timeframe
input bool ShowLevels = false;                                 // Show Levels
input color LevelColor = clrGray;                              //   • Color
input ENUM_LINE_STYLE LevelStyle = STYLE_SOLID;                //   • Style
input uchar LevelWidth = 2;                                    //   • Width
input Qunity::ENUM_LOG_LEVELS LogLevel = Qunity::LOG_LEVEL_NO; // Logging

Qunity::CLogger Logger;
Qunity::Chart::COHLCSeries OHLCSeries;

const int INDICATOR_ID = MathRand();

int Calculated = NULL;
double LastLevelHigh = NULL, LastLevelLow = NULL;
string ShortName = NULL, LevelHighName = NULL, LevelLowName = NULL;

double OpenBuffer[], HighBuffer[], LowBuffer[], CloseBuffer[], ColorBuffer[];

//+--------------------------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                                           |
//+--------------------------------------------------------------------------------------------------------------------+
int OnInit(void)
{
    Logger.SetIdentity(SHORT_NAME);
    Logger.SetLogLevel(LogLevel);

    OHLCSeries.SetLogger(GetPointer(Logger));
    OHLCSeries.SetEnabled(true);
    OHLCSeries.SetTimeframe(CalcTimeframe);

    if (!OHLCSeries.Init())
    {
        IndicatorSetString(INDICATOR_SHORTNAME, SHORT_NAME " ∷ Failed to initialize indicator core");

        return Error("Failed to initialize %indicator", INIT_FAILED);
    };

    ShortName = OHLCSeries.GetName();
    Logger.SetIdentity(ShortName);

    SetIndexBuffer(0, OpenBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, HighBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, LowBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, CloseBuffer, INDICATOR_DATA);
    SetIndexBuffer(4, ColorBuffer, INDICATOR_COLOR_INDEX);

    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    IndicatorSetString(INDICATOR_SHORTNAME, ShortName);

    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

    if (ShowLevels)
    {
        LevelHighName = PrepareObjectName(StringFormat("%s ∷ High", ShortName));
        LevelLowName = PrepareObjectName(StringFormat("%s ∷ Low", ShortName));

        if (!CreateLevelObject(LevelHighName) || !CreateLevelObject(LevelLowName))
            Info("Non-critical error in %indicator");
    };

    return INIT_SUCCEEDED;
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                                         |
//+--------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    if (ShowLevels)
        if (!RemoveLevelObject(LevelHighName) || !RemoveLevelObject(LevelLowName))
            Info("Non-critical error in %indicator");
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
        if (Calculated == rates_total)
            return Calculated;

        ArrayInitialize(OpenBuffer, EMPTY_VALUE);
        ArrayInitialize(HighBuffer, EMPTY_VALUE);
        ArrayInitialize(LowBuffer, EMPTY_VALUE);
        ArrayInitialize(CloseBuffer, EMPTY_VALUE);
        ArrayInitialize(ColorBuffer, EMPTY_VALUE);
    };

    int index = (prev_calculated > 0) ? prev_calculated - 1 : 0;
    while (index < rates_total && !IsStopped())
    {
        if (!OHLCSeries.Refresh(time[index], open[index], high[index], low[index], close[index]))
            return Error("Failed to refresh %indicator", index);

        ColorBuffer[index] = OHLCSeries.GetState() + 1;

        OpenBuffer[index] = OHLCSeries.GetPrice(Qunity::Chart::OHLC_INDEX_OPEN);
        HighBuffer[index] = OHLCSeries.GetPrice(Qunity::Chart::OHLC_INDEX_HIGH);
        LowBuffer[index] = OHLCSeries.GetPrice(Qunity::Chart::OHLC_INDEX_LOW);
        CloseBuffer[index] = OHLCSeries.GetPrice(Qunity::Chart::OHLC_INDEX_CLOSE);

        index++;
    };

    if (ShowLevels && index > 0)
    {
        const int jndex = index - 1;

        if (HighBuffer[jndex] != LastLevelHigh)
            if (!MoveLevelObject(LevelHighName, (LastLevelHigh = HighBuffer[jndex])))
                Info("Non-critical error in %indicator");

        if (LowBuffer[jndex] != LastLevelLow)
            if (!MoveLevelObject(LevelLowName, (LastLevelLow = LowBuffer[jndex])))
                Info("Non-critical error in %indicator");
    };

    return Calculated = index;
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
//| Logging info string output function                                                                                |
//+--------------------------------------------------------------------------------------------------------------------+
void Info(const string message)
{
    Log(Qunity::LOG_LEVEL_INFO, message);
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
//| Object name preparing function                                                                                     |
//+--------------------------------------------------------------------------------------------------------------------+
string PrepareObjectName(const string name)
{
    return StringFormat("[%d] %s", INDICATOR_ID, name);
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Level object creating function                                                                                     |
//+--------------------------------------------------------------------------------------------------------------------+
bool CreateLevelObject(const string name)
{
    ResetLastError();
    if (!ObjectCreate(0, name, OBJ_HLINE, 0, 0, 0.0))
        return (bool)Error("Failed to create level in %indicator", false);

    ObjectSetInteger(0, name, OBJPROP_COLOR, LevelColor);
    ObjectSetInteger(0, name, OBJPROP_STYLE, LevelStyle);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, LevelWidth);

    ChartRedraw();

    return true;
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Level object moving function                                                                                       |
//+--------------------------------------------------------------------------------------------------------------------+
bool MoveLevelObject(const string name, const double price)
{
    ResetLastError();
    if (!ObjectMove(0, name, 0, 0, price))
        return (bool)Error("Failed to move level in %indicator", false);

    ChartRedraw();

    return true;
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Level object removing function                                                                                     |
//+--------------------------------------------------------------------------------------------------------------------+
bool RemoveLevelObject(const string name)
{
    ResetLastError();
    if (!ObjectDelete(0, name))
        return (bool)Error("Failed to remove level in %indicator", false);

    ChartRedraw();

    return true;
};
//+--------------------------------------------------------------------------------------------------------------------+
