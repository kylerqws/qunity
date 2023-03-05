//+--------------------------------------------------------------------------------------------------------------------+
//|                                                                                                                    |
//|                                                                                                        ADXMT-F.mq5 |
//|                                                                          Copyright 2022 - 2023, kyleRQWS@gmail.com |
//|                                                                                            https://vk.com/kylerqws |
//|                                                                                                                    |
//+--------------------------------------------------------------------------------------------------------------------+
#property copyright "Copyright 2022 - 2023, kyleRQWS@gmail.com"
#property link "https://vk.com/kylerqws"
#property version "1.02"

#define SHORT_NAME "ADXMT-F"
#define INDICATOR_NAME "Qunity ADXMT-F"

#property description INDICATOR_NAME " is multi-timeframe trend indicator based on the ADX / ADXWilder indicator with Fibonacci levels"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 10
#property indicator_plots 6

#property indicator_label1 SHORT_NAME " ∷ Direction"
#property indicator_type1 DRAW_NONE
#property indicator_color1 clrNONE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

#property indicator_label2 SHORT_NAME " ∷ Strength"
#property indicator_type2 DRAW_COLOR_HISTOGRAM
#property indicator_color2 clrRed, clrOrange, clrGreen, clrDarkSalmon, clrGoldenrod, clrDarkKhaki
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
#include <Qunity/Chart/Fibonacci.mqh>
#include <Qunity/Chart/Tendency.mqh>

input ENUM_TIMEFRAMES CalcTimeframe = PERIOD_CURRENT;                                                    // Calculate Timeframe
input Qunity::Chart::ENUM_TENDENCY_TYPES TendencyType = Qunity::Chart::TENDENCY_TYPE_IMPULSE;            //   • Tendency Type
input Qunity::Chart::ENUM_ADX_TYPES ADX0Type = Qunity::Chart::ADX_TYPE_WILDER;                           // Config Screen Junior
input int ADX0Period = 14;                                                                               //   • ADX Period
input uchar ADX0Filter = 15;                                                                             //   • ADX Filter
input bool ADX1Enabled = false;                                                                          // Config Screen Middle
input ENUM_TIMEFRAMES ADX1Timeframe = PERIOD_H4;                                                         //   • Timeframe
input Qunity::Chart::ENUM_ADX_TYPES ADX1Type = Qunity::Chart::ADX_TYPE_WILDER;                           //   • ADX Type
input int ADX1Period = 9;                                                                                //   • ADX Period
input uchar ADX1Filter = 15;                                                                             //   • ADX Filter
input bool ADX2Enabled = false;                                                                          // Config Screen Senior
input ENUM_TIMEFRAMES ADX2Timeframe = PERIOD_D1;                                                         //   • Timeframe
input Qunity::Chart::ENUM_ADX_TYPES ADX2Type = Qunity::Chart::ADX_TYPE_WILDER;                           //   • ADX Type
input int ADX2Period = 5;                                                                                //   • ADX Period
input uchar ADX2Filter = 15;                                                                             //   • ADX Filter
input bool ShowFiboLevels = true;                                                                        // Show Fibonacci Levels
input Qunity::Chart::ENUM_FIBO_TYPES FiboRange1Type = Qunity::Chart::FIBO_TYPE_X000_X236_X382_X500_X618; //   • Range #1
input Qunity::Chart::ENUM_FIBO_TYPES FiboRange2Type = Qunity::Chart::FIBO_TYPE_X000_X618;                //   • Range #2
input Qunity::Chart::ENUM_FIBO_TYPES FiboRange3Type = Qunity::Chart::FIBO_TYPE_X618;                     //   • Range #3
input Qunity::Chart::ENUM_FIBO_TYPES FiboRange4Type = Qunity::Chart::FIBO_TYPE_DISABLE;                  //   • Range #4
input Qunity::Chart::ENUM_FIBO_TYPES FiboRange5Type = Qunity::Chart::FIBO_TYPE_X236;                     //   • Range #5
input Qunity::Chart::ENUM_FIBO_TYPES FiboRange6Type = Qunity::Chart::FIBO_TYPE_DISABLE;                  //   • Range #6
input bool RoundLevelsText = true;                                                                       // - Round Levels
input color RoundLevelColor = clrGray;                                                                   //   • Color
input ENUM_LINE_STYLE RoundLevelStyle = STYLE_SOLID;                                                     //   • Style
input uchar RoundLevelWidth = 2;                                                                         //   • Width
input bool HalfLevelsText = true;                                                                        // - Half Levels
input color HalfLevelColor = clrDarkGray;                                                                //   • Color
input ENUM_LINE_STYLE HalfLevelStyle = STYLE_SOLID;                                                      //   • Style
input uchar HalfLevelWidth = 1;                                                                          //   • Width
input bool FloatLevelsText = true;                                                                       // - Float Levels
input color FloatLevelColor = clrLightGray;                                                              //   • Color
input ENUM_LINE_STYLE FloatLevelStyle = STYLE_DOT;                                                       //   • Style
input uchar FloatLevelWidth = 1;                                                                         //   • Width
input Qunity::ENUM_LOG_LEVELS LogLevel = Qunity::LOG_LEVEL_NO;                                           // Logging

Qunity::CLogger Logger;
Qunity::Chart::CADXTrend Junior, Middle, Senior;
Qunity::Chart::CFibonacci Fibonacci;
Qunity::Chart::CTendency Tendency;

const int INDICATOR_ID = MathRand();

uchar FiboSizeLevels;
Qunity::Chart::ENUM_FIBO_LEVELS FiboLevels[];

int Calculated = NULL, FiboBarIndex = NULL;
double LastFiboPrice1 = NULL, LastFiboPrice2 = NULL;
string ShortName = NULL, FiboName = NULL, FiboObjectName = NULL;

double BinaryStateBuffer[], TrendStateBuffer[], ImpulseStateBuffer[];
double StateBuffer[], StrengthBuffer[], ColorBuffer[], OpenBuffer[], HighBuffer[], LowBuffer[], CloseBuffer[];

//+--------------------------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                                           |
//+--------------------------------------------------------------------------------------------------------------------+
int OnInit(void)
{
    Logger.SetIdentity(SHORT_NAME);
    Logger.SetLogLevel(LogLevel);

    Qunity::CLogger *logger = GetPointer(Logger);

    Junior.SetLogger(logger);
    Junior.SetEnabled(true);
    Junior.SetTimeframe(CalcTimeframe);

    Junior.SetADXType(ADX0Type);
    Junior.SetADXPeriod(ADX0Period);
    Junior.SetADXFilter(ADX0Filter);

    Middle.SetLogger(logger);
    Middle.SetEnabled(ADX1Enabled);
    Middle.SetTimeframe(ADX1Timeframe);

    Middle.SetADXType(ADX1Type);
    Middle.SetADXPeriod(ADX1Period);
    Middle.SetADXFilter(ADX1Filter);

    Senior.SetLogger(logger);
    Senior.SetEnabled(ADX2Enabled);
    Senior.SetTimeframe(ADX2Timeframe);

    Senior.SetADXType(ADX2Type);
    Senior.SetADXPeriod(ADX2Period);
    Senior.SetADXFilter(ADX2Filter);

    Tendency.SetLogger(logger);
    Tendency.SetEnabled(true);
    Tendency.SetTimeframe(CalcTimeframe);

    Tendency.SetType(TendencyType);

    Tendency.SetTrend(Qunity::Chart::SCREEN_JUNIOR, GetPointer(Junior));
    Tendency.SetTrend(Qunity::Chart::SCREEN_MIDDLE, GetPointer(Middle));
    Tendency.SetTrend(Qunity::Chart::SCREEN_SENIOR, GetPointer(Senior));

    if (!Tendency.Init())
    {
        IndicatorSetString(INDICATOR_SHORTNAME, SHORT_NAME " ∷ Failed to initialize indicator core");

        return Error("Failed to initialize %indicator", INIT_FAILED);
    };

    ShortName = Tendency.GetName();
    Logger.SetIdentity(ShortName);

    SetIndexBuffer(0, StateBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, StrengthBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, ColorBuffer, INDICATOR_COLOR_INDEX);
    SetIndexBuffer(3, OpenBuffer, INDICATOR_DATA);
    SetIndexBuffer(4, HighBuffer, INDICATOR_DATA);
    SetIndexBuffer(5, LowBuffer, INDICATOR_DATA);
    SetIndexBuffer(6, CloseBuffer, INDICATOR_DATA);

    SetIndexBuffer(7, BinaryStateBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(8, TrendStateBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(9, ImpulseStateBuffer, INDICATOR_CALCULATIONS);

    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    IndicatorSetString(INDICATOR_SHORTNAME, StringFormat("%s ∷", ShortName));

    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, EMPTY_VALUE);

    if (ShowFiboLevels)
    {
        Fibonacci.SetLogger(logger);
        Fibonacci.SetEnabled(ShowFiboLevels);

        Fibonacci.SetType(Qunity::Chart::FIBO_RANGE_1, FiboRange1Type);
        Fibonacci.SetType(Qunity::Chart::FIBO_RANGE_2, FiboRange2Type);
        Fibonacci.SetType(Qunity::Chart::FIBO_RANGE_3, FiboRange3Type);
        Fibonacci.SetType(Qunity::Chart::FIBO_RANGE_4, FiboRange4Type);
        Fibonacci.SetType(Qunity::Chart::FIBO_RANGE_5, FiboRange5Type);
        Fibonacci.SetType(Qunity::Chart::FIBO_RANGE_6, FiboRange6Type);

        if (!Fibonacci.Init())
        {
            IndicatorSetString(INDICATOR_SHORTNAME, SHORT_NAME " ∷ Failed to initialize Fibonacci");

            return Error("Failed to initialize Fibonacci in %indicator", INIT_FAILED);
        };

        FiboName = Fibonacci.GetName();
        Logger.SetIdentity(StringFormat("%s ∷ %s", ShortName, FiboName));

        if (!Fibonacci.CopyLevels(FiboLevels))
        {
            IndicatorSetString(INDICATOR_SHORTNAME, SHORT_NAME " ∷ Failed to initialize Fibonacci");

            return Error("Failed to copy Fibonacci levels in %indicator", INIT_FAILED);
        };

        FiboSizeLevels = Fibonacci.GetSizeLevels();
        FiboObjectName = PrepareObjectName(FiboName);

        if (!CreateFiboObject(FiboObjectName) || !CreateLevelsObjects(FiboObjectName))
            Info("Non-critical error in %indicator");
    };

    return INIT_SUCCEEDED;
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                                         |
//+--------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    if (ShowFiboLevels)
        if (!RemoveFiboObject(FiboObjectName) || !RemoveLevelsObjects(FiboObjectName))
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

        ArrayInitialize(StateBuffer, EMPTY_VALUE);
        ArrayInitialize(StrengthBuffer, EMPTY_VALUE);
        ArrayInitialize(ColorBuffer, EMPTY_VALUE);
        ArrayInitialize(OpenBuffer, EMPTY_VALUE);
        ArrayInitialize(HighBuffer, EMPTY_VALUE);
        ArrayInitialize(LowBuffer, EMPTY_VALUE);
        ArrayInitialize(CloseBuffer, EMPTY_VALUE);

        ArrayInitialize(BinaryStateBuffer, Qunity::Chart::STATE_MISSING);
        ArrayInitialize(TrendStateBuffer, Qunity::Chart::STATE_MISSING);
        ArrayInitialize(ImpulseStateBuffer, Qunity::Chart::STATE_MISSING);
    };

    int index = (prev_calculated > 0) ? prev_calculated - 1 : 0;
    while (index < rates_total && !IsStopped())
    {
        if (!Tendency.Refresh(time[index], open[index], high[index], low[index], close[index]))
            return Error("Failed to refresh %indicator", index);

        StateBuffer[index] = Tendency.GetState();
        StrengthBuffer[index] = Tendency.GetStrength();
        ColorBuffer[index] = Tendency.GetState() + 1;

        OpenBuffer[index] = Tendency.GetPrice(Qunity::Chart::OHLC_INDEX_OPEN);
        HighBuffer[index] = Tendency.GetPrice(Qunity::Chart::OHLC_INDEX_HIGH);
        LowBuffer[index] = Tendency.GetPrice(Qunity::Chart::OHLC_INDEX_LOW);
        CloseBuffer[index] = Tendency.GetPrice(Qunity::Chart::OHLC_INDEX_CLOSE);

        BinaryStateBuffer[index] = Tendency.GetState(Qunity::Chart::STATE_INDEX_BINARY);
        TrendStateBuffer[index] = Tendency.GetState(Qunity::Chart::STATE_INDEX_TREND);
        ImpulseStateBuffer[index] = Tendency.GetState(Qunity::Chart::STATE_INDEX_IMPULSE);

        if (TendencyType == Qunity::Chart::TENDENCY_TYPE_IMPULSE && index > 0)
        {
            int jndex = index;
            const datetime startTime = Tendency.GetTime(Qunity::Chart::OHLC_INDEX_OPEN);

            if (ImpulseStateBuffer[index] != Qunity::Chart::STATE_MISSING)
                while (--jndex >= 0 && time[jndex] >= startTime && !IsStopped())
                    ColorBuffer[jndex] = 4;

            else if (TrendStateBuffer[index] != Qunity::Chart::STATE_MISSING)
                ColorBuffer[index] = TrendStateBuffer[index] + 4;

            if (TrendStateBuffer[index] == BinaryStateBuffer[index - 1])
                while (--jndex >= 0 && ColorBuffer[jndex] == 1 && !IsStopped())
                    ColorBuffer[jndex] = 4;
        };

        if (ShowFiboLevels && index > 0)
        {
            const int jndex = index - 1;

            if (StateBuffer[jndex] != Qunity::Chart::STATE_MISSING)
                FiboBarIndex = jndex;
        };

        index++;
    };

    if (ShowFiboLevels)
    {
        double price1 = HighBuffer[FiboBarIndex], price2 = LowBuffer[FiboBarIndex];

        if (BinaryStateBuffer[FiboBarIndex] != Qunity::Chart::STATE_BULLISH)
        {
            price1 = LowBuffer[FiboBarIndex];
            price2 = HighBuffer[FiboBarIndex];
        };

        if (price1 != LastFiboPrice1 || price2 != LastFiboPrice2)
        {
            if (!Fibonacci.Refresh((LastFiboPrice1 = price1), (LastFiboPrice2 = price2)))
                return Error("Failed to refresh Fibonacci in %indicator", FiboBarIndex);

            if (!MoveFiboObject(FiboObjectName, price1, price2) || !MoveLevelsObjects(FiboObjectName))
                Info("Non-critical error in %indicator");
        };
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
//| Fibonacci level is round level checking function                                                                   |
//+--------------------------------------------------------------------------------------------------------------------+
bool IsRoundLevel(const Qunity::Chart::ENUM_FIBO_LEVELS level)
{
    return level == Qunity::Chart::FIBO_LEVEL_000_0 || level == Qunity::Chart::FIBO_LEVEL_100_0 ||
           level == Qunity::Chart::FIBO_LEVEL_200_0 || level == Qunity::Chart::FIBO_LEVEL_300_0 ||
           level == Qunity::Chart::FIBO_LEVEL_400_0 || level == Qunity::Chart::FIBO_LEVEL_500_0;
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Fibonacci level is half level checking function                                                                    |
//+--------------------------------------------------------------------------------------------------------------------+
bool IsHalfLevel(const Qunity::Chart::ENUM_FIBO_LEVELS level)
{
    return level == Qunity::Chart::FIBO_LEVEL_050_0 || level == Qunity::Chart::FIBO_LEVEL_150_0 ||
           level == Qunity::Chart::FIBO_LEVEL_250_0 || level == Qunity::Chart::FIBO_LEVEL_350_0 ||
           level == Qunity::Chart::FIBO_LEVEL_450_0 || level == Qunity::Chart::FIBO_LEVEL_550_0;
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Fibonacci level is float level checking function                                                                   |
//+--------------------------------------------------------------------------------------------------------------------+
bool IsFloatLevel(const Qunity::Chart::ENUM_FIBO_LEVELS level)
{
    return (bool)(!IsRoundLevel(level) && !IsHalfLevel(level));
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Fibonacci object creating function                                                                                 |
//+--------------------------------------------------------------------------------------------------------------------+
bool CreateFiboObject(const string name)
{
    ResetLastError();
    if (!ObjectCreate(0, name, OBJ_FIBO, 0, 0, 0.0, 0, 0.0))
        return (bool)Error("Failed to create Fibonacci in %indicator", false);

    ObjectSetInteger(0, name, OBJPROP_COLOR, clrNONE);
    ObjectSetInteger(0, name, OBJPROP_LEVELS, FiboSizeLevels);

    ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, true);
    ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, true);

    for (uchar index = 0; index < FiboSizeLevels && !IsStopped(); index++)
    {
        const double levelValue = Fibonacci.LevelToFactor(FiboLevels[index]);
        const string levelText = StringFormat("%s  ", Fibonacci.LevelToString(FiboLevels[index]));

        ObjectSetInteger(0, name, OBJPROP_LEVELCOLOR, index, clrNONE);
        ObjectSetDouble(0, name, OBJPROP_LEVELVALUE, index, levelValue);
        ObjectSetString(0, name, OBJPROP_LEVELTEXT, index, "");

        if (IsRoundLevel(FiboLevels[index]) && !RoundLevelsText)
            continue;

        if (IsHalfLevel(FiboLevels[index]) && !HalfLevelsText)
            continue;

        if (IsFloatLevel(FiboLevels[index]) && !FloatLevelsText)
            continue;

        ObjectSetString(0, name, OBJPROP_LEVELTEXT, index, levelText);
    };

    ChartRedraw();

    return true;
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Fibonacci object moving function                                                                                   |
//+--------------------------------------------------------------------------------------------------------------------+
bool MoveFiboObject(const string name, const double price1, const double price2)
{
    ResetLastError();
    if (!ObjectMove(0, name, 0, 0, price1) || !ObjectMove(0, name, 1, 0, price2))
        return (bool)Error("Failed to move Fibonacci in %indicator", false);

    ChartRedraw();

    return true;
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Fibonacci object removing function                                                                                 |
//+--------------------------------------------------------------------------------------------------------------------+
bool RemoveFiboObject(const string name)
{
    ResetLastError();
    if (!ObjectDelete(0, name))
        return (bool)Error("Failed to remove Fibonacci in %indicator", false);

    ChartRedraw();

    return true;
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Fibonacci level object name creating function                                                                      |
//+--------------------------------------------------------------------------------------------------------------------+
string CreateLevelName(const string name, const string lname = NULL)
{
    if (lname != NULL)
        return StringFormat("%s ∷ L%s", name, lname);

    return StringFormat("%s ∷ L", name);
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Fibonacci levels objects creating function                                                                         |
//+--------------------------------------------------------------------------------------------------------------------+
bool CreateLevelsObjects(const string name)
{
    for (uchar index = 0; index < FiboSizeLevels && !IsStopped(); index++)
    {
        const string lname = CreateLevelName(name, Fibonacci.LevelToString(FiboLevels[index]));

        ResetLastError();
        if (!ObjectCreate(0, lname, OBJ_HLINE, 0, 0, 0.0))
            return (bool)Error("Failed to create level in %indicator", false);

        if (IsRoundLevel(FiboLevels[index]))
        {
            ObjectSetInteger(0, lname, OBJPROP_COLOR, RoundLevelColor);
            ObjectSetInteger(0, lname, OBJPROP_STYLE, RoundLevelStyle);
            ObjectSetInteger(0, lname, OBJPROP_WIDTH, RoundLevelWidth);

            continue;
        };

        if (IsHalfLevel(FiboLevels[index]))
        {
            ObjectSetInteger(0, lname, OBJPROP_COLOR, HalfLevelColor);
            ObjectSetInteger(0, lname, OBJPROP_STYLE, HalfLevelStyle);
            ObjectSetInteger(0, lname, OBJPROP_WIDTH, HalfLevelWidth);

            continue;
        };

        if (IsFloatLevel(FiboLevels[index]))
        {
            ObjectSetInteger(0, lname, OBJPROP_COLOR, FloatLevelColor);
            ObjectSetInteger(0, lname, OBJPROP_STYLE, FloatLevelStyle);
            ObjectSetInteger(0, lname, OBJPROP_WIDTH, FloatLevelWidth);

            continue;
        };
    };

    ChartRedraw();

    return true;
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Fibonacci levels objects moving function                                                                           |
//+--------------------------------------------------------------------------------------------------------------------+
bool MoveLevelsObjects(const string name)
{
    for (uchar index = 0; index < FiboSizeLevels && !IsStopped(); index++)
    {
        const string lname = CreateLevelName(name, Fibonacci.LevelToString(FiboLevels[index]));

        ResetLastError();
        if (!ObjectMove(0, lname, 0, 0, Fibonacci.GetPrice(FiboLevels[index])))
            return (bool)Error("Failed to move level in %indicator", false);
    };

    ChartRedraw();

    return true;
};

//+--------------------------------------------------------------------------------------------------------------------+
//| Fibonacci levels objects removing function                                                                         |
//+--------------------------------------------------------------------------------------------------------------------+
bool RemoveLevelsObjects(const string name)
{
    ResetLastError();
    if (!ObjectsDeleteAll(0, CreateLevelName(name)))
        return (bool)Error("Failed to remove level(s) in %indicator", false);

    ChartRedraw();

    return true;
};
//+--------------------------------------------------------------------------------------------------------------------+
